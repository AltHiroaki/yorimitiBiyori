import 'package:flutter/material.dart';

import '../../models/user_settings.dart';
import '../../widgets/neumorphic_surface.dart';
import 'onboarding_scaffold.dart';

/// 通知許可ステップの結果。
enum NotificationPermissionChoice { allow, later }

/// オンボーディング3ステップ目。
/// OS 権限リクエスト自体は呼び出し側で行い、この widget は選択結果だけを返す。
class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({
    super.key,
    required this.onSelected,
    required this.onBack,
  });

  final ValueChanged<NotificationPermissionChoice> onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 3,
      onBack: onBack,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.notifications_none,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'よりみちのきっかけを通知します',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '初期設定では$defaultNotificationStartTime〜'
          '$defaultNotificationEndTimeの間に、1日1回だけお知らせします。'
          '時間帯はあとから設定で変えられます。',
        ),
      ],
      // 文字サイズ最大でもあふれないよう、収まらないときは縦積みにする。
      footer: OverflowBar(
        alignment: MainAxisAlignment.end,
        overflowAlignment: OverflowBarAlignment.end,
        spacing: 8,
        overflowSpacing: 8,
        children: [
          TextButton(
            onPressed: () => onSelected(NotificationPermissionChoice.later),
            child: const Text('あとで'),
          ),
          NeumorphicButtonFrame(
            isPrimary: true,
            child: FilledButton(
              onPressed: () => onSelected(NotificationPermissionChoice.allow),
              child: const Text('通知を許可する'),
            ),
          ),
        ],
      ),
    );
  }
}
