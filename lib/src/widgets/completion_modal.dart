import 'package:flutter/material.dart';

import '../models/suggestion_record.dart';

/// 選択されたフィードバックで履歴を保存する処理。呼び出し側（提案画面）が渡す。
typedef CompletionSaveCallback = Future<void> Function(
  SuggestionFeedback feedback,
);

/// 完了モーダル（仕様書 3.6）を表示する。
/// 「履歴に保存」で [onSave] を実行し、成功したら true を返して閉じる。
/// モーダル外タップなどで閉じた場合は null を返す（履歴には保存しない）。
Future<bool?> showCompletionModal(
  BuildContext context, {
  required CompletionSaveCallback onSave,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => CompletionModal(onSave: onSave),
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
/// 保存の実処理は [onSave] に委ね、ここでは保存中のボタン無効化と
/// 成否の SnackBar 表示だけを担う（issue #44）。
class CompletionModal extends StatefulWidget {
  const CompletionModal({super.key, required this.onSave});

  final CompletionSaveCallback onSave;

  @override
  State<CompletionModal> createState() => _CompletionModalState();
}

class _CompletionModalState extends State<CompletionModal> {
  // UI プロトタイプに合わせ、初期選択は「よかった」にする。
  SuggestionFeedback _selectedFeedback = SuggestionFeedback.good;

  /// 保存処理中は「履歴に保存」を無効化し、連打による二重登録を防ぐ。
  bool _isSaving = false;

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_selectedFeedback);
    } catch (_) {
      // 失敗時はモーダルを開いたままにして、再試行できるようにする。
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    // ScaffoldMessenger はモーダルより上の階層にあるため、閉じたあとも表示され続ける。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('履歴に保存しました')),
    );
    Navigator.of(context).pop(true);
  }

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
                ChoiceChip(
                  label: Text('${choice.emoji} ${choice.label}'),
                  selected: _selectedFeedback == choice.feedback,
                  onSelected: _isSaving
                      ? null
                      : (_) {
                          setState(() => _selectedFeedback = choice.feedback);
                        },
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _handleSave,
              child: const Text('履歴に保存'),
            ),
          ),
        ],
      ),
    );
  }
}
