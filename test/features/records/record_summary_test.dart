import 'package:flutter_test/flutter_test.dart';

import 'package:yorimichi_biyori/src/features/records/record_summary.dart';
import 'package:yorimichi_biyori/src/models/suggestion_record.dart';

SuggestionRecord _record({
  required String id,
  required SuggestionRecordStatus status,
  int estimatedMinutes = 10,
  DateTime? createdAt,
  DateTime? startedAt,
  DateTime? completedAt,
}) {
  return SuggestionRecord(
    id: id,
    suggestionId: 'suggestion_$id',
    suggestionTitle: '提案$id',
    category: 'music',
    estimatedMinutes: estimatedMinutes,
    status: status,
    feedback: status == SuggestionRecordStatus.done
        ? SuggestionFeedback.good
        : null,
    createdAt: createdAt ?? DateTime.utc(2026, 7, 1),
    startedAt: startedAt,
    completedAt: completedAt,
  );
}

void main() {
  test('実施数・スキップ数・合計時間が正しく集計される', () {
    final records = [
      _record(
        id: 'a',
        status: SuggestionRecordStatus.done,
        estimatedMinutes: 15,
      ),
      _record(
        id: 'b',
        status: SuggestionRecordStatus.skipped,
        estimatedMinutes: 30,
      ),
      _record(
        id: 'c',
        status: SuggestionRecordStatus.done,
        estimatedMinutes: 5,
      ),
    ];

    final summary = summarizeRecords(records);

    expect(summary.doneCount, 2);
    expect(summary.skippedCount, 1);
    // 合計時間は done のみ。skipped の30分は含めない。
    expect(summary.totalDoneMinutes, 20);
  });

  test('合計時間は正常な実測を優先し、それ以外は目安時間を使う', () {
    final base = DateTime.utc(2026, 7, 1, 12);
    final records = [
      _record(
        id: 'actual',
        status: SuggestionRecordStatus.done,
        estimatedMinutes: 20,
        startedAt: base,
        completedAt: base.add(const Duration(minutes: 8)),
      ),
      _record(
        id: 'fallback',
        status: SuggestionRecordStatus.done,
        estimatedMinutes: 5,
      ),
      _record(
        id: 'skipped',
        status: SuggestionRecordStatus.skipped,
        estimatedMinutes: 30,
        startedAt: base,
        completedAt: base.add(const Duration(minutes: 2)),
      ),
    ];

    final summary = summarizeRecords(records);

    expect(summary.doneCount, 2);
    expect(summary.skippedCount, 1);
    expect(summary.totalDoneMinutes, 13);
  });

  test('履歴 0 件のサマリーはすべて 0 になる', () {
    final summary = summarizeRecords(const []);

    expect(summary.doneCount, 0);
    expect(summary.skippedCount, 0);
    expect(summary.totalDoneMinutes, 0);
  });

  test('新しい順に並べ替えられ、元のリストは変更されない', () {
    final oldest = _record(
      id: 'old',
      status: SuggestionRecordStatus.done,
      createdAt: DateTime.utc(2026, 7, 1),
    );
    final newest = _record(
      id: 'new',
      status: SuggestionRecordStatus.done,
      createdAt: DateTime.utc(2026, 7, 3),
    );
    final middle = _record(
      id: 'mid',
      status: SuggestionRecordStatus.skipped,
      createdAt: DateTime.utc(2026, 7, 2),
    );
    final records = [oldest, newest, middle];

    final sortedRecords = sortRecordsByNewest(records);

    expect(sortedRecords.map((record) => record.id), ['new', 'mid', 'old']);
    expect(records.map((record) => record.id), ['old', 'new', 'mid']);
  });
}
