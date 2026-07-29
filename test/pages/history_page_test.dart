import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimichi_biyori/src/features/records/history_filter.dart';
import 'package:yorimichi_biyori/src/models/ongoing_suggestion.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';
import 'package:yorimichi_biyori/src/pages/history_page.dart';
import 'package:yorimichi_biyori/src/repositories/ongoing_suggestion_repository.dart';
import 'package:yorimichi_biyori/src/repositories/records_repository.dart';
import 'package:yorimichi_biyori/src/repositories/suggestion_repository.dart';

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
  DateTime? now,
  bool isActive = true,
}) async {
  final latestCreatedAt = records.isEmpty
      ? DateTime(2026, 7, 29, 12)
      : records
            .map((record) => record.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b)
            .add(const Duration(hours: 1));
  final suggestionRepository = SuggestionRepository(
    assetBundle: _FakeAssetBundle(
      failSuggestionLoad ? null : jsonEncode(suggestions),
    ),
    assetPaths: const ['test/suggestions.json'],
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HistoryPage(
          recordsRepository: _FakeRecordsRepository(records),
          suggestionRepository: suggestionRepository,
          ongoingSuggestionRepository:
              ongoingSuggestionRepository ?? _FakeOngoingSuggestionRepository(),
          onGoToSuggestions: onGoToSuggestions,
          onSuggestionRevived: onSuggestionRevived,
          highlightedRecordId: highlightedRecordId,
          isActive: isActive,
          nowProvider: () => now ?? latestCreatedAt,
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
  DateTime? startedAt,
  DateTime? completedAt,
  String category = 'music',
}) {
  return SuggestionRecord(
    id: id,
    suggestionId: suggestionId ?? 'suggestion_$id',
    suggestionTitle: title,
    category: category,
    estimatedMinutes: estimatedMinutes,
    status: status,
    feedback: status == SuggestionRecordStatus.done
        ? SuggestionFeedback.good
        : null,
    createdAt: createdAt ?? DateTime(2026, 7, 1),
    startedAt: startedAt,
    completedAt: completedAt,
  );
}

Map<String, dynamic> _suggestionJson({
  required String id,
  required String title,
  String category = 'music',
  List<String> tags = const ['ジャズ'],
  String? recipe,
}) {
  return {
    'id': id,
    'title': title,
    'description': '$titleの説明文。',
    'category': category,
    'tags': tags,
    'where_to_try': '音楽配信アプリで検索する。',
    'estimated_minutes': 5,
    'weight': 1.0,
    'recipe': ?recipe,
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
    expect(find.text('実測を優先し、記録がない場合は目安で集計'), findsOneWidget);
    // サマリーラベル＋フィルタ＋ done 2件のバッジで計4つ。
    expect(find.text('実施'), findsNWidgets(4));
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

    expect(find.text('今週の履歴'), findsOneWidget);

    // 新しい順：スキップした「新しい提案」が上に来る。
    final newOffset = tester.getTopLeft(find.text('新しい提案'));
    final oldOffset = tester.getTopLeft(find.text('古い提案'));
    expect(newOffset.dy, lessThan(oldOffset.dy));

    // バッジ（サマリーの「実施」ラベルと合わせて2つ）と日付・カテゴリ・所要時間。
    expect(find.text('スキップ'), findsNWidgets(3));
    expect(find.text('6月7日　音楽・目安 5分'), findsOneWidget);
    expect(find.text('6月5日　音楽・目安 5分'), findsOneWidget);
    // 実施済み・スキップともタップで詳細を開けるため、両行にシェブロンが付く。
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(2));
  });

  testWidgets('履歴行は実測と目安を区別し、サマリーも同じ時間を使う', (tester) async {
    final base = DateTime.utc(2026, 7, 29, 12);
    await _pumpPage(
      tester,
      now: base,
      records: [
        _record(
          id: 'actual',
          title: '実測できた提案',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 20,
          createdAt: base,
          startedAt: base.subtract(const Duration(minutes: 8)),
          completedAt: base,
        ),
        _record(
          id: 'estimated',
          title: '旧形式の提案',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 5,
          createdAt: base.subtract(const Duration(hours: 1)),
        ),
      ],
    );

    expect(find.text('7月29日　音楽・実測 8分'), findsOneWidget);
    expect(find.text('7月29日　音楽・目安 5分'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(find.text('音楽・実測 8分・目安 20分'), findsNothing);
  });

  testWidgets('履歴 0 件のときは空状態とサマリー 0 が表示される', (tester) async {
    await _pumpPage(tester, records: []);

    expect(find.text('まだ履歴はありません'), findsOneWidget);
    expect(find.text('よりみちを実行すると、ここに記録されます。'), findsOneWidget);
    expect(find.text('提案を見てみる'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(3));
    expect(find.text('最近の履歴'), findsNothing);
  });

  testWidgets('初期状態は今週・すべてで、全期間へ切り替えるとサマリーと一覧が連動する', (tester) async {
    final now = DateTime(2026, 7, 29, 12);
    await _pumpPage(
      tester,
      now: now,
      records: [
        _record(
          id: 'this-week-done',
          title: '今週の実施',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 15,
          createdAt: DateTime(2026, 7, 28),
        ),
        _record(
          id: 'this-week-skipped',
          title: '今週のスキップ',
          status: SuggestionRecordStatus.skipped,
          createdAt: DateTime(2026, 7, 29),
        ),
        _record(
          id: 'old-done',
          title: '以前の実施',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 10,
          createdAt: DateTime(2026, 7, 20),
        ),
      ],
    );

    final periodSelector = tester.widget<SegmentedButton<HistoryPeriod>>(
      find.byType(SegmentedButton<HistoryPeriod>),
    );
    expect(periodSelector.selected, {HistoryPeriod.thisWeek});
    expect(find.text('今週の実施'), findsOneWidget);
    expect(find.text('今週のスキップ'), findsOneWidget);
    expect(find.text('以前の実施'), findsNothing);
    expect(find.text('15'), findsOneWidget);

    await tester.tap(find.byKey(historyAllPeriodSegmentKey));
    await tester.pumpAndSettle();

    expect(find.text('最近の履歴'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('以前の実施'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('以前の実施'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
  });

  testWidgets('ステータスで一覧だけを絞り込み、期間サマリーは変えない', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done',
          title: '実施した提案',
          status: SuggestionRecordStatus.done,
          estimatedMinutes: 15,
        ),
        _record(
          id: 'skipped',
          title: 'スキップした提案',
          status: SuggestionRecordStatus.skipped,
        ),
      ],
    );

    await tester.tap(find.byKey(historyDoneStatusFilterKey));
    await tester.pumpAndSettle();

    expect(find.text('実施した提案'), findsOneWidget);
    expect(find.text('スキップした提案'), findsNothing);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));

    await tester.tap(find.byKey(historySkippedStatusFilterKey));
    await tester.pumpAndSettle();

    expect(find.text('実施した提案'), findsNothing);
    expect(find.text('スキップした提案'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('通常のタブ非アクティブ化と再読み込みではフィルタ状態を維持する', (tester) async {
    final records = [
      _record(id: 'done', title: '実施した提案', status: SuggestionRecordStatus.done),
      _record(
        id: 'skipped',
        title: 'スキップした提案',
        status: SuggestionRecordStatus.skipped,
      ),
    ];
    await _pumpPage(tester, records: records);
    await tester.tap(find.byKey(historyDoneStatusFilterKey));
    await tester.pumpAndSettle();

    await _pumpPage(tester, records: records, isActive: false);
    await _pumpPage(tester, records: records);

    expect(find.text('実施した提案'), findsOneWidget);
    expect(find.text('スキップした提案'), findsNothing);
    final doneFilter = tester.widget<FilterChip>(
      find.byKey(historyDoneStatusFilterKey),
    );
    expect(doneFilter.selected, isTrue);
  });

  testWidgets('新しいハイライト対象がフィルタに隠れる場合はすべて表示へ補正する', (tester) async {
    final records = [
      _record(
        id: 'done',
        title: '保存したばかりの提案',
        status: SuggestionRecordStatus.done,
      ),
      _record(
        id: 'skipped',
        title: 'スキップした提案',
        status: SuggestionRecordStatus.skipped,
      ),
    ];
    await _pumpPage(tester, records: records);
    await tester.tap(find.byKey(historySkippedStatusFilterKey));
    await tester.pumpAndSettle();
    expect(find.text('保存したばかりの提案'), findsNothing);

    await _pumpPage(tester, records: records, highlightedRecordId: 'done');

    expect(find.text('保存したばかりの提案'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('history-record-done')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is TweenAnimationBuilder<double>,
      ),
      findsOneWidget,
    );
    final allFilter = tester.widget<FilterChip>(
      find.byKey(historyAllStatusFilterKey),
    );
    expect(allFilter.selected, isTrue);
  });

  testWidgets('今週が0件なら全体空状態と区別し、全期間へ切り替えられる', (tester) async {
    await _pumpPage(
      tester,
      now: DateTime(2026, 7, 29, 12),
      records: [
        _record(
          id: 'old',
          title: '以前の履歴',
          status: SuggestionRecordStatus.done,
          createdAt: DateTime(2026, 7, 20),
        ),
      ],
    );

    expect(find.text('今週の履歴はありません'), findsOneWidget);
    expect(find.text('まだ履歴はありません'), findsNothing);

    await tester.tap(find.text('全期間を見る'));
    await tester.pumpAndSettle();

    expect(find.text('以前の履歴'), findsOneWidget);
  });

  testWidgets('ステータスの結果が0件ならすべて表示へ戻せる', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done',
          title: '実施した提案',
          status: SuggestionRecordStatus.done,
        ),
      ],
    );

    await tester.tap(find.byKey(historySkippedStatusFilterKey));
    await tester.pumpAndSettle();

    expect(find.text('この条件の履歴はありません'), findsOneWidget);
    expect(find.text('まだ履歴はありません'), findsNothing);

    await tester.tap(find.text('すべて表示'));
    await tester.pumpAndSettle();

    expect(find.text('実施した提案'), findsOneWidget);
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
      tester.widget<TweenAnimationBuilder<double>>(highlightAnimation).duration,
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

  testWidgets('スキップ行から詳細と確認を経て実施中へ復活でき、元の履歴は残る', (tester) async {
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
    expect(find.text('ジャズを1曲流すの説明文。'), findsOneWidget);
    expect(find.text('目安 約5分'), findsOneWidget);
    expect(find.text('入手先：音楽配信アプリで検索する。'), findsOneWidget);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('スキップして次の提案'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'やってみる'));
    await tester.pumpAndSettle();

    expect(find.text('この提案を実施しますか？'), findsOneWidget);
    expect(find.textContaining('もう一度実施します。'), findsOneWidget);
    expect(find.textContaining('実施中の提案と置き換わります。'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '実施する'));
    await tester.pumpAndSettle();

    expect(ongoingRepository.ongoing, isNotNull);
    expect(ongoingRepository.ongoing!.suggestionId, 'music_a');
    expect(ongoingRepository.ongoing!.startedAt.isUtc, isTrue);
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

    expect(find.textContaining('実施中の提案と置き換わります。'), findsOneWidget);
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
      suggestions: [_suggestionJson(id: 'music_a', title: 'ジャズを1曲流す')],
    );

    await tester.tap(find.text('ジャズを1曲流す'));
    await tester.pumpAndSettle();

    expect(find.text('実施したよりみち'), findsOneWidget);
    expect(find.text('6月5日に実施'), findsOneWidget);
    expect(find.text('ジャズを1曲流すの説明文。'), findsOneWidget);
    expect(find.text('目安 約5分'), findsOneWidget);
    expect(find.text('入手先：音楽配信アプリで検索する。'), findsOneWidget);
    expect(find.text('感想：😊 よかった'), findsOneWidget);
    // 閲覧専用：復活フローのボタンは出さない。
    expect(find.text('やってみる'), findsNothing);
    expect(find.text('スキップした提案'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '閉じる'));
    await tester.pumpAndSettle();

    expect(find.text('実施したよりみち'), findsNothing);
  });

  testWidgets('実施済みの料理履歴はレシピを「詳しく見る」で展開・収納できる', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done-cook',
          suggestionId: 'cook_a',
          title: '味噌汁をつくる',
          status: SuggestionRecordStatus.done,
          category: 'cook',
        ),
      ],
      suggestions: [
        _suggestionJson(
          id: 'cook_a',
          title: '味噌汁をつくる',
          category: 'cook',
          tags: const ['和食'],
          recipe: '1. だしを取る\n2. 具材を煮る\n3. 味噌を溶く',
        ),
      ],
    );

    await tester.tap(find.text('味噌汁をつくる'));
    await tester.pumpAndSettle();

    // 初期状態はレシピ本文を閉じておく。
    expect(find.text('詳しく見る'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('suggestion-recipe-content')),
      findsNothing,
    );
    expect(find.text('レシピ'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('レシピ'), findsOneWidget);
    expect(find.text('1. だしを取る\n2. 具材を煮る\n3. 味噌を溶く'), findsOneWidget);
    expect(find.text('レシピを閉じる'), findsOneWidget);
    // 既存の表示要素は展開後も残る。
    expect(find.text('味噌汁をつくるの説明文。'), findsOneWidget);
    expect(find.text('目安 約5分'), findsOneWidget);
    expect(find.text('感想：😊 よかった'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('詳しく見る'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('suggestion-recipe-content')),
      findsNothing,
    );
  });

  testWidgets('長いレシピを展開してもダイアログ内でスクロールでき、はみ出さない', (tester) async {
    final longRecipe = List<String>.generate(
      40,
      (index) => '${index + 1}. 手順の説明テキストをここに書く。',
    ).join('\n');

    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done-cook-long',
          suggestionId: 'cook_long',
          title: '煮込みハンバーグをつくる',
          status: SuggestionRecordStatus.done,
          category: 'cook',
        ),
      ],
      suggestions: [
        _suggestionJson(
          id: 'cook_long',
          title: '煮込みハンバーグをつくる',
          category: 'cook',
          tags: const ['洋食'],
          recipe: longRecipe,
        ),
      ],
    );

    await tester.tap(find.text('煮込みハンバーグをつくる'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
    );
    await tester.pumpAndSettle();

    // オーバーフロー（RenderFlex overflowed）が起きていないこと。
    expect(tester.takeException(), isNull);

    // ダイアログ内をスクロールすると下端の「閉じる」まで到達できる。
    final dialogScrollView = find.descendant(
      of: find.byKey(const ValueKey<String>('done-record-detail-dialog')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, '閉じる'),
      300,
      scrollable: dialogScrollView.first,
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '閉じる'), findsOneWidget);
  });

  testWidgets('スキップした料理履歴もレシピを「詳しく見る」で展開・収納できる', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'skipped-cook',
          suggestionId: 'cook_a',
          title: '味噌汁をつくる',
          status: SuggestionRecordStatus.skipped,
          category: 'cook',
        ),
      ],
      suggestions: [
        _suggestionJson(
          id: 'cook_a',
          title: '味噌汁をつくる',
          category: 'cook',
          tags: const ['和食'],
          recipe: '1. だしを取る\n2. 具材を煮る\n3. 味噌を溶く',
        ),
      ],
    );

    await tester.tap(find.text('味噌汁をつくる'));
    await tester.pumpAndSettle();

    expect(find.text('スキップした提案'), findsOneWidget);
    // 初期状態はレシピ本文を閉じておく。
    expect(find.text('詳しく見る'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('suggestion-recipe-content')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('レシピ'), findsOneWidget);
    expect(find.text('1. だしを取る\n2. 具材を煮る\n3. 味噌を溶く'), findsOneWidget);
    // 復活フローのボタンはレシピ展開後も残る。
    expect(find.widgetWithText(FilledButton, 'やってみる'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('詳しく見る'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('suggestion-recipe-content')),
      findsNothing,
    );
  });

  testWidgets('レシピを持たないスキップ履歴にはレシピ操作を表示しない', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'skipped-music',
          suggestionId: 'music_a',
          title: 'ジャズを1曲流す',
          status: SuggestionRecordStatus.skipped,
        ),
      ],
      suggestions: [_suggestionJson(id: 'music_a', title: 'ジャズを1曲流す')],
    );

    await tester.tap(find.text('ジャズを1曲流す'));
    await tester.pumpAndSettle();

    expect(find.text('スキップした提案'), findsOneWidget);
    expect(find.text('詳しく見る'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
      findsNothing,
    );
  });

  testWidgets('レシピを持たない実施済み履歴にはレシピ操作を表示しない', (tester) async {
    await _pumpPage(
      tester,
      records: [
        _record(
          id: 'done-music',
          suggestionId: 'music_a',
          title: 'ジャズを1曲流す',
          status: SuggestionRecordStatus.done,
        ),
      ],
      suggestions: [_suggestionJson(id: 'music_a', title: 'ジャズを1曲流す')],
    );

    await tester.tap(find.text('ジャズを1曲流す'));
    await tester.pumpAndSettle();

    expect(find.text('実施したよりみち'), findsOneWidget);
    expect(find.text('詳しく見る'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('suggestion-recipe-toggle')),
      findsNothing,
    );
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
