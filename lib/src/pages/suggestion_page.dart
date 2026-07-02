import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

/// 提案タブ（トップ画面）。
/// UI プロトタイプの「01 提案」に対応する。
/// 現在は骨格のみで、提案ロジック・提案設定画面との接続は今後の Phase で実装する。
class SuggestionPage extends StatelessWidget {
  const SuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'よりみち日和',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          '空いた時間に、小さなよりみちを。',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: '現在の提案条件',
          description: '音楽・読書・映画 / ジャンル：ジャズ。今後ここに保存済みのカテゴリと詳細設定を表示し、「提案設定」画面から変更できるようにします。',
        ),
        const SizedBox(height: 12),
        const SectionCard(
          title: '今日のよりみち',
          description: '作業用にジャズを1曲だけ流す — いつもの曲から少しだけ角度を変えてみる。今後ここに条件に合う提案を1件表示します。',
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
        const SizedBox(height: 16),
        const SectionCard(
          title: '使い方',
          description: '通知をタップすると保存した条件のよりみちが表示されます。条件を変えたいときは「提案設定」から調整できます。',
        ),
      ],
    );
  }
}
