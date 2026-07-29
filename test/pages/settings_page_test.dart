import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimichi_biyori/src/app/theme_mode_scope.dart';
import 'package:yorimichi_biyori/src/features/notifications/notification_service.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';
import 'package:yorimichi_biyori/src/models/user_settings.dart';
import 'package:yorimichi_biyori/src/pages/settings_page.dart';
import 'package:yorimichi_biyori/src/pages/suggestion_settings_page.dart';
import 'package:yorimichi_biyori/src/pages/usage_page.dart';
import 'package:yorimichi_biyori/src/repositories/records_repository.dart';
import 'package:yorimichi_biyori/src/repositories/settings_repository.dart';

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
  Future<void> scheduleDailyNotifications({
    required String startTime,
    required String endTime,
  }) async {}

  @override
  Future<void> cancelDailyNotifications() async {}
}

Future<void> _pumpPage(
  WidgetTester tester, {
  NotificationController? notificationController,
  NotificationTimePicker? notificationTimePicker,
  ValueChanged<ThemeModeSetting>? onThemeModeSettingChanged,
}) async {
  // ListView 下部（履歴削除の確認ボタン等）まで描画されるよう縦長の画面にする。
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final page = SettingsPage(
    notificationController: notificationController,
    notificationTimePicker: notificationTimePicker,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: onThemeModeSettingChanged == null
            ? page
            : ThemeModeScope(
                themeModeSetting: ThemeModeSetting.system,
                onThemeModeSettingChanged: onThemeModeSettingChanged,
                child: page,
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

  testWidgets('提案設定を開くとカテゴリ変更画面へ遷移できる', (tester) async {
    await _pumpPage(tester);

    await tester.tap(find.text('提案設定を開く'));
    await tester.pumpAndSettle();

    expect(find.byType(SuggestionSettingsPage), findsOneWidget);
    expect(find.widgetWithText(FilterChip, '🎵 音楽'), findsOneWidget);
    expect(find.text('この条件で保存'), findsOneWidget);
  });

  testWidgets('「使い方」から専用ページへ遷移し、決定済みの5項目を確認できる', (tester) async {
    await _pumpPage(tester);

    expect(find.text('よりみち日和の基本操作を確認'), findsOneWidget);
    await tester.tap(find.text('使い方'));
    await tester.pumpAndSettle();

    expect(find.byType(UsagePage), findsOneWidget);
    expect(find.text('よりみち日和の使い方'), findsOneWidget);
    expect(find.text('提案が合わないときは'), findsOneWidget);
    expect(find.text('スキップした提案をもう一度'), findsOneWidget);
    expect(find.text('料理のレシピを見る'), findsOneWidget);
    expect(find.text('通知について'), findsOneWidget);
    expect(
      find.text('通知や提案タブによりみちが届きます。「やってみる」で始め、終わったら「完了」すると履歴に残ります。'),
      findsOneWidget,
    );
    expect(
      find.text('「スキップして次の提案」で次へ進めます。カテゴリやジャンルは提案設定から絞り込めます。'),
      findsOneWidget,
    );
    expect(
      find.text('履歴のスキップした提案をタップすると、内容を確認してもう一度「やってみる」ことができます。'),
      findsOneWidget,
    );
    expect(find.text('料理の提案は、「詳しく見る」をタップすると材料と手順をその場で確認できます。'), findsOneWidget);
    expect(
      find.text('通知をオンにすると、設定した時間帯の中でランダムな時刻に1日1回、よりみちのきっかけが届きます。'),
      findsOneWidget,
    );
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

  testWidgets('テーマカードがライト／ダーク／システムの順で表示される', (tester) async {
    await _pumpPage(tester);

    expect(find.text('テーマ'), findsOneWidget);
    expect(find.text('システム'), findsOneWidget);
    expect(find.text('ライト'), findsOneWidget);
    expect(find.text('ダーク'), findsOneWidget);

    final themeButton = tester.widget<SegmentedButton<ThemeModeSetting>>(
      find.byType(SegmentedButton<ThemeModeSetting>),
    );
    expect(themeButton.segments.map((segment) => segment.value).toList(), [
      ThemeModeSetting.light,
      ThemeModeSetting.dark,
      ThemeModeSetting.system,
    ]);
  });

  testWidgets('保存済み設定が無いときはライトが選択されている', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await _pumpPage(tester);

    final themeButton = tester.widget<SegmentedButton<ThemeModeSetting>>(
      find.byType(SegmentedButton<ThemeModeSetting>),
    );
    expect(themeButton.selected, {ThemeModeSetting.light});
  });

  testWidgets('「ダーク」を選ぶと設定を保存し、ThemeModeScope へ通知する', (tester) async {
    final changedSettings = <ThemeModeSetting>[];

    await _pumpPage(
      tester,
      onThemeModeSettingChanged: changedSettings.add,
    );

    await tester.tap(find.text('ダーク'));
    await tester.pumpAndSettle();

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.themeMode, ThemeModeSetting.dark);
    expect(changedSettings, [ThemeModeSetting.dark]);
  });

  testWidgets('ThemeModeScope が無くても「ライト」への切り替えで保存できる', (tester) async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(themeMode: ThemeModeSetting.dark).toJson(),
      ),
    });

    await _pumpPage(tester);

    await tester.tap(find.text('ライト'));
    await tester.pumpAndSettle();

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.themeMode, ThemeModeSetting.light);
  });

  testWidgets('通知トグルをOFFにすると設定を保存し、通知サービスへ反映する', (tester) async {
    final notificationController = _FakeNotificationController();
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode([_record().toJson()]),
      settingsPreferenceKey: jsonEncode(
        const UserSettings(
          notificationEnabled: true,
          notificationStartTime: '17:00',
          notificationEndTime: '21:00',
        ).toJson(),
      ),
    });

    await _pumpPage(
      tester,
      notificationController: notificationController,
    );

    expect(find.text('開始時刻：17:00'), findsOneWidget);
    expect(find.text('終了時刻：21:00'), findsOneWidget);

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

  testWidgets('開始時刻を変更すると設定を保存し、通知サービスへ反映する', (tester) async {
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

    // 1 つ目の「変更」= 開始時刻。
    await tester.tap(find.text('変更').first);
    await tester.pumpAndSettle();

    expect(receivedInitialTime, const TimeOfDay(hour: 17, minute: 0));
    expect(find.text('開始時刻：19:05'), findsOneWidget);

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationStartTime, '19:05');
    expect(savedSettings.notificationEndTime, '21:00');
    expect(
        notificationController.appliedSettingsLog.single.notificationStartTime,
        '19:05');
  });

  testWidgets('終了時刻を変更すると設定を保存し、通知サービスへ反映する', (tester) async {
    final notificationController = _FakeNotificationController();
    TimeOfDay? receivedInitialTime;

    await _pumpPage(
      tester,
      notificationController: notificationController,
      notificationTimePicker: (context, initialTime) async {
        receivedInitialTime = initialTime;
        return const TimeOfDay(hour: 22, minute: 30);
      },
    );

    // 2 つ目の「変更」= 終了時刻。
    await tester.tap(find.text('変更').at(1));
    await tester.pumpAndSettle();

    expect(receivedInitialTime, const TimeOfDay(hour: 21, minute: 0));
    expect(find.text('終了時刻：22:30'), findsOneWidget);

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationEndTime, '22:30');
    expect(notificationController.appliedSettingsLog.single.notificationEndTime,
        '22:30');
  });

  testWidgets('終了時刻より後の開始時刻はエラーになり保存されない', (tester) async {
    final notificationController = _FakeNotificationController();

    await _pumpPage(
      tester,
      notificationController: notificationController,
      notificationTimePicker: (context, initialTime) async {
        return const TimeOfDay(hour: 22, minute: 0);
      },
    );

    await tester.tap(find.text('変更').first);
    await tester.pumpAndSettle();

    expect(find.text('開始時刻は終了時刻より後にできません'), findsOneWidget);
    expect(find.text('開始時刻：17:00'), findsOneWidget);

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationStartTime, '17:00');
    expect(notificationController.appliedSettingsLog, isEmpty);
  });

  testWidgets('開始時刻より前の終了時刻はエラーになり保存されない', (tester) async {
    final notificationController = _FakeNotificationController();

    await _pumpPage(
      tester,
      notificationController: notificationController,
      notificationTimePicker: (context, initialTime) async {
        return const TimeOfDay(hour: 8, minute: 0);
      },
    );

    await tester.tap(find.text('変更').at(1));
    await tester.pumpAndSettle();

    expect(find.text('終了時刻は開始時刻より前にできません'), findsOneWidget);
    expect(find.text('終了時刻：21:00'), findsOneWidget);

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationEndTime, '21:00');
    expect(notificationController.appliedSettingsLog, isEmpty);
  });

  testWidgets('開始時刻と同じ終了時刻は固定時刻として保存できる', (tester) async {
    final notificationController = _FakeNotificationController();

    await _pumpPage(
      tester,
      notificationController: notificationController,
      notificationTimePicker: (context, initialTime) async {
        return const TimeOfDay(hour: 17, minute: 0);
      },
    );

    await tester.tap(find.text('変更').at(1));
    await tester.pumpAndSettle();

    expect(find.text('終了時刻：17:00'), findsOneWidget);

    final savedSettings = await SettingsRepository().loadSettings();
    expect(savedSettings.notificationStartTime, '17:00');
    expect(savedSettings.notificationEndTime, '17:00');
  });
}
