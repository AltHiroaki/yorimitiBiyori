import 'package:flutter_test/flutter_test.dart';
import 'package:yorimichi_biyori/src/features/records/record_duration.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';

SuggestionRecord _record({
  SuggestionRecordStatus status = SuggestionRecordStatus.done,
  int estimatedMinutes = 10,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  return SuggestionRecord(
    id: 'record_1',
    suggestionId: 'music_1',
    suggestionTitle: '音楽を聴く',
    category: 'music',
    estimatedMinutes: estimatedMinutes,
    status: status,
    feedback: status == SuggestionRecordStatus.done
        ? SuggestionFeedback.good
        : null,
    createdAt: completedAt ?? DateTime.utc(2026, 7, 1),
    startedAt: startedAt,
    completedAt: completedAt,
  );
}

void main() {
  group('resolveRecordDuration', () {
    test('正常な実測時間を四捨五入し、1分未満は1分にする', () {
      final base = DateTime.utc(2026, 7, 1, 12);

      final rounded = resolveRecordDuration(
        _record(
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 10, seconds: 30)),
        ),
      );
      final minimum = resolveRecordDuration(
        _record(
          startedAt: base,
          completedAt: base.add(const Duration(seconds: 20)),
        ),
      );

      expect(rounded.minutes, 11);
      expect(rounded.source, RecordDurationSource.actual);
      expect(rounded.displayLabel, '実測 11分');
      expect(minimum.minutes, 1);
      expect(minimum.source, RecordDurationSource.actual);
    });

    test('日付をまたぐ実測時間も採用する', () {
      final duration = resolveRecordDuration(
        _record(
          startedAt: DateTime.utc(2026, 7, 1, 23, 55),
          completedAt: DateTime.utc(2026, 7, 2, 0, 5),
        ),
      );

      expect(duration.minutes, 10);
      expect(duration.source, RecordDurationSource.actual);
    });

    test('開始・完了時刻の欠損、同時刻、逆転は目安時間へフォールバックする', () {
      final base = DateTime.utc(2026, 7, 1, 12);
      final records = [
        _record(completedAt: base),
        _record(startedAt: base),
        _record(startedAt: base, completedAt: base),
        _record(
          startedAt: base,
          completedAt: base.subtract(const Duration(seconds: 1)),
        ),
      ];

      for (final record in records) {
        final duration = resolveRecordDuration(record);
        expect(duration.minutes, 10);
        expect(duration.source, RecordDurationSource.estimated);
        expect(duration.displayLabel, '目安 10分');
      }
    });

    test('スキップは時刻があっても目安時間を使う', () {
      final base = DateTime.utc(2026, 7, 1, 12);
      final duration = resolveRecordDuration(
        _record(
          status: SuggestionRecordStatus.skipped,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 5)),
        ),
      );

      expect(duration.minutes, 10);
      expect(duration.source, RecordDurationSource.estimated);
    });

    test('下限15分は境界を含み、超過すると目安時間へフォールバックする', () {
      final base = DateTime.utc(2026, 7, 1, 12);

      final accepted = resolveRecordDuration(
        _record(
          estimatedMinutes: 4,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 15)),
        ),
      );
      final rejected = resolveRecordDuration(
        _record(
          estimatedMinutes: 4,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 15, seconds: 1)),
        ),
      );

      expect(accepted.minutes, 15);
      expect(accepted.source, RecordDurationSource.actual);
      expect(rejected.minutes, 4);
      expect(rejected.source, RecordDurationSource.estimated);
    });

    test('目安の3倍は境界を含み、超過すると目安時間へフォールバックする', () {
      final base = DateTime.utc(2026, 7, 1, 12);

      final accepted = resolveRecordDuration(
        _record(
          estimatedMinutes: 10,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 30)),
        ),
      );
      final rejected = resolveRecordDuration(
        _record(
          estimatedMinutes: 10,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 30, seconds: 1)),
        ),
      );

      expect(accepted.minutes, 30);
      expect(accepted.source, RecordDurationSource.actual);
      expect(rejected.minutes, 10);
      expect(rejected.source, RecordDurationSource.estimated);
    });

    test('上限180分は境界を含み、超過すると目安時間へフォールバックする', () {
      final base = DateTime.utc(2026, 7, 1, 12);

      final accepted = resolveRecordDuration(
        _record(
          estimatedMinutes: 119,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 180)),
        ),
      );
      final rejected = resolveRecordDuration(
        _record(
          estimatedMinutes: 119,
          startedAt: base,
          completedAt: base.add(const Duration(minutes: 180, seconds: 1)),
        ),
      );

      expect(accepted.minutes, 180);
      expect(accepted.source, RecordDurationSource.actual);
      expect(rejected.minutes, 119);
      expect(rejected.source, RecordDurationSource.estimated);
    });
  });
}
