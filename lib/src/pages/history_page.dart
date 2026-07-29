import 'package:flutter/material.dart';

import '../features/records/history_filter.dart';
import '../features/records/record_duration.dart';
import '../features/records/record_summary.dart';
import '../models/interest_category.dart';
import '../models/ongoing_suggestion.dart';
import '../models/suggestion.dart';
import '../models/suggestion_record.dart';
import '../repositories/ongoing_suggestion_repository.dart';
import '../repositories/records_repository.dart';
import '../repositories/suggestion_repository.dart';
import '../widgets/history_record_modals.dart';
import '../widgets/neumorphic_surface.dart';

const Duration historyNewRecordHighlightDuration = Duration(milliseconds: 1500);
const Key historyThisWeekSegmentKey = ValueKey<String>(
  'history-period-this-week',
);
const Key historyAllPeriodSegmentKey = ValueKey<String>('history-period-all');
const Key historyAllStatusFilterKey = ValueKey<String>('history-status-all');
const Key historyDoneStatusFilterKey = ValueKey<String>('history-status-done');
const Key historySkippedStatusFilterKey = ValueKey<String>(
  'history-status-skipped',
);

/// 履歴タブ。仕様書 3.2 に対応する。
/// 今週／全期間とステータスで履歴を絞り込み、期間連動サマリーと
/// 新しい順の一覧を表示する。全体 0 件と絞り込み 0 件は別の空状態にする。
class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    this.recordsRepository,
    this.suggestionRepository,
    this.ongoingSuggestionRepository,
    this.onGoToSuggestions,
    this.onSuggestionRevived,
    this.highlightedRecordId,
    this.isActive = true,
    this.nowProvider,
  });

  /// テスト用に差し替え可能。null なら通常の repository を使う。
  final RecordsRepository? recordsRepository;
  final SuggestionRepository? suggestionRepository;
  final OngoingSuggestionRepository? ongoingSuggestionRepository;

  /// 空状態の「提案を見てみる」で提案タブへ切り替えるためのコールバック。
  final VoidCallback? onGoToSuggestions;

  /// スキップした提案を実施中に戻した後、提案タブへ切り替える。
  final VoidCallback? onSuggestionRevived;

  /// 完了フローで保存した直後に背景色を強調する履歴 ID。
  final String? highlightedRecordId;

  /// 履歴タブとして表示が確定しているか。`PageView` は横スワイプを始めた時点で
  /// 隣のページも build するため、false の間は読み込みを走らせない。
  /// false → true になったタイミングで読み込む（`AppShell` が `onPageChanged`
  /// 基準で切り替える）。単体で使うときは常に読み込む。
  final bool isActive;

  /// 期間判定に使う現在時刻。テストでは固定時刻へ差し替えられる。
  final DateTime Function()? nowProvider;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final RecordsRepository _recordsRepository;
  late final SuggestionRepository _suggestionRepository;
  late final OngoingSuggestionRepository _ongoingSuggestionRepository;

  bool _isLoading = true;
  bool _isRecordDialogOpen = false;
  List<SuggestionRecord> _allRecords = const [];
  List<SuggestionRecord> _visibleRecords = const [];
  RecordSummary _summary = summarizeRecords(const []);
  HistoryPeriod _selectedPeriod = HistoryPeriod.thisWeek;
  HistoryStatusFilter _selectedStatus = HistoryStatusFilter.all;
  String? _handledHighlightedRecordId;

  @override
  void initState() {
    super.initState();
    _recordsRepository = widget.recordsRepository ?? RecordsRepository();
    _suggestionRepository =
        widget.suggestionRepository ?? SuggestionRepository();
    _ongoingSuggestionRepository =
        widget.ongoingSuggestionRepository ?? OngoingSuggestionRepository();
    if (widget.isActive) {
      _loadRecords();
    }
  }

  @override
  void didUpdateWidget(HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // スワイプが履歴タブへ確定した時点で読み込む。途中でやめた場合は
    // isActive が false のままなので、無駄な読み込みは起きない。
    final becameActive = widget.isActive && !oldWidget.isActive;
    final highlightedRecordChanged =
        widget.highlightedRecordId != oldWidget.highlightedRecordId;
    if (widget.isActive && (becameActive || highlightedRecordChanged)) {
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    // 壊れた保存データは repository 側で空リストへフォールバックするため失敗しない。
    final records = await _recordsRepository.loadRecords();
    if (!mounted) {
      return;
    }
    final now = _currentTime();
    setState(() {
      _allRecords = sortRecordsByNewest(records);
      _adjustFiltersForHighlightedRecord(now);
      _rebuildFilteredRecords(now);
      _isLoading = false;
    });
  }

  DateTime _currentTime() {
    return widget.nowProvider?.call() ?? DateTime.now();
  }

  void _adjustFiltersForHighlightedRecord(DateTime now) {
    final highlightedRecordId = widget.highlightedRecordId;
    if (highlightedRecordId == null ||
        highlightedRecordId == _handledHighlightedRecordId) {
      return;
    }

    SuggestionRecord? highlightedRecord;
    for (final record in _allRecords) {
      if (record.id == highlightedRecordId) {
        highlightedRecord = record;
        break;
      }
    }
    if (highlightedRecord == null) {
      return;
    }

    _selectedStatus = HistoryStatusFilter.all;
    _selectedPeriod =
        isRecordInHistoryPeriod(
          highlightedRecord,
          period: HistoryPeriod.thisWeek,
          now: now,
        )
        ? HistoryPeriod.thisWeek
        : HistoryPeriod.all;
    _handledHighlightedRecordId = highlightedRecordId;
  }

  void _rebuildFilteredRecords(DateTime now) {
    final periodRecords = filterRecordsByPeriod(
      _allRecords,
      period: _selectedPeriod,
      now: now,
    );
    _summary = summarizeRecords(periodRecords);
    _visibleRecords = sortRecordsByNewest(
      filterRecordsByStatus(periodRecords, statusFilter: _selectedStatus),
    );
  }

  void _selectPeriod(HistoryPeriod period) {
    if (_selectedPeriod == period) {
      return;
    }
    setState(() {
      _selectedPeriod = period;
      _rebuildFilteredRecords(_currentTime());
    });
  }

  void _selectStatus(HistoryStatusFilter status) {
    if (_selectedStatus == status) {
      return;
    }
    setState(() {
      _selectedStatus = status;
      _rebuildFilteredRecords(_currentTime());
    });
  }

  /// 履歴行タップの入口。実施済みは内容の閲覧ダイアログ、
  /// スキップは復活フロー（詳細 → 確認 → 実施中へ保存）を開く。
  Future<void> _openRecordDetail(SuggestionRecord record) async {
    if (_isRecordDialogOpen) {
      return;
    }

    final isDone = record.status == SuggestionRecordStatus.done;
    setState(() {
      _isRecordDialogOpen = true;
    });
    try {
      final suggestions = await _suggestionRepository.loadSuggestions();
      if (!mounted) {
        return;
      }
      final suggestion = _findSuggestionById(suggestions, record.suggestionId);
      if (suggestion == null) {
        await showReviveSuggestionUnavailableDialog(context: context);
        return;
      }

      if (isDone) {
        await showDoneSuggestionRecordDetailDialog(
          context: context,
          suggestion: suggestion,
          record: record,
        );
        return;
      }

      await _continueReviveFlow(suggestion, record);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isDone
                  ? '履歴の内容を表示できませんでした。もう一度お試しください。'
                  : '提案を復活できませんでした。もう一度お試しください。',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecordDialogOpen = false;
        });
      }
    }
  }

  /// スキップした提案の復活フロー後半：詳細 → 確認 → 実施中として保存。
  Future<void> _continueReviveFlow(
    Suggestion suggestion,
    SuggestionRecord record,
  ) async {
    final shouldTry = await showReviveSuggestionDetailDialog(
      context: context,
      suggestion: suggestion,
    );
    if (!mounted || !shouldTry) {
      return;
    }

    final ongoingSuggestion = await _ongoingSuggestionRepository
        .loadOngoingSuggestion();
    if (!mounted) {
      return;
    }
    final shouldRevive = await showReviveSuggestionConfirmDialog(
      context: context,
      suggestion: suggestion,
      hasOngoingSuggestion: ongoingSuggestion != null,
    );
    if (!mounted || !shouldRevive) {
      return;
    }

    // 復活元のスキップ履歴 ID を添えて保存し、完了時にその1件を削除できるようにする。
    await _ongoingSuggestionRepository.saveOngoingSuggestion(
      OngoingSuggestion(
        suggestionId: suggestion.id,
        startedAt: DateTime.now().toUtc(),
        revivedFromRecordId: record.id,
      ),
    );
    if (!mounted) {
      return;
    }
    widget.onSuggestionRevived?.call();
  }

  Suggestion? _findSuggestionById(
    List<Suggestion> suggestions,
    String suggestionId,
  ) {
    for (final suggestion in suggestions) {
      if (suggestion.id == suggestionId) {
        return suggestion;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          '履歴',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('実施したよりみちと、スキップした提案を確認します。', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 16),
        _buildPeriodSelector(),
        const SizedBox(height: 16),
        _buildSummaryCard(),
        const SizedBox(height: 24),
        _buildStatusFilters(),
        const SizedBox(height: 24),
        if (_allRecords.isEmpty)
          _buildEmptyState()
        else if (_visibleRecords.isEmpty)
          _buildFilteredEmptyState()
        else ...[
          Text(
            _selectedPeriod == HistoryPeriod.thisWeek ? '今週の履歴' : '最近の履歴',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final record in _visibleRecords) ...[
            _buildRecordRow(record),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '期間',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: NeumorphicRecessedSurface(
            child: SegmentedButton<HistoryPeriod>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: HistoryPeriod.thisWeek,
                  label: Text('今週', key: historyThisWeekSegmentKey),
                ),
                ButtonSegment(
                  value: HistoryPeriod.all,
                  label: Text('全期間', key: historyAllPeriodSegmentKey),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (selection) {
                _selectPeriod(selection.first);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ステータス',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildStatusFilterChip(
              key: historyAllStatusFilterKey,
              status: HistoryStatusFilter.all,
              label: 'すべて',
            ),
            _buildStatusFilterChip(
              key: historyDoneStatusFilterKey,
              status: HistoryStatusFilter.done,
              label: '実施',
            ),
            _buildStatusFilterChip(
              key: historySkippedStatusFilterKey,
              status: HistoryStatusFilter.skipped,
              label: 'スキップ',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilterChip({
    required Key key,
    required HistoryStatusFilter status,
    required String label,
  }) {
    final isSelected = _selectedStatus == status;
    return NeumorphicChipFrame(
      isSelected: isSelected,
      child: FilterChip(
        key: key,
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _selectStatus(status),
      ),
    );
  }

  /// サマリーカード：実施数（緑）／スキップ数（黄）／合計時間・分の3分割。
  Widget _buildSummaryCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                _buildSummaryItem(
                  value: '${_summary.doneCount}',
                  label: '実施',
                  valueColor: colorScheme.primary,
                ),
                const SizedBox(height: 48, child: VerticalDivider(width: 1)),
                _buildSummaryItem(
                  value: '${_summary.skippedCount}',
                  label: 'スキップ',
                  valueColor: colorScheme.tertiary,
                ),
                const SizedBox(height: 48, child: VerticalDivider(width: 1)),
                _buildSummaryItem(
                  value: '${_summary.totalDoneMinutes}',
                  label: '分',
                  valueColor: colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '実測を優先し、記録がない場合は目安で集計',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// 履歴 1 行：ステータスアイコン・タイトル・日付とカテゴリ・所要時間・バッジ。
  Widget _buildRecordRow(SuggestionRecord record) {
    if (record.id != widget.highlightedRecordId) {
      return _buildRecordCard(record);
    }

    final theme = Theme.of(context);
    final normalCardColor =
        theme.cardTheme.color ?? theme.colorScheme.surfaceContainerLow;
    return TweenAnimationBuilder<double>(
      duration: historyNewRecordHighlightDuration,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, progress, _) {
        final backgroundColor = Color.lerp(
          theme.colorScheme.primaryContainer,
          normalCardColor,
          progress,
        );
        return _buildRecordCard(record, backgroundColor: backgroundColor);
      },
    );
  }

  Widget _buildRecordCard(SuggestionRecord record, {Color? backgroundColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = record.status == SuggestionRecordStatus.done;
    final iconBackground = isDone
        ? colorScheme.primaryContainer
        : colorScheme.tertiaryContainer;
    final accentColor = isDone
        ? colorScheme.onPrimaryContainer
        : colorScheme.onTertiaryContainer;
    final categoryLabel =
        InterestCategories.findById(record.category)?.label ?? record.category;
    final duration = resolveRecordDuration(record);

    return NeumorphicSurface(
      key: ValueKey<String>('history-record-${record.id}'),
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        child: InkWell(
          onTap: _isRecordDialogOpen ? null : () => _openRecordDetail(record),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconBackground,
                  child: isDone
                      ? Icon(Icons.check, size: 18, color: accentColor)
                      : Text(
                          '−',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.suggestionTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatRecordDate(record.createdAt)}　'
                        '$categoryLabel・${duration.displayLabel}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeumorphicChipFrame(
                  isSelected: true,
                  backgroundColor: iconBackground,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      isDone ? '実施' : 'スキップ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 空状態：サマリーは 0 表示のまま、提案タブへの導線を出す（仕様書 3.2）。
  Widget _buildEmptyState() {
    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'まだ履歴はありません',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('よりみちを実行すると、ここに記録されます。'),
            const SizedBox(height: 16),
            NeumorphicButtonFrame(
              isPrimary: true,
              isEnabled: widget.onGoToSuggestions != null,
              child: FilledButton(
                onPressed: widget.onGoToSuggestions,
                child: const Text('提案を見てみる'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 保存済み履歴はあるが、選択した期間・ステータスでは0件のときの表示。
  Widget _buildFilteredEmptyState() {
    final hasStatusFilter = _selectedStatus != HistoryStatusFilter.all;
    final title = hasStatusFilter ? 'この条件の履歴はありません' : '今週の履歴はありません';
    final message = switch (_selectedStatus) {
      HistoryStatusFilter.done => '選択した期間に実施した履歴はありません。',
      HistoryStatusFilter.skipped => '選択した期間にスキップした履歴はありません。',
      HistoryStatusFilter.all => '全期間に切り替えると、以前の履歴を確認できます。',
    };
    final buttonLabel = hasStatusFilter ? 'すべて表示' : '全期間を見る';

    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 16),
            NeumorphicButtonFrame(
              child: OutlinedButton(
                onPressed: hasStatusFilter
                    ? () => _selectStatus(HistoryStatusFilter.all)
                    : () => _selectPeriod(HistoryPeriod.all),
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 「6月5日」形式の表示用日付（UI プロトタイプ準拠）。
String _formatRecordDate(DateTime dateTime) {
  return '${dateTime.month}月${dateTime.day}日';
}
