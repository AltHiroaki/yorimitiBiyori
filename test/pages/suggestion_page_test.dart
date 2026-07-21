import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yorimiti_biyori/src/models/ongoing_suggestion.dart';
import 'package:yorimiti_biyori/src/models/suggestion_record.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';
import 'package:yorimiti_biyori/src/pages/suggestion_page.dart';
import 'package:yorimiti_biyori/src/pages/suggestion_settings_page.dart';
import 'package:yorimiti_biyori/src/repositories/current_suggestion_repository.dart';
import 'package:yorimiti_biyori/src/repositories/ongoing_suggestion_repository.dart';
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
  Future<void> deleteRecord(String recordId) async {
    addedRecords.removeWhere((record) => record.id == recordId);
  }

  @override
  Future<void> deleteAllRecords() async {
    addedRecords.clear();
  }
}

class _FakeCurrentSuggestionRepository implements CurrentSuggestionRepository {
  _FakeCurrentSuggestionRepository([this.currentSuggestionId]);

  String? currentSuggestionId;
  final List<String?> savedSuggestionIdLog = [];

  @override
  Future<String?> loadCurrentSuggestionId() async => currentSuggestionId;

  @override
  Future<void> saveCurrentSuggestionId(String suggestionId) async {
    currentSuggestionId = suggestionId;
    savedSuggestionIdLog.add(suggestionId);
  }

  @override
  Future<void> clearCurrentSuggestion() async {
    currentSuggestionId = null;
    savedSuggestionIdLog.add(null);
  }
}

/// 実施中よりみちをメモリ上で保持するテスト用フェイク。
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

/// 固定の JSON 文字列を返す（または失敗する）テスト用 AssetBundle。
class _FakeAssetBundle extends AssetBundle {
  _FakeAssetBundle(this._source);

  final String? _source;

  @override
  Future<ByteData> load(String key) async {
    final source = _source;
    if (source == null) {
      throw FlutterError('asset load failed: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

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
  String? detail,
  String category = 'music',
  int budgetYen = 0,
}) {
  return {
    'id': id,
    'title': title,
    'description': '$titleの説明文。',
    'detail': detail ?? '$titleの補足。',
    'category': category,
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
  _FakeCurrentSuggestionRepository? currentSuggestionRepository,
  _FakeOngoingSuggestionRepository? ongoingSuggestionRepository,
  ValueChanged<String>? onSuggestionCompleted,
}) async {
  // ListView の下部（案内カード等）まで描画されるよう縦長の画面にする。
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final settingsRepository = _FakeSettingsRepository(settings);
  final suggestionRepository = SuggestionRepository(
    assetBundle: _FakeAssetBundle(
      failAssetLoad ? null : jsonEncode(suggestions),
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SuggestionPage(
          suggestionRepository: suggestionRepository,
          settingsRepository: settingsRepository,
          recordsRepository: recordsRepository ?? _FakeRecordsRepository(),
          currentSuggestionRepository:
              currentSuggestionRepository ?? _FakeCurrentSuggestionRepository(),
          ongoingSuggestionRepository:
              ongoingSuggestionRepository ?? _FakeOngoingSuggestionRepository(),
          random: Random(0),
          onSuggestionCompleted: onSuggestionCompleted,
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

  testWidgets('詳しく見るをタップすると提案のdetailを展開・収納できる', (tester) async {
    const recipe = '材料：卵2個、だし大さじ2。\n手順：1. 材料を混ぜる。2. 弱火で焼く。';
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(
          id: 'cook_recipe',
          title: '卵焼きを作る',
          tags: ['和食', '焼く'],
          detail: recipe,
          category: 'cook',
        ),
      ],
      settings: const UserSettings(selectedCategories: ['cook']),
    );

    expect(find.text('詳しく見る'), findsOneWidget);
    expect(find.text(recipe), findsNothing);

    await tester.tap(find.text('詳しく見る'));
    await tester.pumpAndSettle();

    expect(find.text('詳しい内容'), findsOneWidget);
    expect(find.text(recipe), findsOneWidget);

    await tester.tap(find.text('詳しい内容を閉じる'));
    await tester.pumpAndSettle();

    expect(find.text(recipe), findsNothing);
    expect(find.text('詳しく見る'), findsOneWidget);
  });

  testWidgets('detailが空または空白のみなら詳細UIを表示しない', (tester) async {
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(
          id: 'music_without_detail',
          title: '詳細のない提案',
          tags: ['ポップス'],
          detail: '   ',
        ),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
    );

    expect(find.text('詳しく見る'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('suggestion-detail-content')),
      findsNothing,
    );
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
    expect(find.text(firstWasA ? 'ポップスを1曲流す' : 'ジャズを1曲流す'), findsOneWidget);
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

    expect(repository.savedSettingsLog, isEmpty);

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

  testWidgets('やってみるで実施中カードに切り替わり、実施中状態が保存される', (tester) async {
    final ongoingRepository = _FakeOngoingSuggestionRepository();
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      ongoingSuggestionRepository: ongoingRepository,
    );

    await tester.tap(find.text('やってみる'));
    await tester.pumpAndSettle();

    expect(find.text('実施中のよりみち'), findsOneWidget);
    expect(find.text('ジャズを1曲流す'), findsOneWidget);
    expect(find.text('完了'), findsOneWidget);
    expect(find.text('スキップ'), findsOneWidget);
    expect(find.text('やってみる'), findsNothing);
    expect(find.text('別の提案'), findsNothing);
    expect(ongoingRepository.ongoing, isNotNull);
    expect(ongoingRepository.ongoing!.suggestionId, 'music_a');
  });

  testWidgets('実施中の完了→履歴に保存で done レコードが保存され、完了演出後に履歴IDが渡る', (tester) async {
    final recordsRepository = _FakeRecordsRepository();
    final ongoingRepository = _FakeOngoingSuggestionRepository();
    String? completedRecordId;
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
      ongoingSuggestionRepository: ongoingRepository,
      onSuggestionCompleted: (recordId) => completedRecordId = recordId,
    );

    await tester.tap(find.text('やってみる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('完了'));
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

    // 実施中は解除され、保存した履歴 ID がタブ遷移側へ渡る。
    expect(ongoingRepository.ongoing, isNull);
    expect(completedRecordId, savedRecord.id);
    // 保存成功のフィードバックとして SnackBar を表示する（issue #44）。
    expect(find.text('履歴に保存しました'), findsOneWidget);
  });

  testWidgets('スキップから復活した実施中を完了すると元のスキップ履歴が削除される', (tester) async {
    final skippedRecord = SuggestionRecord(
      id: 'record_skip',
      suggestionId: 'music_a',
      suggestionTitle: 'ジャズを1曲流す',
      category: 'music',
      estimatedMinutes: 5,
      status: SuggestionRecordStatus.skipped,
      feedback: null,
      createdAt: DateTime(2026, 7, 10),
    );
    final recordsRepository = _FakeRecordsRepository()
      ..addedRecords.add(skippedRecord);
    final ongoingRepository = _FakeOngoingSuggestionRepository(
      OngoingSuggestion(
        suggestionId: 'music_a',
        startedAt: DateTime(2026, 7, 15, 17, 30),
        revivedFromRecordId: 'record_skip',
      ),
    );
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
      ongoingSuggestionRepository: ongoingRepository,
    );

    await tester.tap(find.text('完了'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('履歴に保存'));
    await tester.pumpAndSettle();

    // 元のスキップ履歴は消え、done レコードだけが残る。
    expect(recordsRepository.addedRecords, hasLength(1));
    final savedRecord = recordsRepository.addedRecords.single;
    expect(savedRecord.status, SuggestionRecordStatus.done);
    expect(savedRecord.suggestionId, 'music_a');
  });

  testWidgets('スキップから復活した実施中を再スキップした場合は元のスキップ履歴を残す', (tester) async {
    final skippedRecord = SuggestionRecord(
      id: 'record_skip',
      suggestionId: 'music_a',
      suggestionTitle: 'ジャズを1曲流す',
      category: 'music',
      estimatedMinutes: 5,
      status: SuggestionRecordStatus.skipped,
      feedback: null,
      createdAt: DateTime(2026, 7, 10),
    );
    final recordsRepository = _FakeRecordsRepository()
      ..addedRecords.add(skippedRecord);
    final ongoingRepository = _FakeOngoingSuggestionRepository(
      OngoingSuggestion(
        suggestionId: 'music_a',
        startedAt: DateTime(2026, 7, 15, 17, 30),
        revivedFromRecordId: 'record_skip',
      ),
    );
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
      ongoingSuggestionRepository: ongoingRepository,
    );

    await tester.tap(find.text('スキップ'));
    await tester.pumpAndSettle();

    // 完了には至っていないので、元のスキップ履歴は削除しない。
    expect(
      recordsRepository.addedRecords.map((record) => record.id),
      contains('record_skip'),
    );
    expect(recordsRepository.addedRecords, hasLength(2));
  });

  testWidgets('完了モーダルを保存せず閉じると履歴は保存されず実施中のまま', (tester) async {
    final recordsRepository = _FakeRecordsRepository();
    final ongoingRepository = _FakeOngoingSuggestionRepository();
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
      ongoingSuggestionRepository: ongoingRepository,
    );

    await tester.tap(find.text('やってみる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('完了'));
    await tester.pumpAndSettle();
    // モーダル外（背景）をタップして閉じる。
    await tester.tapAt(const Offset(400, 20));
    await tester.pumpAndSettle();

    expect(recordsRepository.addedRecords, isEmpty);
    expect(find.text('実施中のよりみち'), findsOneWidget);
    expect(ongoingRepository.ongoing, isNotNull);
  });

  testWidgets('実施中のスキップで skipped が保存され、通常の提案表示に戻る', (tester) async {
    final recordsRepository = _FakeRecordsRepository();
    final ongoingRepository = _FakeOngoingSuggestionRepository();
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
        _suggestionJson(id: 'music_b', title: 'ポップスを1曲流す', tags: ['ポップス']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      recordsRepository: recordsRepository,
      ongoingSuggestionRepository: ongoingRepository,
    );

    await tester.tap(find.text('やってみる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('スキップ'));
    await tester.pumpAndSettle();

    expect(recordsRepository.addedRecords, hasLength(1));
    expect(
      recordsRepository.addedRecords.single.status,
      SuggestionRecordStatus.skipped,
    );
    expect(ongoingRepository.ongoing, isNull);
    // 実施中カードが消え、通常の提案カード（やってみる／別の提案）に戻る。
    expect(find.text('実施中のよりみち'), findsNothing);
    expect(find.text('やってみる'), findsOneWidget);
    expect(find.text('別の提案'), findsOneWidget);
  });

  testWidgets('保存済みの実施中状態が起動時に復元される', (tester) async {
    final ongoingRepository = _FakeOngoingSuggestionRepository(
      OngoingSuggestion(
        suggestionId: 'music_a',
        startedAt: DateTime(2026, 7, 15, 17, 30),
      ),
    );
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      ongoingSuggestionRepository: ongoingRepository,
    );

    expect(find.text('実施中のよりみち'), findsOneWidget);
    expect(find.text('ジャズを1曲流す'), findsOneWidget);
    expect(find.text('開始：17:30'), findsOneWidget);
    expect(find.text('完了'), findsOneWidget);
    expect(find.text('スキップ'), findsOneWidget);
  });

  testWidgets('実施中の提案IDが提案データに存在しない場合は実施中を解除して通常表示に戻る', (tester) async {
    final ongoingRepository = _FakeOngoingSuggestionRepository(
      OngoingSuggestion(
        suggestionId: 'deleted_id',
        startedAt: DateTime(2026, 7, 15, 17, 30),
      ),
    );
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      ongoingSuggestionRepository: ongoingRepository,
    );

    expect(find.text('実施中のよりみち'), findsNothing);
    expect(find.text('今日のよりみち'), findsOneWidget);
    expect(ongoingRepository.ongoing, isNull);
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
    // スキップはカードの切り替わり自体がフィードバックのため SnackBar は出さない（issue #44）。
    expect(find.text('履歴に保存しました'), findsNothing);
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

  testWidgets('表示中提案IDが復元され、直近リストを消費しない', (tester) async {
    final currentSuggestionRepository = _FakeCurrentSuggestionRepository(
      'music_b',
    );
    final settingsRepository = await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
        _suggestionJson(id: 'music_b', title: 'ポップスを1曲流す', tags: ['ポップス']),
      ],
      settings: const UserSettings(selectedCategories: ['music']),
      currentSuggestionRepository: currentSuggestionRepository,
    );

    expect(find.text('ポップスを1曲流す'), findsOneWidget);
    expect(find.text('ジャズを1曲流す'), findsNothing);
    expect(settingsRepository.savedSettingsLog, isEmpty);
    expect(currentSuggestionRepository.savedSuggestionIdLog, ['music_b']);
  });

  testWidgets('保存された表示中提案が現在条件に合わなければ再抽選する', (tester) async {
    final currentSuggestionRepository = _FakeCurrentSuggestionRepository(
      'music_b',
    );
    await _pumpPage(
      tester,
      suggestions: [
        _suggestionJson(id: 'music_a', title: 'ジャズを1曲流す', tags: ['ジャズ']),
        _suggestionJson(id: 'music_b', title: 'ポップスを1曲流す', tags: ['ポップス']),
      ],
      settings: const UserSettings(
        selectedCategories: ['music'],
        detailSettings: {
          'music': {
            'genre': ['ジャズ'],
          },
        },
      ),
      currentSuggestionRepository: currentSuggestionRepository,
    );

    expect(find.text('ジャズを1曲流す'), findsOneWidget);
    expect(currentSuggestionRepository.currentSuggestionId, 'music_a');
  });
}
