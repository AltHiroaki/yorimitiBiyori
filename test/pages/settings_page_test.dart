import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimiti_biyori/src/features/notifications/notification_service.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';
import 'package:yorimiti_biyori/src/pages/settings_page.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';
import 'package:yorimiti_biyori/src/repositories/settings_repository.dart';

class _FakeNotificationController implements NotificationController {
  _FakeNotificationController({this.permissionResult = true});

  final bool permissionResult;
  final List<UserSettings> appliedSettingsLog = [];
  int requestPermissionCount = 0;

  @override
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {}

  @override
  Future<bool> requestPermission() async {
    requestPermissionCount += 1;
    return permissionResult;
  }

  @override
  Future<void> applySettings(UserSettings settings) async {
    appliedSettingsLog.add(settings);
  }

  @override
  Future<void> showInvitationNotification() async {}

  @override
  Future<void> scheduleDailyNotification(String notificationTime) async {}

  @override
  Future<void> cancelDailyNotification() async {}
}

Future<void> _pumpPage(
  WidgetTester tester, {
  NotificationController? notificationController,
  NotificationTimePicker? notificationTimePicker,
}) async {
  // ListView 下部（履歴削除の確認ボタン等）まで描画されるよう縦長の画面にする。
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SettingsPage(
          notificationController: notificationController,
          notificationTimePicker: notificationTimePicker,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SuggestionRecord _record() {
  return SuggestionRecord(
    id: 'record_1',
    suggestionId: 'music_jazz_focus',
    suggestionTitle: '作業用にジャズを1曲だけ流す',
    category: 'music',
    estimatedMinutes: 5,
    status: SuggestionRecordStatus.done,
    feedback: SuggestionFeedback.good,
    createdAt: DateTime.utc(2026, 7, 1, 12),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode([_record().toJson()]),
      settingsPreferenceKey: jsonEncode(const UserSettings().toJson()),
    });
  });

  testWidgets('履歴削除の行（赤字タイトル・「削除」ボタン）が表示される', (tester) async {
    await _pumpPage(tester);

    expect(find.text('履歴削除'), findsOneWidget);
    expect(find.text('端末内に保存した履歴を削除'), findsOneWidget);
    expect(find.text('削除'), findsOneWidget);
  });

  testWidgets('「削除」をタップするとインライン確認が表示される', (tester) async {
    await _pumpPage(tester);

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    expect(find.text('本当に削除しますか？この操作は取り消せません。'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('削除する'), findsOneWidget);
  });

  testWidgets('キャンセルで確認が閉じ、履歴が削除されていない', (tester) async {
    await _pumpPage(tester);

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.text('本当に削除しますか？この操作は取り消せません。'), findsNothing);
    expect(find.text('履歴削除'), findsOneWidget);

    final loadedRecords = await RecordsRepository().loadRecords();
    expect(loadedRecords, hasLength(1));
  });

  testWidgets('「削除する」で履歴が空になり、確認が閉じ、SnackBar が表示される', (tester) async {
    await _pumpPage(tester);

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    expect(find.text('本当に削除しますか？この操作は取り消せません。'), findsNothing);
    expect(find.text('履歴を削除しました'), findsOneWidget);

    final loadedRecords = await RecordsRepository().loadRecords();
    expect(loadedRecords, isEmpty);
  });

  testWidgets('通知トグルをOFFにすると設定を保存し、通知サービスへ反映する', (tester) async {
    final notificationController = _FakeNotificationController();
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode([_record().toJson()]),
      settingsPreferenceKey: jsonEncode(
        const UserSettings(
          notificationEnabled: true,
          notificationTime: '17:30',
        ).toJson(),
      ),
    });

    await _pumpPage(
      tester,
      notificationController: notificationController,
    );

    expect(find.text('通知時刻：17:30'), findsOneWidget);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationEnabled, isFalse);
    expect(notificationController.appliedSettingsLog.single.notificationEnabled,
        isFalse);
  });

  testWidgets('通知許可が拒否されたらトグルをONにしない', (tester) async {
    final notificationController = _FakeNotificationController(
      permissionResult: false,
    );
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode([_record().toJson()]),
      settingsPreferenceKey: jsonEncode(
        const UserSettings(notificationEnabled: false).toJson(),
      ),
    });

    await _pumpPage(
      tester,
      notificationController: notificationController,
    );

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationEnabled, isFalse);
    expect(notificationController.requestPermissionCount, 1);
    expect(notificationController.appliedSettingsLog.single.notificationEnabled,
        isFalse);
    expect(find.text('通知を有効にするには、端末の通知許可が必要です'), findsOneWidget);
  });

  testWidgets('通知時刻を変更すると設定を保存し、通知サービスへ反映する', (tester) async {
    final notificationController = _FakeNotificationController();
    TimeOfDay? receivedInitialTime;

    await _pumpPage(
      tester,
      notificationController: notificationController,
      notificationTimePicker: (context, initialTime) async {
        receivedInitialTime = initialTime;
        return const TimeOfDay(hour: 19, minute: 5);
      },
    );

    await tester.tap(find.text('変更'));
    await tester.pumpAndSettle();

    expect(receivedInitialTime, const TimeOfDay(hour: 17, minute: 30));
    expect(find.text('通知時刻：19:05'), findsOneWidget);

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationTime, '19:05');
    expect(notificationController.appliedSettingsLog.single.notificationTime,
        '19:05');
  });
}
