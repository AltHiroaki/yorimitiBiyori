import 'package:flutter/material.dart';

import '../../models/user_settings.dart';
import '../../widgets/neumorphic_surface.dart';
import 'onboarding_scaffold.dart';

/// オンボーディング1ステップ目。アプリの1周の流れを案内する。
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 1,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.lightbulb_outline,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'よりみち日和へようこそ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('空いた時間に、小さなよりみちを。'),
        const SizedBox(height: 24),
        const _WelcomeFlowItem(
          icon: Icons.tune,
          title: '好きなことを選ぶ',
          description: '音楽・料理・読書・映画から。あとで変えられます。',
        ),
        const SizedBox(height: 16),
        const _WelcomeFlowItem(
          icon: Icons.notifications_none,
          title: '空き時間にそっと届く',
          description:
              '初期設定では$defaultNotificationStartTime〜'
              '$defaultNotificationEndTimeの間に、1日1回だけ。',
        ),
        const SizedBox(height: 16),
        const _WelcomeFlowItem(
          icon: Icons.check_circle_outline,
          title: 'やってみたら記録に残る',
          description: '気分じゃなければ次へ。送った提案はあとで戻せます。',
        ),
        const SizedBox(height: 24),
        const Text(
          'まずはこのまま。細かい好みは、提案を見てから絞り込めます。',
          style: TextStyle(fontSize: 13),
        ),
      ],
      footer: SizedBox(
        width: double.infinity,
        child: NeumorphicButtonFrame(
          isPrimary: true,
          child: FilledButton(
            onPressed: onStart,
            child: const Text('はじめる'),
          ),
        ),
      ),
    );
  }
}

class _WelcomeFlowItem extends StatelessWidget {
  const _WelcomeFlowItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 36, child: Icon(icon, color: colorScheme.primary)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
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
