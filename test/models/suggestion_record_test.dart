import 'package:flutter_test/flutter_test.dart';

import 'package:yorimichi_biyori/src/models/suggestion_record.dart';

void main() {
  final doneJson = {
    'id': 'record_1',
    'suggestion_id': 'music_jazz_focus',
    'suggestion_title': '作業用にジャズを1曲だけ流す',
    'category': 'music',
    'estimated_minutes': 5,
    'status': 'done',
    'feedback': 'good',
    'created_at': '2026-07-01T12:00:00.000Z',
    'started_at': '2026-07-01T11:50:00.000Z',
    'completed_at': '2026-07-01T12:00:00.000Z',
  };

  test('done レコードの fromJson/toJson が往復する', () {
    final record = SuggestionRecord.fromJson(doneJson);

    expect(record, isNotNull);
    expect(record!.status, SuggestionRecordStatus.done);
    expect(record.feedback, SuggestionFeedback.good);
    expect(record.startedAt, DateTime.utc(2026, 7, 1, 11, 50));
    expect(record.completedAt, DateTime.utc(2026, 7, 1, 12));
    expect(record.toJson(), doneJson);
  });

  test('skipped レコードは feedback が null になる', () {
    final skippedJson = Map<String, dynamic>.from(doneJson)
      ..['status'] = 'skipped'
      ..['feedback'] = null
      ..['started_at'] = null
      ..['completed_at'] = null;

    final record = SuggestionRecord.fromJson(skippedJson);

    expect(record, isNotNull);
    expect(record!.status, SuggestionRecordStatus.skipped);
    expect(record.feedback, isNull);
    expect(record.startedAt, isNull);
    expect(record.completedAt, isNull);
    expect(record.toJson(), skippedJson);
  });

  test('任意の実測時刻が不正でもレコード自体は読み込む', () {
    final brokenJson = Map<String, dynamic>.from(doneJson)
      ..['started_at'] = 'not-a-date'
      ..['completed_at'] = 123;

    final record = SuggestionRecord.fromJson(brokenJson);

    expect(record, isNotNull);
    expect(record!.startedAt, isNull);
    expect(record.completedAt, isNull);
  });

  test('status が不正な値の場合は null を返す（例外を投げない）', () {
    final brokenJson = Map<String, dynamic>.from(doneJson)
      ..['status'] = 'unknown';

    expect(SuggestionRecord.fromJson(brokenJson), isNull);
  });

  test('created_at がパースできない場合は null を返す（例外を投げない）', () {
    final brokenJson = Map<String, dynamic>.from(doneJson)
      ..['created_at'] = 'not-a-date';

    expect(SuggestionRecord.fromJson(brokenJson), isNull);
  });

  test('必須フィールドが欠けている場合は null を返す（例外を投げない）', () {
    final brokenJson = Map<String, dynamic>.from(doneJson)
      ..remove('suggestion_id');

    expect(SuggestionRecord.fromJson(brokenJson), isNull);
  });
}
