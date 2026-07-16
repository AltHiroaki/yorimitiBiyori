import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../features/recommendation/suggestion_picker.dart';
import '../models/interest_category.dart';
import '../models/ongoing_suggestion.dart';
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
import '../widgets/section_card.dart';
import 'suggestion_settings_page.dart';

enum _LoadStatus { loading, loaded, error }

/// 提案タブ（トップ画面）。仕様書 3.1 に対応する。
/// 現在の提案条件カードと「今日のよりみち」カードを表示し、
/// 「別の提案」で再抽選、「提案設定 >」で提案設定画面へ遷移する。
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
  late final SuggestionRepository _suggestionRepository;
  late final SettingsRepository _settingsRepository;
  late final RecordsRepository _recordsRepository;
  late final CurrentSuggestionRepository _currentSuggestionRepository;
  late final OngoingSuggestionRepository _ongoingSuggestionRepository;
  late final Random _random;

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
    _suggestionRepository =
        widget.suggestionRepository ?? SuggestionRepository();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _recordsRepository = widget.recordsRepository ?? RecordsRepository();
    _currentSuggestionRepository =
        widget.currentSuggestionRepository ?? CurrentSuggestionRepository();
    _ongoingSuggestionRepository =
        widget.ongoingSuggestionRepository ?? OngoingSuggestionRepository();
    _random = widget.random ?? Random();
    _initialize();
  }

  Future<void> _initialize() async {
    // 設定の読込は repository 側でデフォルトへフォールバックするため失敗しない。
    // エラー扱いにするのは提案データ（suggestions.json）の読込失敗のみ。
    final settings = await _settingsRepository.loadSettings();
    final currentSuggestionId =
        await _currentSuggestionRepository.loadCurrentSuggestionId();
    final ongoing = await _ongoingSuggestionRepository.loadOngoingSuggestion();
    try {
      final suggestions = await _suggestionRepository.loadSuggestions();
      if (!mounted) {
        return;
      }
      final ongoingSuggestion = _resolveOngoingSuggestion(
        suggestions: suggestions,
        ongoing: ongoing,
      );
      final restoredSuggestion = _restoreCurrentSuggestion(
        suggestions: suggestions,
        settings: settings,
        suggestionId: currentSuggestionId,
      );
      setState(() {
        _allSuggestions = suggestions;
        _settings = settings;
        _status = _LoadStatus.loaded;
        if (ongoingSuggestion != null) {
          _ongoingSuggestion = ongoingSuggestion;
          _ongoingStartedAt = ongoing!.startedAt;
        }
        if (restoredSuggestion == null) {
          _drawSuggestion();
        } else {
          _setCurrentSuggestion(restoredSuggestion);
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

  /// 保存済みの実施中よりみちを提案データから引き直す。
  /// 提案データの更新で ID が消えていた場合は実施中を解除する（null を返す）。
  Suggestion? _resolveOngoingSuggestion({
    required List<Suggestion> suggestions,
    required OngoingSuggestion? ongoing,
  }) {
    if (ongoing == null) {
      return null;
    }

    for (final suggestion in suggestions) {
      if (suggestion.id == ongoing.suggestionId) {
        return suggestion;
      }
    }
    // 該当データが存在しないため、保存済みの実施中状態も片付ける。
    unawaited(
      _ongoingSuggestionRepository.clearOngoingSuggestion().catchError((_) {}),
    );
    return null;
  }

  /// 現在の設定で候補を絞り込み、weight 付きランダムで 1 件選ぶ。
  void _drawSuggestion() {
    final candidates = excludeRecent(
      filterSuggestions(_allSuggestions, _settings),
      _settings.recentSuggestionIds,
    );
    final picked = pickWeightedRandom(candidates, _random);
    _setCurrentSuggestion(picked);
  }

  Suggestion? _restoreCurrentSuggestion({
    required List<Suggestion> suggestions,
    required UserSettings settings,
    required String? suggestionId,
  }) {
    if (suggestionId == null) {
      return null;
    }

    final matchedSuggestions = filterSuggestions(suggestions, settings);
    for (final suggestion in matchedSuggestions) {
      if (suggestion.id == suggestionId) {
        return suggestion;
      }
    }
    return null;
  }

  void _setCurrentSuggestion(Suggestion? suggestion) {
    _currentSuggestion = suggestion;
    if (suggestion == null) {
      unawaited(
        _currentSuggestionRepository.clearCurrentSuggestion().catchError(
              (_) {},
            ),
      );
      return;
    }

    unawaited(
      _currentSuggestionRepository
          .saveCurrentSuggestionId(suggestion.id)
          .catchError((_) {}),
    );
  }

  /// 表示した提案 ID を直近リストへ追加する（重複は寄せ、3件を超えたら古い順に削除）。
  /// 永続化の失敗で UI を止めないため、保存は待たずに実行する。
  void _recordRecent(String suggestionId) {
    final recentIds = [
      for (final id in _settings.recentSuggestionIds)
        if (id != suggestionId) id,
      suggestionId,
    ];
    if (recentIds.length > recentSuggestionLimit) {
      recentIds.removeRange(0, recentIds.length - recentSuggestionLimit);
    }
    _settings = _settings.copyWith(recentSuggestionIds: recentIds);
    unawaited(
      _settingsRepository.saveSettings(_settings).catchError((_) {}),
    );
  }

  /// やってみる：提案を実施中状態に切り替える（issue #48）。
  /// 実施中はタブ切替・アプリ再起動でも維持されるよう永続化する。
  void _onTrySuggestion(Suggestion suggestion) {
    final startedAt = DateTime.now();
    setState(() {
      _ongoingSuggestion = suggestion;
      _ongoingStartedAt = startedAt;
    });
    unawaited(
      _ongoingSuggestionRepository
          .saveOngoingSuggestion(
            OngoingSuggestion(
              suggestionId: suggestion.id,
              startedAt: startedAt,
            ),
          )
          .catchError((_) {}),
    );
  }

  /// 実施中カードの完了：フィードバックを聞いて done として履歴に保存し、
  /// お祝いを表示して履歴タブへ移る。モーダルを閉じただけなら実施中のまま。
  /// 保存の成否表示・保存中のボタン無効化はモーダル側が担う（issue #44）。
  Future<void> _onCompleteOngoing(Suggestion suggestion) async {
    final completedRecordId =
        'record_${DateTime.now().microsecondsSinceEpoch}';
    final saved = await showCompletionModal(
      context,
      onSave: (feedback) => _saveRecord(
        suggestion,
        status: SuggestionRecordStatus.done,
        feedback: feedback,
        recordId: completedRecordId,
      ),
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
    _recordRecent(suggestion.id);
    unawaited(
      _saveRecord(
        suggestion,
        status: SuggestionRecordStatus.skipped,
        feedback: null,
        updateRecent: false,
      ),
    );
    await _clearOngoing();
  }

  /// 実施中状態を解除し、通常の提案表示（再抽選）に戻す。
  Future<void> _clearOngoing() async {
    await _ongoingSuggestionRepository
        .clearOngoingSuggestion()
        .catchError((_) {});
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
      _recordRecent(suggestion.id);
      unawaited(
        _saveRecord(
          suggestion,
          status: SuggestionRecordStatus.skipped,
          feedback: null,
          updateRecent: false,
        ),
      );
    }
    setState(_drawSuggestion);
  }

  /// 表示中の提案から履歴レコードを組み立てて保存する。
  /// タイトル等は提案データ更新後も履歴表示が壊れないよう非正規化して保持する。
  Future<void> _saveRecord(
    Suggestion suggestion, {
    required SuggestionRecordStatus status,
    required SuggestionFeedback? feedback,
    bool updateRecent = true,
    String? recordId,
  }) async {
    final now = DateTime.now();
    final record = SuggestionRecord(
      id: recordId ?? 'record_${now.microsecondsSinceEpoch}',
      suggestionId: suggestion.id,
      suggestionTitle: suggestion.title,
      category: suggestion.category,
      estimatedMinutes: suggestion.estimatedMinutes,
      status: status,
      feedback: feedback,
      createdAt: now,
    );
    await _recordsRepository.addRecord(record);
    if (updateRecent) {
      _recordRecent(suggestion.id);
    }
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
            const Text(
              '空いた時間に、小さなよりみちを。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildConditionCard(),
            const SizedBox(height: 12),
            if (_ongoingSuggestion case final Suggestion ongoing)
              _buildOngoingCard(ongoing)
            else if (_currentSuggestion case final Suggestion suggestion)
              _buildSuggestionCard(suggestion)
            else
              _buildEmptyCard(),
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

  /// 現在の提案条件カード：選択カテゴリのチップ＋有効な詳細設定の要約。
  Widget _buildConditionCard() {
    final selectedCategories = <InterestCategory>[
      for (final categoryId in _settings.selectedCategories)
        if (InterestCategories.findById(categoryId) case final InterestCategory
            category)
          category,
    ];
    final detailSummary = _buildDetailSummary();

    return Card(
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
                  onPressed: _openSuggestionSettings,
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
                    Chip(label: Text('${category.emoji} ${category.label}')),
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

  /// 実施中カードに表示する「HH:mm」形式の開始時刻。
  String _formatStartTime(DateTime startedAt) {
    final hour = startedAt.hour.toString().padLeft(2, '0');
    final minute = startedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 有効な詳細設定の選択値を「／」で連結した要約（例：ジャズ／作業向け）。
  String _buildDetailSummary() {
    final selectedValues = <String>[];
    for (final categoryId in _settings.selectedCategories) {
      final groups = _settings.detailSettings[categoryId];
      if (groups == null) {
        continue;
      }
      for (final values in groups.values) {
        selectedValues.addAll(values);
      }
    }
    return selectedValues.join('／');
  }

  /// 今日のよりみちカード。
  Widget _buildSuggestionCard(Suggestion suggestion) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
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
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(suggestion.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in suggestion.tags) Chip(label: Text(tag)),
                Chip(label: Text('約${suggestion.estimatedMinutes}分')),
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
                  child: FilledButton(
                    onPressed: () => _onTrySuggestion(suggestion),
                    child: const Text('やってみる'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _onAnotherSuggestion,
                    child: const Text('別の提案'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 実施中カード（issue #48）：完了／スキップの2ボタンで、開始時刻を添える。
  Widget _buildOngoingCard(Suggestion suggestion) {
    final colorScheme = Theme.of(context).colorScheme;
    final startedAt = _ongoingStartedAt;

    return Card(
      key: _ongoingCardKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_walk, size: 18, color: colorScheme.primary),
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
                '開始：${_formatStartTime(startedAt)}',
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
                    onPressed: () => _onCompleteOngoing(suggestion),
                    child: const Text('完了'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onSkipOngoing(suggestion),
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

  /// 候補なし時のカード（仕様書 6.3）。条件の自動緩和は行わない。
  Widget _buildEmptyCard() {
    final isCategoryEmpty = _settings.selectedCategories.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isCategoryEmpty ? 'カテゴリが選ばれていません' : '条件に合う提案が見つかりませんでした',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isCategoryEmpty
                  ? '提案設定から、興味のあるカテゴリを選んでみてください。'
                  : 'カテゴリを増やすか、詳細設定を緩めてみてください。',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _openSuggestionSettings,
              child: const Text('提案設定を開く'),
            ),
          ],
        ),
      ),
    );
  }
}
