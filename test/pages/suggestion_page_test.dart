import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';
import 'package:yorimiti_biyori/src/pages/suggestion_page.dart';
import 'package:yorimiti_biyori/src/pages/suggestion_settings_page.dart';
import 'package:yorimiti_biyori/src/repositories/records_repository.dart';
import 'package:yorimiti_biyori/src/repositories/settings_repository.dart';
import 'package:yorimiti_biyori/src/repositories/suggestion_repository.dart';

/// 設定の読込値と保存履歴を差し替え・記録できるテスト用フェイク。
class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this.settings);

  UserSettings settings;
  final List<UserSettings> savedSettingsLog = [];

  @override
  Future<UserSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(UserSettings settings) async {
    this.settings = settings;
    savedSettingsLog.add(settings);
  }
}

/// 追加されたレコードをメモリ上に記録するテスト用フェイク。
class _FakeRecordsRepository implements RecordsRepository {
  final List<SuggestionRecord> addedRecords = [];

  @override
  Future<List<SuggestionRecord>> loadRecords() async => addedRecords;

  @override
  Future<void> addRecord(SuggestionRecord record) async {
    addedRecords.add(record);
  }

  @override
  Future<void> deleteAllRecords() async {
    addedRecords.clear();
  }
}

/// 固定の JSON 文字列を返す（または失敗する）テスト用 AssetBundle。
class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this._source);

  final String? _source;

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final source = _source;
    if (source == null) {
      throw FlutterError('asset load failed: $key');
    }
    return source;
  }

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async {
    return parser(await loadString(key));
  }
}

Map<String, dynamic> _suggestionJson({
  required String id,
  required String title,
  required List<String> tags,
  int budgetYen = 0,
}) {
  return {
    'id': id,
    'title': title,
    'description': '$titleの説明文。',
    'detail': '$titleの補足。',
    'category': 'music',
    'tags': tags,
    'budget_yen': budgetYen,
    'where_to_try': '音楽配信アプリで検索する。',
    'estimated_minutes': 5,
    'weight': 1.0,
  };
}

Future<_FakeSettingsRepository> _pumpPage(
  WidgetTester tester, {
  required List<Map<String, dynamic>> suggestions,
  required UserSettings settings,
  bool failAssetLoad = false,
  _FakeRecordsRepository? recordsRepository,
}) async {
  // ListView の下部（案内カード等）まで描画されるよう縦長の画面にする。
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final settingsRepository = _FakeSettingsRepository(settings);
  final suggestionRepository = SuggestionRepository(
    assetBundle:
        _FakeAssetBundle(failAssetLoad ? null : jsonEncode(suggestions)),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SuggestionPage(
          suggestionRepository: suggestionRepository,
          settingsRepository: settingsRepository,
          recordsRepository: recordsRepository ?? _FakeRecordsRepository(),
          random: Random(0),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settingsRepository;
}

void main() {
  testWidgets('条件カードと今日のよりみちカードが表示される', (tester) async {
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
        _suggestionJson(
          id: 'music_b',
          title: 'ポップスを1曲流す',
          tags: ['ポップス'],
          budgetYen: 300,
        ),
      ],
      settings: const UserSettings(
        selectedCategories: ['music'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
        },
      ),
    );

    // 条件カード：選択カテゴリのチップ＋詳細設定の要約。
    expect(find.text('現在の提案条件'), findsOneWidget);
    expect(find.text('🎵 音楽'), findsOneWidget);
    expect(find.text('詳細設定：ジャズ'), findsOneWidget);
    expect(find.text('提案設定 >'), findsOneWidget);

    // 今日のよりみちカード：ジャズ指定なので music_a が確定で選ばれる。
    expect(find.text('今日のよりみち'), findsOneWidget);
    expect(find.text('ジャズを1曲流す'), findsOneWidget);
    expect(find.text('ジャズを1曲流すの説明文。'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'ジャズ'), findsOneWidget);
    expect(find.text('約5分'), findsOneWidget);
    expect(find.text('入手先：音楽配信アプリで検索する。'), findsOneWidget);
    expect(find.text('予算：無料'), findsOneWidget);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('別の提案'), findsOneWidget);
  });

  testWidgets('詳細設定が未設定なら「指定なし」、予算は金額表示になる', (tester) async {
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(
          id: 'music_b',
          title: 'ポップスを1曲流す',
          tags: ['ポップス'],
          budgetYen: 300,
        ),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
    );

    expect(find.text('詳細設定：指定なし'), findsOneWidget);
    expect(find.text('予算：¥300'), findsOneWidget);
  });

  testWidgets('「別の提案」で直近と異なる提案に切り替わる', (tester) async {
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
        _suggestionJson(id: 'music_b', title: 'ポップスを1曲流す', tags: ['ポップス']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
    );

    final firstWasA = find.text('ジャズを1曲流す').evaluate().isNotEmpty;

    await tester.tap(find.text('別の提案'));
    await tester.pumpAndSettle();

    // 候補2件では直近除外により必ずもう一方に切り替わる。
    expect(
      find.text(firstWasA ? 'ポップスを1曲流す' : 'ジャズを1曲流す'),
      findsOneWidget,
    );
  });

  testWidgets('表示した提案IDが recent_suggestion_ids として3件まで保存される', (tester) async {
    final repository = await _pumpPage(
      tester,
      suggestions: [
        for (var i = 0; i < 4; i++)
          _suggestionJson(id: 'music_$i', title: '提案その$i', tags: ['ポップス']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
    );

    expect(repository.savedSettingsLog, hasLength(1));
    expect(repository.savedSettingsLog.last.recentSuggestionIds, hasLength(1));

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('別の提案'));
      await tester.pumpAndSettle();
    }

    // 4回表示しても直近リストは3件を超えない。
    final recentIds = repository.savedSettingsLog.last.recentSuggestionIds;
    expect(recentIds, hasLength(3));
    expect(recentIds.toSet(), hasLength(3));
  });

  testWidgets('条件に合う候補がないときは条件変更を促すメッセージを表示する', (tester) async {
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(
        selectedCategories: ['music'],
        detailSettings: {
          'music': {
            'genre': ['クラシック'],
          },
        },
      ),
    );

    expect(find.text('条件に合う提案が見つかりませんでした'), findsOneWidget);
    expect(find.text('カテゴリを増やすか、詳細設定を緩めてみてください。'), findsOneWidget);
    expect(find.text('提案設定を開く'), findsOneWidget);
    expect(find.text('今日のよりみち'), findsNothing);
  });

  testWidgets('カテゴリ未選択のときはカテゴリ設定を促す', (tester) async {
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: []),
    );

    expect(find.text('カテゴリが選ばれていません'), findsWidgets);
    expect(find.text('提案設定から、興味のあるカテゴリを選んでみてください。'), findsOneWidget);
    expect(find.text('提案設定を開く'), findsOneWidget);
  });

  testWidgets('提案データの読込失敗時はエラーメッセージを表示してクラッシュしない', (tester) async {
    await _pumpPage(
      tester,
      suggestions: const [],
      settings: const UserSettings(),
      failAssetLoad: true,
    );

    expect(find.text('データの読み込みに失敗しました。再起動してください。'), findsOneWidget);
  });

  testWidgets('やってみる→履歴に保存で done レコードが保存される', (tester) async {
    final recordsRepository = _FakeRecordsRepository();
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
    );

    await tester.tap(find.text('やってみる'));
    await tester.pumpAndSettle();
    expect(find.text('おつかれさまです'), findsOneWidget);

    await tester.tap(find.text('🙂 普通'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    expect(recordsRepository.addedRecords, hasLength(1));
    final savedRecord = recordsRepository.addedRecords.single;
    expect(savedRecord.suggestionId, 'music_a');
    expect(savedRecord.suggestionTitle, 'ジャズを1曲流す');
    expect(savedRecord.category, 'music');
    expect(savedRecord.estimatedMinutes, 5);
    expect(savedRecord.status, SuggestionRecordStatus.done);
    expect(savedRecord.feedback, SuggestionFeedback.normal);
  });

  testWidgets('完了モーダルを保存せず閉じると履歴は保存されない', (tester) async {
    final recordsRepository = _FakeRecordsRepository();
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
    );

    await tester.tap(find.text('やってみる'));
    await tester.pumpAndSettle();
    // モーダル外（背景）をタップして閉じる。
    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();

    expect(recordsRepository.addedRecords, isEmpty);
  });

  testWidgets('別の提案でスキップが記録されてから再抽選される', (tester) async {
    final recordsRepository = _FakeRecordsRepository();
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
        _suggestionJson(id: 'music_b', title: 'ポップスを1曲流す', tags: ['ポップス']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
    );

    final firstWasA = find.text('ジャズを1曲流す').evaluate().isNotEmpty;

    await tester.tap(find.text('別の提案'));
    await tester.pumpAndSettle();

    expect(recordsRepository.addedRecords, hasLength(1));
    final skippedRecord = recordsRepository.addedRecords.single;
    expect(skippedRecord.suggestionId, firstWasA ? 'music_a' : 'music_b');
    expect(skippedRecord.status, SuggestionRecordStatus.skipped);
    expect(skippedRecord.feedback, isNull);
  });

  testWidgets('提案設定から戻ると条件が再読込されて表示に反映される', (tester) async {
    final repository = await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
    );

    await tester.tap(find.text('提案設定 >'));
    await tester.pumpAndSettle();
    expect(find.byType(SuggestionSettingsPage), findsOneWidget);

    // 提案設定画面での保存に相当する設定変更をフェイクに反映してから戻る。
    repository.settings = repository.settings.copyWith(
      selectedCategories: ['music', 'walk'],
      detailSettings: {
        'music': {
          'genre': ['ジャズ'],
        },
      },
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('🚶 散歩'), findsOneWidget);
    expect(find.text('詳細設定：ジャズ'), findsOneWidget);
  });
}
