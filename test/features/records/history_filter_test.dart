import 'package:flutter_test/flutter_test.dart';
import 'package:yorimichi_biyori/src/features/records/history_filter.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';

SuggestionRecord _record({
  required String id,
  required SuggestionRecordStatus status,
  required DateTime createdAt,
}) {
  return SuggestionRecord(
    id: id,
    suggestionId: 'suggestion_$id',
    suggestionTitle: id,
    category: 'music',
    estimatedMinutes: 5,
    status: status,
    feedback: status == SuggestionRecordStatus.done
        ? SuggestionFeedback.good
        : null,
    createdAt: createdAt,
  );
}

void main() {
  group('startOfLocalWeek', () {
    test('月曜日00:00を週の開始として返す', () {
      final now = DateTime(2026, 7, 29, 18, 30);

      expect(startOfLocalWeek(now), DateTime(2026, 7, 27));
    });

    test('月跨ぎ・年跨ぎでも直前の月曜日を返す', () {
      expect(startOfLocalWeek(DateTime(2026, 8, 1, 12)), DateTime(2026, 7, 27));
      expect(
        startOfLocalWeek(DateTime(2026, 1, 1, 12)),
        DateTime(2025, 12, 29),
      );
    });
  });

  group('filterRecordsByPeriod', () {
    test('今週は月曜日00:00から現在時刻までを含む', () {
      final now = DateTime(2026, 7, 29, 12);
      final records = [
        _record(
          id: 'before',
          status: SuggestionRecordStatus.done,
          createdAt: DateTime(2026, 7, 26, 23, 59, 59),
        ),
        _record(
          id: 'week-start',
          status: SuggestionRecordStatus.done,
          createdAt: DateTime(2026, 7, 27),
        ),
        _record(
          id: 'now',
          status: SuggestionRecordStatus.skipped,
          createdAt: now,
        ),
        _record(
          id: 'future',
          status: SuggestionRecordStatus.done,
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      ];

      final filtered = filterRecordsByPeriod(
        records,
        period: HistoryPeriod.thisWeek,
        now: now,
      );

      expect(filtered.map((record) => record.id), ['week-start', 'now']);
      expect(records, hasLength(4));
    });

    test('全期間は未来時刻を含む全レコードを新しいリストで返す', () {
      final records = [
        _record(
          id: 'old',
          status: SuggestionRecordStatus.done,
          createdAt: DateTime(2025),
        ),
        _record(
          id: 'future',
          status: SuggestionRecordStatus.skipped,
          createdAt: DateTime(2027),
        ),
      ];

      final filtered = filterRecordsByPeriod(
        records,
        period: HistoryPeriod.all,
        now: DateTime(2026),
      );

      expect(filtered, records);
      expect(identical(filtered, records), isFalse);
    });
  });

  group('filterRecordsByStatus', () {
    final records = [
      _record(
        id: 'done',
        status: SuggestionRecordStatus.done,
        createdAt: DateTime(2026),
      ),
      _record(
        id: 'skipped',
        status: SuggestionRecordStatus.skipped,
        createdAt: DateTime(2026),
      ),
    ];

    test('実施だけを抽出する', () {
      final filtered = filterRecordsByStatus(
        records,
        statusFilter: HistoryStatusFilter.done,
      );

      expect(filtered.map((record) => record.id), ['done']);
    });

    test('スキップだけを抽出する', () {
      final filtered = filterRecordsByStatus(
        records,
        statusFilter: HistoryStatusFilter.skipped,
      );

      expect(filtered.map((record) => record.id), ['skipped']);
    });

    test('すべては入力順を保った新しいリストを返す', () {
      final filtered = filterRecordsByStatus(
        records,
        statusFilter: HistoryStatusFilter.all,
      );

      expect(filtered, records);
      expect(identical(filtered, records), isFalse);
    });
  });
}
