import 'package:flutter/material.dart';

/// 通知許可ステップの結果。
enum NotificationPermissionChoice { allow, later }

/// M4 の通知基盤実装まで、OS 権限リクエストは行わず選択結果だけを返す。
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({
    super.key,
    required this.onSelected,
  });

  final ValueChanged<NotificationPermissionChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.notifications_none,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('よりみちのきっかけを通知します'),
      content: const Text(
        '空き時間に、小さな行動の提案をお届けします。通知はあとから設定で変更できます。',
      ),
      actions: [
        TextButton(
          onPressed: () => onSelected(NotificationPermissionChoice.later),
          child: const Text('あとで'),
        ),
        FilledButton(
          onPressed: () => onSelected(NotificationPermissionChoice.allow),
          child: const Text('通知を許可する'),
        ),
      ],
    );
  }
}
