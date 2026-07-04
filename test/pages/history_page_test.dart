import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/pages/history_page.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';

/// 固定の履歴リストを返すテスト用フェイク。
class _FakeRecordsRepository implements RecordsRepository {
  _FakeRecordsRepository(this.records);

  final List<SuggestionRecord> records;

  @override
  Future<List<SuggestionRecord>> loadRecords() async => records;

  @override
  Future<void> addRecord(SuggestionRecord record) async {
    records.add(record);
  }

  @override
  Future<void> deleteAllRecords() async {
    records.clear();
  }
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required List<SuggestionRecord> records,
  VoidCallback? onGoToSuggestions,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HistoryPage(
          recordsRepository: _FakeRecordsRepository(records),
          onGoToSuggestions: onGoToSuggestions,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

SuggestionRecord _record({
  required String id,
  required String title,
  required SuggestionRecordStatus status,
  int estimatedMinutes = 5,
  DateTime? createdAt,
}) {
  return SuggestionRecord(
    id: id,
    suggestionId: 'suggestion_$id',
    suggestionTitle: title,
    category: 'music',
    estimatedMinutes: estimatedMinutes,
    status: status,
    feedback:
        status == SuggestionRecordStatus.done ? SuggestionFeedback.good : null,
    createdAt: createdAt ?? DateTime(2026, 7, 1),
  );
}

void main() {
  testWidgets('サマリーに実施数・スキップ数・合計分が表示される', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'a',
          title: 'ジャズを1曲流す',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 15,
        ),
        _record(
          id: 'b',
          title: 'エッセイを読む',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 10,
        ),
        _record(
          id: 'c',
          title: 'ポップスを1曲流す',
          status: SuggestionRecordStatus.skipped,
        ),
      ],
    );

    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // 実施数
    expect(find.text('1'), findsOneWidget); // スキップ数
    expect(find.text('25'), findsOneWidget); // 合計分（done のみ）
    // サマリーラベルの「実施」＋ done 2件のバッジで計3つ。
    expect(find.text('実施'), findsNWidgets(3));
    expect(find.text('分'), findsOneWidget);
  });

  testWidgets('履歴一覧が新しい順に表示され、バッジと日付が出る', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'old',
          title: '古い提案',
          status: SuggestionRecordStatus.done,
          createdAt: DateTime(2026, 6, 5),
        ),
        _record(
          id: 'new',
          title: '新しい提案',
          status: SuggestionRecordStatus.skipped,
          createdAt: DateTime(2026, 6, 7),
        ),
      ],
    );

    expect(find.text('最近の履歴'), findsOneWidget);

    // 新しい順：スキップした「新しい提案」が上に来る。
    final newOffset = tester.getTopLeft(find.text('新しい提案'));
    final oldOffset = tester.getTopLeft(find.text('古い提案'));
    expect(newOffset.dy, lessThan(oldOffset.dy));

    // バッジ（サマリーの「実施」ラベルと合わせて2つ）と日付・カテゴリ・所要時間。
    expect(find.text('スキップ'), findsNWidgets(2));
    expect(find.text('6月7日　音楽・5分'), findsOneWidget);
    expect(find.text('6月5日　音楽・5分'), findsOneWidget);
  });

  testWidgets('履歴 0 件のときは空状態とサマリー 0 が表示される', (tester) async {
    await _pumpPage(tester, records: []);

    expect(find.text('まだ履歴はありません'), findsOneWidget);
    expect(find.text('よりみちを実行すると、ここに記録されます。'), findsOneWidget);
    expect(find.text('提案を見てみる'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('最近の履歴'), findsNothing);
  });

  testWidgets('「提案を見てみる」でコールバックが呼ばれる', (tester) async {
    var wasCalled = false;
    await _pumpPage(
      tester,
      records: [],
      onGoToSuggestions: () => wasCalled = true,
    );

    await tester.tap(find.text('提案を見てみる'));
    await tester.pumpAndSettle();

    expect(wasCalled, isTrue);
  });
}
