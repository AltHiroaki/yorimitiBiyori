import '../../models/suggestion_record.dart';

/// 履歴サマリー（仕様書 6.5）。実施数・スキップ数・合計時間（分）を保持する。
class RecordSummary {
  const RecordSummary({
    required this.doneCount,
    required this.skippedCount,
    required this.totalDoneMinutes,
  });

  final int doneCount;
  final int skippedCount;

  /// done レコードの `estimated_minutes` 合計。skipped は含めない。
  final int totalDoneMinutes;
}

/// 履歴からサマリーを集計する純粋関数。
RecordSummary summarizeRecords(List<SuggestionRecord> records) {
  var doneCount = 0;
  var skippedCount = 0;
  var totalDoneMinutes = 0;

  for (final record in records) {
    switch (record.status) {
      case SuggestionRecordStatus.done:
        doneCount += 1;
        totalDoneMinutes += record.estimatedMinutes;
      case SuggestionRecordStatus.skipped:
        skippedCount += 1;
    }
  }

  return RecordSummary(
    doneCount: doneCount,
    skippedCount: skippedCount,
    totalDoneMinutes: totalDoneMinutes,
  );
}

/// 履歴を新しい順（created_at 降順）に並べた新しいリストを返す純粋関数。
/// 引数のリストは変更しない。
List<SuggestionRecord> sortRecordsByNewest(List<SuggestionRecord> records) {
  final sortedRecords = List<SuggestionRecord>.of(records);
  sortedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return sortedRecords;
}
