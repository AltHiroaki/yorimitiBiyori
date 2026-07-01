import 'package:flutter_test/flutter_test.dart';

import 'package:yorimiti_biyori/src/models/suggestion_record.dart';

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
  };

  test('done レコードの fromJson/toJson が往復する', () {
    final record = SuggestionRecord.fromJson(doneJson);

    expect(record, isNotNull);
    expect(record!.status, SuggestionRecordStatus.done);
    expect(record.feedback, SuggestionFeedback.good);
    expect(record.toJson(), doneJson);
  });

  test('skipped レコードは feedback が null になる', () {
    final skippedJson = Map<String, dynamic>.from(doneJson)
      ..['status'] = 'skipped'
      ..['feedback'] = null;

    final record = SuggestionRecord.fromJson(skippedJson);

    expect(record, isNotNull);
    expect(record!.status, SuggestionRecordStatus.skipped);
    expect(record.feedback, isNull);
    expect(record.toJson(), skippedJson);
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
