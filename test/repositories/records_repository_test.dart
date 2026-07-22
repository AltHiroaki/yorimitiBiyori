import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';
import 'package:yorimichi_biyori/src/repositories/records_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  final skippedRecord = SuggestionRecord(
    id: 'record_2',
    suggestionId: 'read_essay_short',
    suggestionTitle: 'エッセイを1篇だけ読む',
    category: 'read',
    estimatedMinutes: 10,
    status: SuggestionRecordStatus.skipped,
    feedback: null,
    createdAt: DateTime.utc(2026, 7, 2, 18, 30),
  );

  test('追加した履歴を全件取得できる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = RecordsRepository();

    await repository.addRecord(doneRecord);
    await repository.addRecord(skippedRecord);
    final preferences = await SharedPreferences.getInstance();
    final savedJson = jsonDecode(
      preferences.getString(recordsPreferenceKey)!,
    ) as Map<String, dynamic>;
    final loadedRecords = await repository.loadRecords();

    expect(savedJson['version'], recordsSchemaVersion);
    expect(savedJson['records'], isA<List<dynamic>>());
    expect(loadedRecords, hasLength(2));
    expect(loadedRecords[0].id, 'record_1');
    expect(loadedRecords[0].status, SuggestionRecordStatus.done);
    expect(loadedRecords[0].feedback, SuggestionFeedback.good);
    expect(loadedRecords[1].id, 'record_2');
    expect(loadedRecords[1].status, SuggestionRecordStatus.skipped);
    expect(loadedRecords[1].feedback, isNull);
  });

  test('未保存のときは空リストを返す', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, isEmpty);
  });

  test('指定 ID の履歴だけを1件削除できる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = RecordsRepository();

    await repository.addRecord(doneRecord);
    await repository.addRecord(skippedRecord);
    await repository.deleteRecord('record_2');
    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, hasLength(1));
    expect(loadedRecords.single.id, 'record_1');
  });

  test('存在しない ID の削除は何もしない', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = RecordsRepository();

    await repository.addRecord(doneRecord);
    await repository.deleteRecord('missing_record');
    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, hasLength(1));
    expect(loadedRecords.single.id, 'record_1');
  });

  test('全削除すると履歴が空になる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = RecordsRepository();

    await repository.addRecord(doneRecord);
    await repository.deleteAllRecords();
    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, isEmpty);
  });

  test('JSON として壊れたデータは空リストにフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: '{{not json',
    });
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, isEmpty);
  });

  test('version 付き JSON の records 以外は空リストにフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: '{"id": "record_1"}',
    });
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, isEmpty);
  });

  test('旧形式（version なしのリスト）もこれまでどおり読み込める', () async {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode([
        {
          ...doneRecord.toJson(),
          'unknown_field': 'ignored',
        },
        skippedRecord.toJson(),
      ]),
    });
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, hasLength(2));
    expect(loadedRecords[0].id, 'record_1');
    expect(loadedRecords[1].id, 'record_2');
  });

  test('version 付き JSON も読み込める', () async {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode({
        'version': recordsSchemaVersion,
        'records': [doneRecord.toJson()],
        'unknown_field': 'ignored',
      }),
    });
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, hasLength(1));
    expect(loadedRecords.single.id, 'record_1');
  });

  test('未知の version は空リストにフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode({
        'version': 999,
        'records': [doneRecord.toJson()],
      }),
    });
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, isEmpty);
  });

  test('1件単位で壊れたレコードはスキップし、正常なレコードは維持する', () async {
    final brokenList = [
      doneRecord.toJson(),
      {'id': 'broken_record'},
      'not a map',
      {
        ...doneRecord.toJson(),
        'id': 'broken_status',
        'status': 'unknown',
      },
      skippedRecord.toJson(),
    ];
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: jsonEncode({
        'version': recordsSchemaVersion,
        'records': brokenList,
      }),
    });
    final repository = RecordsRepository();

    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, hasLength(2));
    expect(loadedRecords[0].id, 'record_1');
    expect(loadedRecords[1].id, 'record_2');
  });

  test('壊れたデータがあっても追加すると正常なレコードだけが保存し直される', () async {
    SharedPreferences.setMockInitialValues({
      recordsPreferenceKey: '{{not json',
    });
    final repository = RecordsRepository();

    await repository.addRecord(doneRecord);
    final loadedRecords = await repository.loadRecords();

    expect(loadedRecords, hasLength(1));
    expect(loadedRecords[0].id, 'record_1');
  });
}
