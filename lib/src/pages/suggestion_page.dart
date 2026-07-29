import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../features/recommendation/suggestion_flow_service.dart';
import '../models/hour_minute.dart';
import '../models/interest_category.dart';
import '../models/suggestion.dart';
import '../models/suggestion_record.dart';
import '../models/user_settings.dart';
import '../repositories/current_suggestion_repository.dart';
import '../repositories/ongoing_suggestion_repository.dart';
import '../repositories/records_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/suggestion_repository.dart';
import '../widgets/completion_celebration.dart';
import '../widgets/completion_modal.dart';
import '../widgets/neumorphic_surface.dart';
import '../widgets/section_card.dart';
import '../widgets/suggestion_card_content.dart';
import 'suggestion_settings_page.dart';

enum _LoadStatus { loading, loaded, error }

/// 提案タブ（トップ画面）。仕様書 3.1 に対応する。
/// 「今日のよりみち」カードと現在の提案条件カードを上から順に表示し、
/// 条件カードのカテゴリチップで絞り込みを即時に切り替え、
/// 「スキップして次の提案」で再抽選、「変更 >」で提案設定画面へ遷移する。
/// 業務ロジック（読込・抽選・復元・履歴保存）は [SuggestionFlowService] が担う。
class SuggestionPage extends StatefulWidget {
  const SuggestionPage({
    super.key,
    this.suggestionRepository,
    this.settingsRepository,
    this.recordsRepository,
    this.currentSuggestionRepository,
    this.ongoingSuggestionRepository,
    this.random,
    this.historyDestinationKey,
    this.onSuggestionCompleted,
  });

  /// テスト用に差し替え可能。null なら通常の repository・乱数を使う。
  final SuggestionRepository? suggestionRepository;
  final SettingsRepository? settingsRepository;
  final RecordsRepository? recordsRepository;
  final CurrentSuggestionRepository? currentSuggestionRepository;
  final OngoingSuggestionRepository? ongoingSuggestionRepository;
  final Random? random;

  /// カード吸い込み先となる履歴タブのアイコン位置を取得するためのキー。
  final GlobalKey? historyDestinationKey;

  /// 完了演出後、保存した履歴 ID を渡して履歴タブへ切り替える。
  final ValueChanged<String>? onSuggestionCompleted;

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  late final SettingsRepository _settingsRepository;
  late final SuggestionFlowService _flowService;

  _LoadStatus _status = _LoadStatus.loading;
  List<Suggestion> _allSuggestions = const [];
  UserSettings _settings = const UserSettings();

  /// 表示中の提案。null は「条件に合う候補なし」を表す。
  Suggestion? _currentSuggestion;

  /// 実施中のよりみち。null は「実施中なし」（通常の提案表示）を表す。
  Suggestion? _ongoingSuggestion;
  DateTime? _ongoingStartedAt;
  final GlobalKey _ongoingCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _flowService = SuggestionFlowService(
      suggestionRepository:
          widget.suggestionRepository ?? SuggestionRepository(),
      settingsRepository: _settingsRepository,
      recordsRepository: widget.recordsRepository ?? RecordsRepository(),
      currentSuggestionRepository:
          widget.currentSuggestionRepository ?? CurrentSuggestionRepository(),
      ongoingSuggestionRepository:
          widget.ongoingSuggestionRepository ?? OngoingSuggestionRepository(),
      random: widget.random ?? Random(),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final snapshot = await _flowService.load();
      if (!mounted) {
        return;
      }
      setState(() {
        _allSuggestions = snapshot.suggestions;
        _settings = snapshot.settings;
        _status = _LoadStatus.loaded;
        if (snapshot.ongoingSuggestion != null) {
          _ongoingSuggestion = snapshot.ongoingSuggestion;
          _ongoingStartedAt = snapshot.ongoingStartedAt;
        }
        if (snapshot.restoredSuggestion == null) {
          _drawSuggestion();
        } else {
          _currentSuggestion = snapshot.restoredSuggestion;
          _flowService.persistCurrentSuggestion(snapshot.restoredSuggestion);
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _LoadStatus.error;
      });
    }
  }

  /// 現在の設定で再抽選し、表示中の提案を差し替える。
  void _drawSuggestion() {
    _currentSuggestion = _flowService.drawSuggestion(
      suggestions: _allSuggestions,
      settings: _settings,
    );
  }

  /// やってみる：提案を実施中状態に切り替える（issue #48）。
  void _onTrySuggestion(Suggestion suggestion) {
    final startedAt = DateTime.now();
    setState(() {
      _ongoingSuggestion = suggestion;
      _ongoingStartedAt = startedAt;
    });
    _flowService.startOngoing(suggestion, startedAt);
  }

  /// 実施中カードの完了：フィードバックを聞いて done として履歴に保存し、
  /// お祝いを表示して履歴タブへ移る。モーダルを閉じただけなら実施中のまま。
  /// 保存の成否表示・保存中のボタン無効化はモーダル側が担う（issue #44）。
  Future<void> _onCompleteOngoing(Suggestion suggestion) async {
    final completedRecordId = buildSuggestionRecordId(DateTime.now());
    final saved = await showCompletionModal(
      context,
      onSave: (feedback) async {
        await _flowService.saveRecord(
          suggestion,
          status: SuggestionRecordStatus.done,
          feedback: feedback,
          recordId: completedRecordId,
        );
        // スキップからの復活なら、挽回された元のスキップ履歴を削除する。
        await _flowService.removeRevivedSkipRecord();
        _settings = _flowService.appendRecentSuggestionId(
          _settings,
          suggestion.id,
        );
      },
    );
    if (!mounted || saved != true) {
      return;
    }

    final sourceRect = _ongoingCardRect();
    final historyDestinationCenter = _historyDestinationCenter();
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    await showCompletionCheckOverlay(
      context: context,
      disableAnimations: disableAnimations,
    );
    if (!mounted) {
      return;
    }

    await _clearOngoing();
    if (!mounted) {
      return;
    }

    await showCompletionCardFlightOverlay(
      context: context,
      sourceRect: sourceRect,
      targetCenter: historyDestinationCenter,
      suggestionTitle: suggestion.title,
      disableAnimations: disableAnimations,
    );
    if (!mounted) {
      return;
    }
    widget.onSuggestionCompleted?.call(completedRecordId);
  }

  Rect _ongoingCardRect() {
    final cardRect = _globalRectFor(_ongoingCardKey);
    if (cardRect != null) {
      return cardRect;
    }

    final screenSize = MediaQuery.sizeOf(context);
    final fallbackWidth = min(screenSize.width - 48, 400.0);
    return Rect.fromLTWH(
      (screenSize.width - fallbackWidth) / 2,
      screenSize.height * 0.25,
      fallbackWidth,
      220,
    );
  }

  Offset _historyDestinationCenter() {
    final destinationKey = widget.historyDestinationKey;
    if (destinationKey != null) {
      final destinationRect = _globalRectFor(destinationKey);
      if (destinationRect != null) {
        return destinationRect.center;
      }
    }

    final screenSize = MediaQuery.sizeOf(context);
    return Offset(screenSize.width / 2, screenSize.height - 36);
  }

  Rect? _globalRectFor(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  /// 実施中カードのスキップ：skipped として履歴に保存し、実施中を解除して再抽選する。
  Future<void> _onSkipOngoing(Suggestion suggestion) async {
    _settings = _flowService.appendRecentSuggestionId(_settings, suggestion.id);
    unawaited(
      _flowService.saveRecord(
        suggestion,
        status: SuggestionRecordStatus.skipped,
        feedback: null,
      ),
    );
    await _clearOngoing();
  }

  /// 実施中状態を解除し、通常の提案表示（再抽選）に戻す。
  Future<void> _clearOngoing() async {
    await _flowService.clearOngoing();
    if (!mounted) {
      return;
    }
    setState(() {
      _ongoingSuggestion = null;
      _ongoingStartedAt = null;
      _drawSuggestion();
    });
  }

  /// スキップして次の提案：表示中の提案を skipped として保存し、同条件で再抽選する。
  void _onSkipAndDrawAnother() {
    if (_currentSuggestion case final Suggestion suggestion) {
      _settings = _flowService.appendRecentSuggestionId(
        _settings,
        suggestion.id,
      );
      unawaited(
        _flowService.saveRecord(
          suggestion,
          status: SuggestionRecordStatus.skipped,
          feedback: null,
        ),
      );
    }
    setState(_drawSuggestion);
  }

  /// 条件カードのカテゴリチップ：選択を切り替えて即保存し、その場で再抽選する
  /// （issue #149）。提案設定画面を開かずに絞り込みを変えられるようにする。
  Future<void> _onToggleCategory(String categoryId) async {
    final selectedIds = _settings.selectedCategories.toSet();
    if (selectedIds.contains(categoryId)) {
      // 提案設定画面と同じく、カテゴリは 1 件以上必須（issue #50）。
      if (selectedIds.length == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カテゴリは1つ以上選んでください')),
        );
        return;
      }
      selectedIds.remove(categoryId);
    } else {
      selectedIds.add(categoryId);
    }

    // マスター定義の順序に揃え、表示順と保存順を一致させる（提案設定画面と同じ扱い）。
    // `all` にない発展カテゴリの選択は、この画面で消さずに末尾へ残す。
    // 詳細設定は選択を外したカテゴリの分も残し、選び直したときに元の絞り込みへ戻す。
    final coreCategoryIds = [
      for (final category in InterestCategories.all)
        if (selectedIds.contains(category.id)) category.id,
    ];
    final updatedSettings = _settings.copyWith(
      selectedCategories: [
        ...coreCategoryIds,
        for (final id in selectedIds)
          if (!coreCategoryIds.contains(id)) id,
      ],
    );
    setState(() {
      _settings = updatedSettings;
      _drawSuggestion();
    });
    await _settingsRepository.saveSettings(updatedSettings);
  }

  Future<void> _openSuggestionSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SuggestionSettingsPage(settingsRepository: _settingsRepository),
      ),
    );
    if (!mounted) {
      return;
    }
    // 保存の有無にかかわらず設定を読み直し、最新の条件で再抽選する。
    final settings = await _settingsRepository.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
      _drawSuggestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case _LoadStatus.error:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('データの読み込みに失敗しました。再起動してください。'),
          ),
        );
      case _LoadStatus.loaded:
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'よりみち日和',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('空いた時間に、小さなよりみちを。', style: TextStyle(fontSize: 14)),
            const _HeaderDivider(),
            if (_ongoingSuggestion case final Suggestion ongoing)
              _OngoingCard(
                suggestion: ongoing,
                startedAt: _ongoingStartedAt,
                cardKey: _ongoingCardKey,
                onComplete: () => _onCompleteOngoing(ongoing),
                onSkip: () => _onSkipOngoing(ongoing),
              )
            else if (_currentSuggestion case final Suggestion suggestion)
              _SuggestionCard(
                suggestion: suggestion,
                onTry: () => _onTrySuggestion(suggestion),
                onSkip: _onSkipAndDrawAnother,
              )
            else
              _EmptyCard(
                isCategoryEmpty: _settings.selectedCategories.isEmpty,
                onOpenSettings: _openSuggestionSettings,
              ),
            const SizedBox(height: 12),
            _ConditionCard(
              settings: _settings,
              onToggleCategory: _onToggleCategory,
              onOpenSettings: _openSuggestionSettings,
            ),
            const SizedBox(height: 16),
            const SectionCard(
              title: '使い方',
              description:
                  'カテゴリは条件カードのチップをタップすると、その場で切り替わります。詳細設定は「変更」から調整できます。通知をタップすると、保存した条件のよりみちが表示されます。',
            ),
          ],
        );
    }
  }
}

/// 見出しと「今日のよりみち」カードの間に置く区切り装飾。
/// 中央の葉アイコンと、両側へ薄れていく緑の線で、案内の始まりを区切る。
class _HeaderDivider extends StatelessWidget {
  const _HeaderDivider();

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: _FadingLine(color: lineColor, fadeToStart: true)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.eco_rounded, size: 18, color: lineColor),
          ),
          Expanded(child: _FadingLine(color: lineColor, fadeToStart: false)),
        ],
      ),
    );
  }
}

/// 片側へ向かって透明になっていく細線。[fadeToStart] が true なら左端が透明。
class _FadingLine extends StatelessWidget {
  const _FadingLine({required this.color, required this.fadeToStart});

  final Color color;
  final bool fadeToStart;

  @override
  Widget build(BuildContext context) {
    final gradientColors = <Color>[
      color.withValues(alpha: 0),
      color.withValues(alpha: 0.45),
    ];
    return Container(
      height: 1.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        gradient: LinearGradient(
          colors: fadeToStart
              ? gradientColors
              : gradientColors.reversed.toList(),
        ),
      ),
    );
  }
}

/// 現在の提案条件カード：カテゴリのチップ＋有効な詳細設定の要約。
/// チップは全カテゴリを並べ、タップでその場で絞り込みを切り替える（issue #149）。
/// 選択肢の多い詳細設定は、要約の右の「変更 >」から提案設定画面で編集する。
class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.settings,
    required this.onToggleCategory,
    required this.onOpenSettings,
  });

  final UserSettings settings;
  final ValueChanged<String> onToggleCategory;
  final VoidCallback onOpenSettings;

  /// 有効な詳細設定の選択値を「／」で連結した要約（例：ジャズ／作業向け）。
  String _buildDetailSummary() {
    final selectedValues = <String>[];
    for (final categoryId in settings.selectedCategories) {
      final groups = settings.detailSettings[categoryId];
      if (groups == null) {
        continue;
      }
      for (final values in groups.values) {
        selectedValues.addAll(values);
      }
    }
    return selectedValues.join('／');
  }

  /// チップとして並べるカテゴリ。MVP のコアカテゴリに加え、`all` に含まれない
  /// 選択中カテゴリ（発展カテゴリや旧データ）も末尾に足し、外せなくならないようにする。
  List<InterestCategory> _buildChipCategories() {
    return [
      ...InterestCategories.all,
      for (final categoryId in settings.selectedCategories)
        if (InterestCategories.findById(categoryId)
            case final InterestCategory category
            when !InterestCategories.all.any(
              (coreCategory) => coreCategory.id == categoryId,
            ))
          category,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryIds = settings.selectedCategories.toSet();
    final chipCategories = _buildChipCategories();
    final detailSummary = _buildDetailSummary();

    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  // 文字サイズ拡大時に折り返せるよう、タイトル側を可変幅にする。
                  const Expanded(
                    child: Text(
                      '現在の提案条件',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedCategoryIds.isNotEmpty)
                    Text(
                      '${selectedCategoryIds.length}つ選択中',
                      style: const TextStyle(fontSize: 13),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in chipCategories)
                    NeumorphicChipFrame(
                      isSelected: selectedCategoryIds.contains(category.id),
                      child: FilterChip(
                        label: Text('${category.emoji} ${category.label}'),
                        selected: selectedCategoryIds.contains(category.id),
                        onSelected: (_) => onToggleCategory(category.id),
                      ),
                    ),
                ],
              ),
            ),
            if (selectedCategoryIds.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12, right: 12),
                child: Text('カテゴリが選ばれていません'),
              ),
            Row(
              children: [
                // 詳細設定の値は長くなりうるため、要約側を可変幅にして折り返す。
                Expanded(
                  child: Text(
                    detailSummary.isEmpty
                        ? '詳細設定：すべてのジャンルから'
                        : '詳細設定：$detailSummary',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: onOpenSettings,
                  child: const Text('変更 >'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 今日のよりみちカード。
class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.onTry,
    required this.onSkip,
  });

  final Suggestion suggestion;
  final VoidCallback onTry;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return NeumorphicSurface(
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SuggestionCardContent(
              key: ValueKey<String>(suggestion.id),
              headerLabel: '今日のよりみち',
              title: suggestion.title,
              description: suggestion.description,
              recipe: suggestion.recipe,
              tags: suggestion.tags,
              estimatedMinutes: suggestion.estimatedMinutes,
              whereToTry: suggestion.whereToTry,
            ),
            const SizedBox(height: 16),
            _CardActionButtons(
              primaryButtonKey: const ValueKey<String>(
                'suggestion-primary-action',
              ),
              primaryIcon: Icons.play_arrow_rounded,
              primaryLabel: 'やってみる',
              onPrimaryPressed: onTry,
              secondaryButtonKey: const ValueKey<String>(
                'suggestion-secondary-action',
              ),
              secondaryIcon: Icons.skip_next_rounded,
              secondaryLabel: 'スキップして次の提案',
              onSecondaryPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

/// 実施中カード（issue #48）：完了／スキップの2ボタンで、開始時刻を添える。
class _OngoingCard extends StatelessWidget {
  const _OngoingCard({
    required this.suggestion,
    required this.startedAt,
    required this.cardKey,
    required this.onComplete,
    required this.onSkip,
  });

  final Suggestion suggestion;
  final DateTime? startedAt;

  /// 完了演出の飛行元座標を測るためのキー（page 側が保持する）。
  final GlobalKey cardKey;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final startedAt = this.startedAt;

    return NeumorphicSurface(
      key: cardKey,
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SuggestionCardContent(
              headerIcon: Icons.directions_walk,
              headerLabel: '実施中のよりみち',
              title: suggestion.title,
              description: suggestion.description,
              recipe: suggestion.recipe,
              tags: suggestion.tags,
              estimatedMinutes: suggestion.estimatedMinutes,
              whereToTry: suggestion.whereToTry,
              footnote: startedAt == null
                  ? null
                  : Text(
                      '開始：${HourMinute.fromDateTime(startedAt).format()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            _CardActionButtons(
              primaryButtonKey: const ValueKey<String>(
                'ongoing-primary-action',
              ),
              primaryIcon: Icons.check_rounded,
              primaryLabel: '完了',
              onPrimaryPressed: onComplete,
              secondaryButtonKey: const ValueKey<String>(
                'ongoing-secondary-action',
              ),
              secondaryIcon: Icons.skip_next_rounded,
              secondaryLabel: 'スキップ',
              onSecondaryPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

/// カード内の主操作を強調し、副操作は大きなタップ領域を保ったまま控えめにする。
class _CardActionButtons extends StatelessWidget {
  const _CardActionButtons({
    required this.primaryButtonKey,
    required this.primaryIcon,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.secondaryButtonKey,
    required this.secondaryIcon,
    required this.secondaryLabel,
    required this.onSecondaryPressed,
  });

  final Key primaryButtonKey;
  final IconData primaryIcon;
  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final Key secondaryButtonKey;
  final IconData secondaryIcon;
  final String secondaryLabel;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: NeumorphicButtonFrame(
            isPrimary: true,
            child: FilledButton.icon(
              key: primaryButtonKey,
              onPressed: onPrimaryPressed,
              icon: Icon(primaryIcon),
              label: Text(
                primaryLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 48,
          child: TextButton.icon(
            key: secondaryButtonKey,
            onPressed: onSecondaryPressed,
            icon: Icon(secondaryIcon),
            label: Text(secondaryLabel),
          ),
        ),
      ],
    );
  }
}

/// 候補なし時のカード（仕様書 6.3）。条件の自動緩和は行わない。
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.isCategoryEmpty,
    required this.onOpenSettings,
  });

  final bool isCategoryEmpty;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCategoryEmpty ? 'カテゴリが選ばれていません' : '条件に合う提案が見つかりませんでした',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isCategoryEmpty
                  ? '提案設定から、興味のあるカテゴリを選んでみてください。'
                  : 'カテゴリを増やすか、詳細設定を緩めてみてください。',
            ),
            const SizedBox(height: 16),
            NeumorphicButtonFrame(
              isPrimary: true,
              child: FilledButton(
                onPressed: onOpenSettings,
                child: const Text('提案設定を開く'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
