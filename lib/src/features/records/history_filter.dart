import '../../models/suggestion_record.dart';

/// 履歴画面で選べる表示期間。
enum HistoryPeriod { thisWeek, all }

/// 履歴一覧へ適用するステータスフィルタ。
enum HistoryStatusFilter { all, done, skipped }

/// [now] を含む週の月曜日 00:00 を、端末のローカル時刻で返す。
DateTime startOfLocalWeek(DateTime now) {
  final localNow = now.toLocal();
  final startOfDay = DateTime(localNow.year, localNow.month, localNow.day);
  final daysSinceMonday = localNow.weekday - DateTime.monday;
  return startOfDay.subtract(Duration(days: daysSinceMonday));
}

/// レコードが選択期間に含まれるか判定する。
bool isRecordInHistoryPeriod(
  SuggestionRecord record, {
  required HistoryPeriod period,
  required DateTime now,
}) {
  switch (period) {
    case HistoryPeriod.all:
      return true;
    case HistoryPeriod.thisWeek:
      final localNow = now.toLocal();
      final createdAt = record.createdAt.toLocal();
      final weekStart = startOfLocalWeek(localNow);
      return !createdAt.isBefore(weekStart) && !createdAt.isAfter(localNow);
  }
}

/// 選択期間に含まれる履歴だけを、新しいリストとして返す。
List<SuggestionRecord> filterRecordsByPeriod(
  List<SuggestionRecord> records, {
  required HistoryPeriod period,
  required DateTime now,
}) {
  return records
      .where(
        (record) => isRecordInHistoryPeriod(record, period: period, now: now),
      )
      .toList();
}

/// 選択ステータスに一致する履歴だけを、新しいリストとして返す。
List<SuggestionRecord> filterRecordsByStatus(
  List<SuggestionRecord> records, {
  required HistoryStatusFilter statusFilter,
}) {
  return records.where((record) {
    switch (statusFilter) {
      case HistoryStatusFilter.all:
        return true;
      case HistoryStatusFilter.done:
        return record.status == SuggestionRecordStatus.done;
      case HistoryStatusFilter.skipped:
        return record.status == SuggestionRecordStatus.skipped;
    }
  }).toList();
}
