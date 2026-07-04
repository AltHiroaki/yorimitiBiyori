import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/pages/settings_page.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';

Future<void> _pumpPage(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(body: SettingsPage()),
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
}
