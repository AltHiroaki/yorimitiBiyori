import 'package:flutter/material.dart';

/// よりみち日和の基本操作をいつでも読み返せる静的な案内ページ。
class UsagePage extends StatelessWidget {
  const UsagePage({super.key});

  static const _sections = [
    _UsageSectionData(
      icon: Icons.alt_route,
      title: 'よりみち日和の使い方',
      description: '通知や提案タブによりみちが届きます。「やってみる」で始め、終わったら「完了」すると履歴に残ります。',
    ),
    _UsageSectionData(
      icon: Icons.skip_next,
      title: '提案が合わないときは',
      description: '「スキップして次の提案」で次へ進めます。カテゴリやジャンルは提案設定から絞り込めます。',
    ),
    _UsageSectionData(
      icon: Icons.replay,
      title: 'スキップした提案をもう一度',
      description: '履歴のスキップした提案をタップすると、内容を確認してもう一度「やってみる」ことができます。',
    ),
    _UsageSectionData(
      icon: Icons.menu_book_outlined,
      title: '料理のレシピを見る',
      description: '料理の提案は、「詳しく見る」をタップすると材料と手順をその場で確認できます。',
    ),
    _UsageSectionData(
      icon: Icons.notifications_none,
      title: '通知について',
      description: '通知をオンにすると、設定した時間帯の中でランダムな時刻に1日1回、よりみちのきっかけが届きます。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('使い方')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        itemCount: _sections.length,
        separatorBuilder: (_, _) => const Divider(height: 32),
        itemBuilder: (context, index) {
          final section = _sections[index];
          return _UsageSection(section: section);
        },
      ),
    );
  }
}

class _UsageSectionData {
  const _UsageSectionData({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

class _UsageSection extends StatelessWidget {
  const _UsageSection({required this.section});

  final _UsageSectionData section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(section.icon, color: colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                section.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
