import 'package:flutter_test/flutter_test.dart';

import 'package:yorimichi_biyori/src/models/ongoing_suggestion.dart';

void main() {
  test('fromJson/toJson が往復する', () {
    final json = {
      'suggestion_id': 'music_jazz_focus',
      'started_at': '2026-07-15T17:30:00.000Z',
    };

    final ongoing = OngoingSuggestion.fromJson(json);

    expect(ongoing, isNotNull);
    expect(ongoing!.suggestionId, 'music_jazz_focus');
    expect(ongoing.startedAt, DateTime.utc(2026, 7, 15, 17, 30));
    // 復活元 ID を持たない既存データは null として読め、toJson でもキーを出さない。
    expect(ongoing.revivedFromRecordId, isNull);
    expect(ongoing.toJson(), json);
  });

  test('revived_from_record_id 付きで往復する', () {
    final json = {
      'suggestion_id': 'music_jazz_focus',
      'started_at': '2026-07-15T17:30:00.000Z',
      'revived_from_record_id': 'record_123',
    };

    final ongoing = OngoingSuggestion.fromJson(json);

    expect(ongoing, isNotNull);
    expect(ongoing!.revivedFromRecordId, 'record_123');
    expect(ongoing.toJson(), json);
  });

  test('必須フィールドが欠けている場合は null を返す（例外を投げない）', () {
    expect(
      OngoingSuggestion.fromJson({'suggestion_id': 'music_jazz_focus'}),
      isNull,
    );
    expect(
      OngoingSuggestion.fromJson({'started_at': '2026-07-15T17:30:00.000Z'}),
      isNull,
    );
  });

  test('started_at がパースできない場合は null を返す（例外を投げない）', () {
    final ongoing = OngoingSuggestion.fromJson({
      'suggestion_id': 'music_jazz_focus',
      'started_at': 'not-a-date',
    });

    expect(ongoing, isNull);
  });
}
