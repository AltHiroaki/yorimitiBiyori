import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

/// 設定タブ。
/// UI プロトタイプの「03 設定」に対応する。
/// 現在は骨格のみで、各項目の編集・保存は今後の Phase で実装する。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Text(
          '設定',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          '興味カテゴリ、通知時刻、履歴を管理します。',
          style: TextStyle(fontSize: 13),
        ),
        SizedBox(height: 16),
        SectionCard(
          title: '提案設定',
          description: '時間（5分 / 15分 / 30分 / 60分）・予算・移動距離を調整できるようにします。',
        ),
        SizedBox(height: 12),
        SectionCard(
          title: '興味カテゴリ',
          description: '散歩、音楽、読書、学習、カフェ、写真、整理、休憩、運動、買い物の10種から複数選択できるようにします。',
        ),
        SizedBox(height: 12),
        SectionCard(
          title: '通知',
          description: '通知のON/OFFと通知時刻（デフォルト 17:30）を設定できるようにします。通知では 15分 / 30分 / 60分 を選べます。',
        ),
        SizedBox(height: 12),
        SectionCard(
          title: '履歴削除',
          description: '端末内に保存した履歴を、確認付きで削除できるようにします。',
        ),
      ],
    );
  }
}
