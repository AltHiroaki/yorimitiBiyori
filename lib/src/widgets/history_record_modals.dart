import 'package:flutter/material.dart';

import '../models/suggestion.dart';
import '../models/suggestion_record.dart';
import 'completion_modal.dart';
import 'suggestion_card_content.dart';

/// 実施した履歴の提案内容を表示する（閲覧のみ）。
Future<void> showDoneSuggestionRecordDetailDialog({
  required BuildContext context,
  required Suggestion suggestion,
  required SuggestionRecord record,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DoneSuggestionRecordDetailDialog(
      suggestion: suggestion,
      record: record,
    ),
  );
}

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

class _DoneSuggestionRecordDetailDialog extends StatelessWidget {
  const _DoneSuggestionRecordDetailDialog({
    required this.suggestion,
    required this.record,
  });

  final Suggestion suggestion;
  final SuggestionRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final feedback = record.feedback;

    return Dialog(
      key: const ValueKey<String>('done-record-detail-dialog'),
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
                    child: const Icon(Icons.check),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '実施したよりみち',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${record.createdAt.month}月'
                          '${record.createdAt.day}日に実施',
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // 復活ダイアログと同じ広めの余白でそろえる。
              // レシピは提案タブと同じ「詳しく見る／レシピを閉じる」で開閉する
              // （料理以外は recipe が null のため操作自体が出ない）。
              SuggestionCardContent(
                title: suggestion.title,
                titleMaxLines: null,
                description: suggestion.description,
                recipe: suggestion.recipe,
                tags: suggestion.tags,
                estimatedMinutes: suggestion.estimatedMinutes,
                footnote: feedback == null
                    ? null
                    : Text('感想：${feedbackDisplayLabel(feedback)}'),
                titleSpacing: 10,
                sectionSpacing: 14,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviveSuggestionDetailDialog extends StatelessWidget {
  const _ReviveSuggestionDetailDialog({required this.suggestion});

  final Suggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              // 既存の見た目を保つため、ダイアログはやや広めの余白を指定する。
              // タイトルはスクロールできるため折り返しを制限しない。
              SuggestionCardContent(
                title: suggestion.title,
                titleMaxLines: null,
                description: suggestion.description,
                tags: suggestion.tags,
                estimatedMinutes: suggestion.estimatedMinutes,
                titleSpacing: 10,
                sectionSpacing: 14,
              ),
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
