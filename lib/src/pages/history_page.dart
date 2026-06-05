import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListView(
      padding: EdgeInsets.all(20),
      children: [
        Text(
          '履歴',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        SectionCard(
          title: 'まだ履歴はありません',
          description: '今後、やってみた・スキップした提案を端末内に保存し、ここに表示します。',
        ),
      ],
    );
  }
}
