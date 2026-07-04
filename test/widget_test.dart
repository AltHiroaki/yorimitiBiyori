import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yorimiti_biyori/src/app/yorimiti_biyori_app.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';
import 'package:yorimiti_biyori/src/repositories/settings_repository.dart';

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

  testWidgets('ボトムナビゲーションは提案・履歴・設定の3タブ', (WidgetTester tester) async {
    await tester.pumpWidget(const YorimitiBiyoriApp());
    await tester.pumpAndSettle();

    expect(find.text('提案'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
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

    await tester.ensureVisible(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('履歴'));
    await tester.pumpAndSettle();

    expect(find.text('まだ履歴はありません'), findsOneWidget);
  });
}
