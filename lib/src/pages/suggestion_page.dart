import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class SuggestionPage extends StatelessWidget {
  const SuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '提案',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: '30分でできるおすすめ',
          description: '気になる分野の新しいチャンネルを1つ探す。通知ボタンから選ばれた時間に合わせて、今後ここに提案を表示します。',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {},
          child: const Text('やってみる'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {},
          child: const Text('別の提案'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          child: const Text('スキップ'),
        ),
      ],
    );
  }
}
