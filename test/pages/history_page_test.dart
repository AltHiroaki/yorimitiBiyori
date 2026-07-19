import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/ongoing_suggestion.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/pages/history_page.dart';
import 'package:yorimiti_biyori/src/repositories/ongoing_suggestion_repository.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';
import 'package:yorimiti_biyori/src/repositories/suggestion_repository.dart';

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
  Future<void> deleteRecord(String recordId) async {
    records.removeWhere((record) => record.id == recordId);
  }

  @override
  Future<void> deleteAllRecords() async {
    records.clear();
  }
}

class _FakeOngoingSuggestionRepository implements OngoingSuggestionRepository {
  _FakeOngoingSuggestionRepository([this.ongoing]);

  OngoingSuggestion? ongoing;

  @override
  Future<OngoingSuggestion?> loadOngoingSuggestion() async => ongoing;

  @override
  Future<void> saveOngoingSuggestion(OngoingSuggestion ongoing) async {
    this.ongoing = ongoing;
  }

  @override
  Future<void> clearOngoingSuggestion() async {
    ongoing = null;
  }
}

class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this.source);

  final String? source;

  @override
  Future<ByteData> load(String key) async {
    final source = this.source;
    if (source == null) {
      throw FlutterError('asset load failed: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final source = this.source;
    if (source == null) {
      throw FlutterError('asset load failed: $key');
    }
    return source;
  }
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required List<SuggestionRecord> records,
  VoidCallback? onGoToSuggestions,
  VoidCallback? onSuggestionRevived,
  String? highlightedRecordId,
  List<Map<String, dynamic>> suggestions = const [],
  _FakeOngoingSuggestionRepository? ongoingSuggestionRepository,
  bool failSuggestionLoad = false,
}) async {
  final suggestionRepository = SuggestionRepository(
    assetBundle: _FakeAssetBundle(
      failSuggestionLoad ? null : jsonEncode(suggestions),
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HistoryPage(
          recordsRepository: _FakeRecordsRepository(records),
          suggestionRepository: suggestionRepository,
          ongoingSuggestionRepository:
              ongoingSuggestionRepository ??
              _FakeOngoingSuggestionRepository(),
          onGoToSuggestions: onGoToSuggestions,
          onSuggestionRevived: onSuggestionRevived,
          highlightedRecordId: highlightedRecordId,
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
  String? suggestionId,
  int estimatedMinutes = 5,
  DateTime? createdAt,
}) {
  return SuggestionRecord(
    id: id,
    suggestionId: suggestionId ?? 'suggestion_$id',
    suggestionTitle: title,
    category: 'music',
    estimatedMinutes: estimatedMinutes,
    status: status,
    feedback:
        status == SuggestionRecordStatus.done ? SuggestionFeedback.good : null,
    createdAt: createdAt ?? DateTime(2026, 7, 1),
  );
}

Map<String, dynamic> _suggestionJson({
  required String id,
  required String title,
}) {
  return {
    'id': id,
    'title': title,
    'description': '$titleの説明文。',
    'detail': '$titleの補足。',
    'category': 'music',
    'tags': ['ジャズ'],
    'budget_yen': 0,
    'where_to_try': '音楽配信アプリで検索する。',
    'estimated_minutes': 5,
    'weight': 1.0,
  };
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
    // 実施済み・スキップともタップで詳細を開けるため、両行にシェブロンが付く。
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
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

  testWidgets('指定した直近レコードだけが1.5秒の背景ハイライト対象になる', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'highlighted',
          title: '保存したばかりの提案',
          status: SuggestionRecordStatus.done,
        ),
        _record(
          id: 'normal',
          title: '以前の提案',
          status: SuggestionRecordStatus.done,
        ),
      ],
      highlightedRecordId: 'highlighted',
    );

    final highlightAnimation = find.byWidgetPredicate(
      (widget) => widget is TweenAnimationBuilder<double>,
    );
    expect(highlightAnimation, findsOneWidget);
    expect(
      tester
          .widget<TweenAnimationBuilder<double>>(highlightAnimation)
          .duration,
      historyNewRecordHighlightDuration,
    );
    expect(
      find.byKey(const ValueKey<String>('history-record-highlighted')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('history-record-normal')),
      findsOneWidget,
    );
  });

  testWidgets('スキップ行から詳細と確認を経て実施中へ復活でき、元の履歴は残る',
      (tester) async {
    final records = [
      _record(
        id: 'skipped',
        suggestionId: 'music_a',
        title: 'ジャズを1曲流す',
        status: SuggestionRecordStatus.skipped,
      ),
    ];
    final ongoingRepository = _FakeOngoingSuggestionRepository();
    var wasRevived = false;
    await _pumpPage(
      tester,
      records: records,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す'),
      ],
      ongoingSuggestionRepository: ongoingRepository,
      onSuggestionRevived: () => wasRevived = true,
    );

    await tester.tap(find.text('ジャズを1曲流す'));
    await tester.pumpAndSettle();

    expect(find.text('スキップした提案'), findsOneWidget);
    expect(find.text('入手先：音楽配信アプリで検索する。'), findsOneWidget);
    expect(find.text('予算：無料'), findsOneWidget);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('別の提案'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'やってみる'));
    await tester.pumpAndSettle();

    expect(find.text('この提案を実施しますか？'), findsOneWidget);
    expect(find.textContaining('もう一度実施します。'), findsOneWidget);
    expect(find.textContaining('実施中の提案と置き換わります。'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '実施する'));
    await tester.pumpAndSettle();

    expect(ongoingRepository.ongoing, isNotNull);
    expect(ongoingRepository.ongoing!.suggestionId, 'music_a');
    // 完了時に元のスキップ履歴を削除できるよう、復活元の履歴 ID を記録する。
    expect(ongoingRepository.ongoing!.revivedFromRecordId, 'skipped');
    expect(wasRevived, isTrue);
    expect(records, hasLength(1));
    expect(records.single.status, SuggestionRecordStatus.skipped);
  });

  testWidgets('別の提案が実施中なら確認時に置き換えを明示する', (tester) async {
    final ongoingRepository = _FakeOngoingSuggestionRepository(
      OngoingSuggestion(
        suggestionId: 'music_existing',
        startedAt: DateTime(2026, 7, 1),
      ),
    );
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'skipped',
          suggestionId: 'music_a',
          title: 'ジャズを1曲流す',
          status: SuggestionRecordStatus.skipped,
        ),
      ],
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す'),
      ],
      ongoingSuggestionRepository: ongoingRepository,
    );

    await tester.tap(find.text('ジャズを1曲流す'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'やってみる'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('実施中の提案と置き換わります。'),
      findsOneWidget,
    );
  });

  testWidgets('提案IDが現行データにないスキップ履歴は利用不可を表示する', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'deleted',
          suggestionId: 'deleted_suggestion',
          title: '削除済みの提案',
          status: SuggestionRecordStatus.skipped,
        ),
      ],
    );

    await tester.tap(find.text('削除済みの提案'));
    await tester.pumpAndSettle();

    expect(find.text('この提案は現在利用できません'), findsOneWidget);
    expect(find.text('提案データの更新により、この提案は削除されました。'), findsOneWidget);
  });

  testWidgets('実施済み行をタップするとやった内容と感想を閲覧できる', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done',
          suggestionId: 'music_a',
          title: 'ジャズを1曲流す',
          status: SuggestionRecordStatus.done,
          createdAt: DateTime(2026, 6, 5),
        ),
      ],
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す'),
      ],
    );

    await tester.tap(find.text('ジャズを1曲流す'));
    await tester.pumpAndSettle();

    expect(find.text('実施したよりみち'), findsOneWidget);
    expect(find.text('6月5日に実施'), findsOneWidget);
    expect(find.text('入手先：音楽配信アプリで検索する。'), findsOneWidget);
    expect(find.text('予算：無料'), findsOneWidget);
    expect(find.text('感想：😊 よかった'), findsOneWidget);
    // 閲覧専用：復活フローのボタンは出さない。
    expect(find.text('やってみる'), findsNothing);
    expect(find.text('スキップした提案'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '閉じる'));
    await tester.pumpAndSettle();

    expect(find.text('実施したよりみち'), findsNothing);
  });

  testWidgets('提案IDが現行データにない実施済み履歴は利用不可を表示する', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done-deleted',
          suggestionId: 'deleted_suggestion',
          title: '削除済みの実施提案',
          status: SuggestionRecordStatus.done,
        ),
      ],
    );

    await tester.tap(find.text('削除済みの実施提案'));
    await tester.pumpAndSettle();

    expect(find.text('この提案は現在利用できません'), findsOneWidget);
  });
}
