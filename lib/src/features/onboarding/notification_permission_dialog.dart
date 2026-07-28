import 'package:flutter/material.dart';

import '../../app/yorimichi_neumorphic_theme.dart';
import '../../models/user_settings.dart';
import '../../widgets/neumorphic_surface.dart';
import 'onboarding_progress.dart';

/// 通知許可ステップの結果。
enum NotificationPermissionChoice { allow, later }

/// OS 権限リクエスト自体は呼び出し側で行い、この widget は選択結果だけを返す。
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key, required this.onSelected});

  final ValueChanged<NotificationPermissionChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: NeumorphicSurface(
        radius: YorimichiNeumorphicTheme.heroRadius,
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const OnboardingProgress(currentStep: 3),
                const SizedBox(height: 20),
                Icon(
                  Icons.notifications_none,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'よりみちのきっかけを通知します',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '初期設定では$defaultNotificationStartTime〜'
                  '$defaultNotificationEndTimeの間に、1日1回だけお知らせします。'
                  '時間帯はあとから設定で変えられます。',
                ),
                const SizedBox(height: 24),
                // 文字サイズ最大でもあふれないよう、収まらないときは縦積みにする。
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  overflowAlignment: OverflowBarAlignment.end,
                  spacing: 8,
                  overflowSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: () =>
                          onSelected(NotificationPermissionChoice.later),
                      child: const Text('あとで'),
                    ),
                    NeumorphicButtonFrame(
                      isPrimary: true,
                      child: FilledButton(
                        onPressed: () =>
                            onSelected(NotificationPermissionChoice.allow),
                        child: const Text('通知を許可する'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
