import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yorimiti_biyori/src/app/yorimiti_biyori_app.dart';
import 'package:yorimiti_biyori/src/features/notifications/notification_service.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';
import 'package:yorimiti_biyori/src/repositories/settings_repository.dart';

class _FakeNotificationController implements NotificationController {
  NotificationTapCallback? onNotificationTap;

  void tapNotification() {
    onNotificationTap?.call(notificationPayloadSuggestion);
  }

  @override
  Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    this.onNotificationTap = onNotificationTap;
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> applySettings(UserSettings settings) async {}

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

void main() {
  setUp(() {
    // 提案タブが設定を読み込むため、shared_preferences をモックしておく。
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: true).toJson(),
      ),
    });
    // rootBundle は読み込んだアセットの Future をキャッシュする。前のテストの
    // ゾーンに紐づいた Future を await すると完了しないため、テストごとに捨てる。
    rootBundle.clear();
  });

  testWidgets('アプリが起動して提案タブが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());
    // 提案データ・設定の非同期読込を完了させる。
    await tester.pumpAndSettle();

    // 提案タブ（トップ画面）の内容
    expect(find.text('よりみち日和'), findsOneWidget);
    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('別の提案'), findsOneWidget);
  });

  testWidgets('OS のダークモード設定に追従して darkTheme が使われる', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.darkTheme, isNotNull);
    expect(materialApp.themeMode, ThemeMode.system);

    final appShellContext = tester.element(find.byType(AppShell));
    expect(Theme.of(appShellContext).brightness, Brightness.dark);
    expect(Theme.of(appShellContext).colorScheme.brightness, Brightness.dark);
  });

  testWidgets('ダークモードでも主要画面と完了モーダルを描画できる', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);

    final tryButton = find.widgetWithText(FilledButton, 'やってみる');
    await tester.scrollUntilVisible(tryButton, 100);
    await tester.tap(tryButton);
    await tester.pumpAndSettle();
    expect(find.text('おつかれさまです'), findsOneWidget);

    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();
    expect(find.text('まだ履歴はありません'), findsOneWidget);

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('興味カテゴリ、通知時間帯、履歴を管理します。'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('提案設定を開く'), 200);
    await tester.tap(find.text('提案設定を開く'));
    await tester.pumpAndSettle();
    expect(find.text('この条件で保存'), findsOneWidget);
  });

  testWidgets('設定画面で「ダーク」を選ぶとアプリ全体がダークテーマに切り替わる', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ダーク'));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    final appShellContext = tester.element(find.byType(AppShell));
    expect(Theme.of(appShellContext).brightness, Brightness.dark);

    // 「ライト」へ戻すと OS 設定によらずライトテーマになる。
    await tester.tap(find.text('ライト'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets('保存済みのテーマモード（ダーク）で起動できる', (tester) async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(
          firstLaunchCompleted: true,
          themeMode: ThemeModeSetting.dark,
        ).toJson(),
      ),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    final appShellContext = tester.element(find.byType(AppShell));
    expect(Theme.of(appShellContext).brightness, Brightness.dark);
  });

  testWidgets('ダークモードでもオンボーディングを描画できる', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: false).toJson(),
      ),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('よりみち日和へようこそ'), findsOneWidget);

    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    expect(find.text('興味のあるよりみちを選んでください'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    expect(find.text('よりみちのきっかけを通知します'), findsOneWidget);
  });

  testWidgets('ボトムナビゲーションは提案・履歴・設定の3タブ', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('提案'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('タブ切替は200msのフェードで表示を切り替える', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    final appShellSwitcher = find.byWidgetPredicate((widget) {
      return widget is AnimatedSwitcher && widget.child is KeyedSubtree;
    });

    final animatedSwitcher = tester.widget<AnimatedSwitcher>(
      appShellSwitcher,
    );
    expect(animatedSwitcher.duration, const Duration(milliseconds: 200));
    expect(find.byKey(const ValueKey<int>(0)), findsOneWidget);

    await tester.tap(find.text('履歴'));
    await tester.pump();

    expect(find.byType(FadeTransition), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<int>(1)), findsOneWidget);
  });

  testWidgets('履歴タブに切り替えると空状態が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('まだ履歴はありません'), findsOneWidget);
  });

  testWidgets('設定タブで履歴を削除すると履歴タブが空状態に戻る', (WidgetTester tester) async {
    final doneRecord = SuggestionRecord(
      id: 'record_1',
      suggestionId: 'music_jazz_focus',
      suggestionTitle: '作業用にジャズを1曲だけ流す',
      category: 'music',
      estimatedMinutes: 5,
      status: SuggestionRecordStatus.done,
      feedback: SuggestionFeedback.good,
      createdAt: DateTime.utc(2026, 7, 1, 12),
    );
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: true).toJson(),
      ),
      recordsPreferenceKey: jsonEncode([doneRecord.toJson()]),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('作業用にジャズを1曲だけ流す'), findsOneWidget);
    expect(find.text('まだ履歴はありません'), findsNothing);

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('削除'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('まだ履歴はありません'), findsOneWidget);
  });

  testWidgets('通知タップ時は提案タブへ戻る', (WidgetTester tester) async {
    final notificationController = _FakeNotificationController();

    await tester.pumpWidget(
      YorimitiBiyoriApp(notificationController: notificationController),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    expect(find.text('興味カテゴリ、通知時間帯、履歴を管理します。'), findsOneWidget);

    notificationController.tapNotification();
    await tester.pumpAndSettle();

    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);
  });
}
