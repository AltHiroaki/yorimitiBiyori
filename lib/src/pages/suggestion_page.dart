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
import 'suggestion_settings_page.dart';

enum _LoadStatus { loading, loaded, error }

/// 提案タブ（トップ画面）。仕様書 3.1 に対応する。
/// 現在の提案条件カードと「今日のよりみち」カードを表示し、
/// 「別の提案」で再抽選、「提案設定 >」で提案設定画面へ遷移する。
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

  /// 別の提案：表示中の提案を skipped として履歴に保存し、同条件で再抽選する（仕様書 6.4）。
  void _onAnotherSuggestion() {
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
            const SizedBox(height: 16),
            _ConditionCard(
              settings: _settings,
              onOpenSettings: _openSuggestionSettings,
            ),
            const SizedBox(height: 12),
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
                onAnother: _onAnotherSuggestion,
              )
            else
              _EmptyCard(
                isCategoryEmpty: _settings.selectedCategories.isEmpty,
                onOpenSettings: _openSuggestionSettings,
              ),
            const SizedBox(height: 16),
            const SectionCard(
              title: '使い方',
              description:
                  'カテゴリと詳細設定を変えたいときは「提案設定」から調整できます。通知をタップすると、保存した条件のよりみちが表示されます。',
            ),
          ],
        );
    }
  }
}

/// 現在の提案条件カード：選択カテゴリのチップ＋有効な詳細設定の要約。
class _ConditionCard extends StatelessWidget {
  const _ConditionCard({
    required this.settings,
    required this.onOpenSettings,
  });

  final UserSettings settings;
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

  @override
  Widget build(BuildContext context) {
    final selectedCategories = <InterestCategory>[
      for (final categoryId in settings.selectedCategories)
        if (InterestCategories.findById(categoryId)
            case final InterestCategory category)
          category,
    ];
    final detailSummary = _buildDetailSummary();

    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 文字サイズ拡大時に折り返せるよう、タイトル側を可変幅にする。
                const Expanded(
                  child: Text(
                    '現在の提案条件',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: onOpenSettings,
                  child: const Text('提案設定 >'),
                ),
              ],
            ),
            if (selectedCategories.isEmpty)
              const Text('カテゴリが選ばれていません')
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in selectedCategories)
                    NeumorphicChipFrame(
                      child: Chip(
                        label: Text('${category.emoji} ${category.label}'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                detailSummary.isEmpty ? '詳細設定：指定なし' : '詳細設定：$detailSummary',
                style: const TextStyle(fontSize: 13),
              ),
            ],
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
    required this.onAnother,
  });

  final Suggestion suggestion;
  final VoidCallback onTry;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NeumorphicSurface(
      radius: 32,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日のよりみち',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(suggestion.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in suggestion.tags)
                  NeumorphicChipFrame(child: Chip(label: Text(tag))),
                NeumorphicChipFrame(
                  child: Chip(label: Text('約${suggestion.estimatedMinutes}分')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('入手先：${suggestion.whereToTry}'),
            const SizedBox(height: 4),
            Text(
              '予算：${suggestion.budgetYen == 0 ? '無料' : '¥${suggestion.budgetYen}'}',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NeumorphicButtonFrame(
                    isPrimary: true,
                    child: FilledButton(
                      onPressed: onTry,
                      child: const Text('やってみる'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeumorphicButtonFrame(
                    child: OutlinedButton(
                      onPressed: onAnother,
                      child: const Text('別の提案'),
                    ),
                  ),
                ),
              ],
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

    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_walk,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '実施中のよりみち',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(suggestion.description),
            const SizedBox(height: 12),
            Text('入手先：${suggestion.whereToTry}'),
            if (startedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                '開始：${HourMinute.fromDateTime(startedAt).format()}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onComplete,
                    child: const Text('完了'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text('スキップ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
