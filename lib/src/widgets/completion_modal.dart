import 'package:flutter/material.dart';

import '../models/suggestion_record.dart';
import 'neumorphic_surface.dart';

/// 完了モーダル（仕様書 3.6）を表示する。
/// 「履歴に保存」で選択中のフィードバックを返し、
/// モーダル外タップなどで閉じた場合は null を返す（履歴には保存しない）。
Future<SuggestionFeedback?> showCompletionModal(BuildContext context) {
  return showModalBottomSheet<SuggestionFeedback>(
    context: context,
    showDragHandle: true,
    builder: (_) => const CompletionModal(),
  );
}

/// フィードバック選択肢の表示定義（UI プロトタイプ CompletionModalScreen 準拠）。
class _FeedbackChoice {
  const _FeedbackChoice(this.feedback, this.emoji, this.label);

  final SuggestionFeedback feedback;
  final String emoji;
  final String label;
}

const List<_FeedbackChoice> _feedbackChoices = [
  _FeedbackChoice(SuggestionFeedback.good, '😊', 'よかった'),
  _FeedbackChoice(SuggestionFeedback.normal, '🙂', '普通'),
  _FeedbackChoice(SuggestionFeedback.bad, '😐', '合わなかった'),
];

/// 「やってみる」後に表示するフィードバック入力モーダル。
/// 記録の保存は行わず、選択結果を呼び出し側へ返すことに徹する。
class CompletionModal extends StatefulWidget {
  const CompletionModal({super.key});

  @override
  State<CompletionModal> createState() => _CompletionModalState();
}

class _CompletionModalState extends State<CompletionModal> {
  // UI プロトタイプに合わせ、初期選択は「よかった」にする。
  SuggestionFeedback _selectedFeedback = SuggestionFeedback.good;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 画面が低い端末でも溢れないよう、シート内はスクロール可能にする。
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(Icons.check, size: 28, color: colorScheme.primary),
          ),
          const SizedBox(height: 14),
          const Text(
            'おつかれさまです',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('今回のよりみちはどうでしたか？', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final choice in _feedbackChoices)
                NeumorphicChipFrame(
                  isSelected: _selectedFeedback == choice.feedback,
                  child: ChoiceChip(
                    label: Text('${choice.emoji} ${choice.label}'),
                    selected: _selectedFeedback == choice.feedback,
                    onSelected: (_) {
                      setState(() => _selectedFeedback = choice.feedback);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: NeumorphicButtonFrame(
              isPrimary: true,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(_selectedFeedback);
                },
                child: const Text('履歴に保存'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
