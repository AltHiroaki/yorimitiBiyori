import 'package:flutter/material.dart';

import '../features/records/record_summary.dart';
import '../models/interest_category.dart';
import '../models/ongoing_suggestion.dart';
import '../models/suggestion.dart';
import '../models/suggestion_record.dart';
import '../repositories/ongoing_suggestion_repository.dart';
import '../repositories/records_repository.dart';
import '../repositories/suggestion_repository.dart';
import '../widgets/revive_suggestion_modals.dart';

const Duration historyNewRecordHighlightDuration =
    Duration(milliseconds: 1500);

/// 履歴タブ。仕様書 3.2 に対応する。
/// サマリー（実施／スキップ／合計分）と新しい順の履歴一覧を表示し、
/// 履歴 0 件のときは空状態と「提案を見てみる」ボタンを表示する。
class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
    this.recordsRepository,
    this.suggestionRepository,
    this.ongoingSuggestionRepository,
    this.onGoToSuggestions,
    this.onSuggestionRevived,
    this.highlightedRecordId,
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

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final RecordsRepository _recordsRepository;
  late final SuggestionRepository _suggestionRepository;
  late final OngoingSuggestionRepository _ongoingSuggestionRepository;

  bool _isLoading = true;
  bool _isReviveFlowOpen = false;
  List<SuggestionRecord> _newestFirstRecords = const [];
  RecordSummary _summary = summarizeRecords(const []);

  @override
  void initState() {
    super.initState();
    _recordsRepository = widget.recordsRepository ?? RecordsRepository();
    _suggestionRepository =
        widget.suggestionRepository ?? SuggestionRepository();
    _ongoingSuggestionRepository =
        widget.ongoingSuggestionRepository ?? OngoingSuggestionRepository();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    // 壊れた保存データは repository 側で空リストへフォールバックするため失敗しない。
    final records = await _recordsRepository.loadRecords();
    if (!mounted) {
      return;
    }
    setState(() {
      _newestFirstRecords = sortRecordsByNewest(records);
      _summary = summarizeRecords(records);
      _isLoading = false;
    });
  }

  Future<void> _openReviveFlow(SuggestionRecord record) async {
    if (_isReviveFlowOpen ||
        record.status != SuggestionRecordStatus.skipped) {
      return;
    }

    setState(() {
      _isReviveFlowOpen = true;
    });
    try {
      final suggestions = await _suggestionRepository.loadSuggestions();
      if (!mounted) {
        return;
      }
      final suggestion = _findSuggestionById(
        suggestions,
        record.suggestionId,
      );
      if (suggestion == null) {
        await showReviveSuggestionUnavailableDialog(context: context);
        return;
      }

      final shouldTry = await showReviveSuggestionDetailDialog(
        context: context,
        suggestion: suggestion,
      );
      if (!mounted || !shouldTry) {
        return;
      }

      final ongoingSuggestion =
          await _ongoingSuggestionRepository.loadOngoingSuggestion();
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

      await _ongoingSuggestionRepository.saveOngoingSuggestion(
        OngoingSuggestion(
          suggestionId: suggestion.id,
          startedAt: DateTime.now(),
        ),
      );
      if (!mounted) {
        return;
      }
      widget.onSuggestionRevived?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('提案を復活できませんでした。もう一度お試しください。'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviveFlowOpen = false;
        });
      }
    }
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
        const Text(
          '実施したよりみちと、スキップした提案を確認します。',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(),
        const SizedBox(height: 24),
        if (_newestFirstRecords.isEmpty)
          _buildEmptyState()
        else ...[
          const Text(
            '最近の履歴',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final record in _newestFirstRecords) ...[
            _buildRecordRow(record),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }

  /// サマリーカード：実施数（緑）／スキップ数（黄）／合計時間・分の3分割。
  Widget _buildSummaryCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
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

  Widget _buildRecordCard(
    SuggestionRecord record, {
    Color? backgroundColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = record.status == SuggestionRecordStatus.done;
    final iconBackground =
        isDone ? colorScheme.primaryContainer : colorScheme.tertiaryContainer;
    final accentColor = isDone
        ? colorScheme.onPrimaryContainer
        : colorScheme.onTertiaryContainer;
    final categoryLabel =
        InterestCategories.findById(record.category)?.label ?? record.category;

    return Card(
      key: ValueKey<String>('history-record-${record.id}'),
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDone || _isReviveFlowOpen
            ? null
            : () => _openReviveFlow(record),
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
                      '$categoryLabel・${record.estimatedMinutes}分',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
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
              if (!isDone) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 空状態：サマリーは 0 表示のまま、提案タブへの導線を出す（仕様書 3.2）。
  Widget _buildEmptyState() {
    return Card(
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
            FilledButton(
              onPressed: widget.onGoToSuggestions,
              child: const Text('提案を見てみる'),
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
