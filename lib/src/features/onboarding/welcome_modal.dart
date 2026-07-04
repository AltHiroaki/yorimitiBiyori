import 'package:flutter/material.dart';

/// 初回起動時に表示するウェルカムモーダル。
class WelcomeModal extends StatelessWidget {
  const WelcomeModal({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('よりみち日和へようこそ'),
      content: const Text(
        '空いた時間にできる、小さなよりみちを提案します。まずは気になるカテゴリを選んでみましょう。',
      ),
      actions: [
        FilledButton(
          onPressed: onStart,
          child: const Text('はじめる'),
        ),
      ],
    );
  }
}
