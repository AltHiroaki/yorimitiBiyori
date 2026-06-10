import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          'よりみち日和',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '空いた時間に、興味の中からちょっと新しい体験を。',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 24),
        SectionCard(
          title: 'MVP 方針',
          description: 'Android版MVPでは、興味カテゴリを登録し、通知から 15分 / 30分 / 60分 を選ぶと、その時間に合う提案を表示します。',
        ),
        SizedBox(height: 12),
        SectionCard(
          title: '最初に作るもの',
          description: '興味登録、通知、時間選択、ランダム提案、実施・スキップ履歴に絞ります。',
        ),
      ],
    );
  }
}
