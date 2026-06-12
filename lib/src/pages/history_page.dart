import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

/// 履歴タブ。
/// UI プロトタイプの「02 履歴」「10 履歴空状態」に対応する。
/// 現在は骨格のみで、記録の保存・集計は今後の Phase で実装する。
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '履歴',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          '実施したよりみちと、スキップした提案を確認します。',
          style: TextStyle(fontSize: 13),
        ),
        SizedBox(height: 16),
        SectionCard(
          title: '実施 0 ／ スキップ 0 ／ 0 分',
          description: '今後ここに実施数・スキップ数・合計時間を表示します。',
        ),
        SizedBox(height: 12),
        SectionCard(
          title: 'まだ履歴はありません',
          description: 'よりみちを実行すると、ここに記録されます。',
        ),
      ],
    );
  }
}
