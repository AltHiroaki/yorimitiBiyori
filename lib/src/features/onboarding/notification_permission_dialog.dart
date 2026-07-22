import 'package:flutter/material.dart';

import '../../app/yorimichi_neumorphic_theme.dart';
import '../../widgets/neumorphic_surface.dart';

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
      child: NeumorphicSurface(
        radius: YorimichiNeumorphicTheme.heroRadius,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'よりみちのきっかけを通知します',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('空き時間に、小さな行動の提案をお届けします。通知はあとから設定で変更できます。'),
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
    );
  }
}
