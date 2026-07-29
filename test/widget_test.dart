import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yorimichi_biyori/src/app/app_shell.dart';
import 'package:yorimichi_biyori/src/app/yorimichi_biyori_app.dart';
import 'package:yorimichi_biyori/src/features/notifications/notification_service.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';
import 'package:yorimichi_biyori/src/models/user_settings.dart';
import 'package:yorimichi_biyori/src/pages/history_page.dart';
import 'package:yorimichi_biyori/src/repositories/ongoing_suggestion_repository.dart';
import 'package:yorimichi_biyori/src/repositories/records_repository.dart';
import 'package:yorimichi_biyori/src/repositories/settings_repository.dart';

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
    await tester.pumpWidget(const YorimichiBiyoriApp());
    // 提案データ・設定の非同期読込を完了させる。
    await tester.pumpAndSettle();

    // 提案タブ（トップ画面）の内容
    expect(find.text('よりみち日和'), findsOneWidget);
    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('スキップして次の提案'), findsOneWidget);
  });

  testWidgets('「システム」を選んでいると OS のダークモード設定に追従する', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    // デフォルトはライト固定なので、追従させるには system を保存しておく。
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(
          firstLaunchCompleted: true,
          themeMode: ThemeModeSetting.system,
        ).toJson(),
      ),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimichiBiyoriApp());
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
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(
          firstLaunchCompleted: true,
          themeMode: ThemeModeSetting.dark,
        ).toJson(),
      ),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('空いた時間に、小さなよりみちを。'), findsOneWidget);

    // やってみる → 実施中カード → 完了 → フィードバックモーダル（issue #48）。
    final tryButton = find.widgetWithText(FilledButton, 'やってみる');
    // AppShell の PageView も Scrollable なので、ページ内のリストを名指しする。
    await tester.scrollUntilVisible(
      tryButton,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(tryButton);
    await tester.pumpAndSettle();
    expect(find.text('実施中のよりみち'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '完了'));
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

    await tester.scrollUntilVisible(
      find.text('提案設定を開く'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('提案設定を開く'));
    await tester.pumpAndSettle();
    expect(find.text('この条件で保存'), findsOneWidget);
  });

  testWidgets('設定画面で「ダーク」を選ぶとアプリ全体がダークテーマに切り替わる', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const YorimichiBiyoriApp());
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

  testWidgets('テーマ未保存のときは端末設定によらずライトで起動する', (tester) async {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
    // 端末がダークモードでもライト固定になることを確かめる。
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);
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

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);

    final appShellContext = tester.element(find.byType(AppShell));
    expect(Theme.of(appShellContext).brightness, Brightness.dark);
  });

  testWidgets('ダークモードでもオンボーディングを描画できる', (tester) async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(
          firstLaunchCompleted: false,
          themeMode: ThemeModeSetting.dark,
        ).toJson(),
      ),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('よりみち日和へようこそ'), findsOneWidget);

    await tester.ensureVisible(find.text('はじめる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('はじめる'));
    await tester.pumpAndSettle();
    expect(find.text('興味のあるよりみちを選んでください'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await tester.pumpAndSettle();
    expect(find.text('よりみちのきっかけを通知します'), findsOneWidget);
  });

  testWidgets('ボトムナビゲーションは提案・履歴・設定の3タブ', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('提案'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('隣接タブのタップはスライドで切り替わる', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    expect(_pageControllerOf(tester).page, 0);

    await tester.tap(find.text('履歴'));
    // スライドの途中では 0 と 1 の間に位置し、両ページが見えている。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    final midwayPage = _pageControllerOf(tester).page!;
    expect(midwayPage, greaterThan(0));
    expect(midwayPage, lessThan(1));
    // 飛び越しではないのでフェードは掛からない。
    expect(_fadeOpacityOf(tester), 1);

    await tester.pumpAndSettle();
    expect(_pageControllerOf(tester).page, 1);
    expect(_selectedTabIndexOf(tester), 1);
  });

  testWidgets('提案 ↔ 設定 の飛び越しは履歴を見せずフェードで切り替わる', (tester) async {
    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pump();

    // jumpToPage なので中間の履歴ページを通らない。
    expect(_pageControllerOf(tester).page, 2);
    expect(find.text('実施したよりみちと、スキップした提案を確認します。'), findsNothing);
    expect(_slidePositionOf(tester), Offset.zero);

    await tester.pump(const Duration(milliseconds: 100));
    expect(_fadeOpacityOf(tester), lessThan(1));

    await tester.pumpAndSettle();
    expect(_fadeOpacityOf(tester), 1);
    expect(_selectedTabIndexOf(tester), 2);
    expect(find.text('興味カテゴリ、通知時間帯、履歴を管理します。'), findsOneWidget);
  });

  testWidgets('横スワイプで隣のタブへ移動し、下タブの選択状態も追従する', (tester) async {
    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    final pageView = find.byType(PageView);

    // 提案 → 履歴（左へ払う）。
    await tester.fling(pageView, const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(_pageControllerOf(tester).page, 1);
    expect(_selectedTabIndexOf(tester), 1);
    expect(find.text('まだ履歴はありません'), findsOneWidget);

    // 履歴 → 設定。
    await tester.fling(pageView, const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(_pageControllerOf(tester).page, 2);
    expect(_selectedTabIndexOf(tester), 2);

    // 設定 → 履歴（右へ払う）。
    await tester.fling(pageView, const Offset(400, 0), 1000);
    await tester.pumpAndSettle();

    expect(_pageControllerOf(tester).page, 1);
    expect(_selectedTabIndexOf(tester), 1);
  });

  testWidgets('スワイプを途中でやめると履歴は読み込まれない', (tester) async {
    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    // 半分に届かない距離までドラッグして戻す。
    // 1 回目の移動はドラッグ開始の判定に使われるため、2 回に分けて動かす。
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await gesture.moveBy(const Offset(-30, 0));
    await gesture.moveBy(const Offset(-200, 0));
    await tester.pump();

    // 隣の履歴ページは build されるが、読み込みは走らずローディング表示のまま。
    expect(_pageControllerOf(tester).page, greaterThan(0));
    expect(find.byType(HistoryPage), findsOneWidget);
    expect(
      tester.widget<HistoryPage>(find.byType(HistoryPage)).isActive,
      isFalse,
    );
    expect(find.text('まだ履歴はありません'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(_pageControllerOf(tester).page, 0);
    expect(_selectedTabIndexOf(tester), 0);
  });

  testWidgets('reduce motion 有効時はスライドもフェードもせず切り替える', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: YorimichiBiyoriApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 隣接（提案 → 履歴）でもスライドせず即座に切り替わる。
    await tester.tap(find.text('履歴'));
    await tester.pump();
    expect(_pageControllerOf(tester).page, 1);
    expect(_fadeOpacityOf(tester), 1);

    // 飛び越し（提案 → 設定）も同じく即座に切り替わる。
    await tester.pumpAndSettle();
    await tester.tap(find.text('提案'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('設定'));
    await tester.pump();
    expect(_pageControllerOf(tester).page, 2);
    expect(_fadeOpacityOf(tester), 1);
  });

  testWidgets('完了時は履歴タブへ自動遷移し、保存した履歴IDをハイライト対象に渡す', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    final tryButton = find.widgetWithText(FilledButton, 'やってみる');
    // AppShell の PageView も Scrollable なので、ページ内のリストを名指しする。
    await tester.scrollUntilVisible(
      tryButton,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(tryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '完了'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🙂 普通'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('これで完了'));

    // 完了演出（チェック → カードの吸い込み）のあとに履歴タブへ切り替わる。
    // 通常のタブ移動と違い、右から滑り込むスライドが掛かることを確かめる。
    final completionSlideStart = await _pumpUntilCompletionSlideStarts(tester);
    expect(completionSlideStart, isNotNull);
    expect(completionSlideStart!.dx, greaterThan(0));
    // 飛び越しと同じく中間ページは見せないので、切り替わった時点で履歴にいる。
    expect(_pageControllerOf(tester).page, 1);
    expect(_fadeOpacityOf(tester), lessThan(1));

    await tester.pumpAndSettle();

    expect(_slidePositionOf(tester), Offset.zero);
    expect(_fadeOpacityOf(tester), 1);
    expect(_selectedTabIndexOf(tester), 1);
    expect(find.text('今週の履歴'), findsOneWidget);

    final historyPage = tester.widget<HistoryPage>(find.byType(HistoryPage));
    expect(historyPage.highlightedRecordId, isNotNull);
  });

  testWidgets('履歴タブに切り替えると空状態が表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('まだ履歴はありません'), findsOneWidget);
  });

  testWidgets('スキップ履歴を復活すると提案タブの実施中カードへ自動遷移する', (tester) async {
    final skippedRecord = SuggestionRecord(
      id: 'record_skipped',
      suggestionId: 'music_jazz_focus',
      suggestionTitle: '作業用にジャズを1曲だけ流す',
      category: 'music',
      estimatedMinutes: 5,
      status: SuggestionRecordStatus.skipped,
      feedback: null,
      createdAt: DateTime.now(),
    );
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: true).toJson(),
      ),
      recordsPreferenceKey: jsonEncode([skippedRecord.toJson()]),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('作業用にジャズを1曲だけ流す'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'やってみる'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '実施する'));
    await tester.pumpAndSettle();

    expect(find.text('実施中のよりみち'), findsOneWidget);
    expect(find.text('作業用にジャズを1曲だけ流す'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(ongoingSuggestionPreferenceKey), isNotNull);

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();
    expect(find.text('作業用にジャズを1曲だけ流す'), findsOneWidget);
    expect(find.text('スキップ'), findsNWidgets(3));
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
      createdAt: DateTime.now(),
    );
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: jsonEncode(
        const UserSettings(firstLaunchCompleted: true).toJson(),
      ),
      recordsPreferenceKey: jsonEncode([doneRecord.toJson()]),
    });
    rootBundle.clear();

    await tester.pumpWidget(const YorimichiBiyoriApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('作業用にジャズを1曲だけ流す'), findsOneWidget);
    expect(find.text('まだ履歴はありません'), findsNothing);

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('削除'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
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
      YorimichiBiyoriApp(notificationController: notificationController),
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

PageController _pageControllerOf(WidgetTester tester) {
  return tester.widget<PageView>(find.byType(PageView)).controller!;
}

double _fadeOpacityOf(WidgetTester tester) {
  return tester
      .widget<FadeTransition>(find.byKey(appShellTabFadeKey))
      .opacity
      .value;
}

Offset _slidePositionOf(WidgetTester tester) {
  return tester
      .widget<SlideTransition>(find.byKey(appShellTabSlideKey))
      .position
      .value;
}

int _selectedTabIndexOf(WidgetTester tester) {
  return tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;
}

/// 完了演出が終わってタブ切替のスライドが始まるまでフレームを進め、
/// 最初に観測したスライド量を返す。見つからなければ null。
Future<Offset?> _pumpUntilCompletionSlideStarts(WidgetTester tester) async {
  for (var frame = 0; frame < 240; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
    final position = _slidePositionOf(tester);
    if (position != Offset.zero) {
      return position;
    }
  }
  return null;
}
