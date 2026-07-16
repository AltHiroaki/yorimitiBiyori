import 'package:flutter/material.dart';

import '../models/suggestion.dart';

/// スキップした提案の詳細を表示し、「やってみる」が押されたら true を返す。
Future<bool> showReviveSuggestionDetailDialog({
  required BuildContext context,
  required Suggestion suggestion,
}) async {
  final shouldTry = await showDialog<bool>(
    context: context,
    builder: (_) => _ReviveSuggestionDetailDialog(suggestion: suggestion),
  );
  return shouldTry ?? false;
}

/// 復活の最終確認を表示する。既存の実施中がある場合は置換を明示する。
Future<bool> showReviveSuggestionConfirmDialog({
  required BuildContext context,
  required Suggestion suggestion,
  required bool hasOngoingSuggestion,
}) async {
  final shouldRevive = await showDialog<bool>(
    context: context,
    builder: (context) {
      final replacementMessage = hasOngoingSuggestion
          ? '実施中の提案と置き換わります。\n'
          : '';
      return AlertDialog(
        title: const Text('この提案を実施しますか？'),
        content: Text(
          '$replacementMessage「${suggestion.title}」をもう一度実施します。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('実施する'),
          ),
        ],
      );
    },
  );
  return shouldRevive ?? false;
}

/// 履歴が参照する提案 ID が現在の提案データに存在しない場合に表示する。
Future<void> showReviveSuggestionUnavailableDialog({
  required BuildContext context,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('この提案は現在利用できません'),
        content: const Text('提案データの更新により、この提案は削除されました。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      );
    },
  );
}

class _ReviveSuggestionDetailDialog extends StatelessWidget {
  const _ReviveSuggestionDetailDialog({required this.suggestion});

  final Suggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final budgetLabel =
        suggestion.budgetYen == 0 ? '無料' : '¥${suggestion.budgetYen}';

    return Dialog(
      key: const ValueKey<String>('revive-suggestion-detail-dialog'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.replay),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'スキップした提案',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${suggestion.estimatedMinutes}分でできる',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '閉じる',
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                suggestion.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(suggestion.description),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in suggestion.tags) Chip(label: Text(tag)),
                  Chip(label: Text('約${suggestion.estimatedMinutes}分')),
                ],
              ),
              const SizedBox(height: 14),
              Text('入手先：${suggestion.whereToTry}'),
              const SizedBox(height: 4),
              Text('予算：$budgetLabel'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('やってみる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
