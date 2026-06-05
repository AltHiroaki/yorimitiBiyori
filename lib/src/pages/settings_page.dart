import 'package:flutter/material.dart';

import '../widgets/section_card.dart';

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
        SizedBox(height: 16),
        SectionCard(
          title: '通知設定',
          description: '今後、通知時刻と通知ボタンを設定できるようにします。MVP では 15分 / 30分 / 60分 を基本にします。',
        ),
        SizedBox(height: 12),
        SectionCard(
          title: '興味カテゴリ',
          description: '音楽、YouTube、読書、散歩、学習など、ユーザーが興味を持つカテゴリを登録できるようにします。',
        ),
      ],
    );
  }
}
