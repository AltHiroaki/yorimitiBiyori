import 'dart:math' as math;

import '../../models/suggestion_record.dart';

const int minimumActualDurationLimitMinutes = 15;
const int maximumActualDurationLimitMinutes = 180;

enum RecordDurationSource { actual, estimated }

/// 履歴の表示と集計に採用する所要時間。
class RecordDuration {
  const RecordDuration({required this.minutes, required this.source});

  final int minutes;
  final RecordDurationSource source;

  String get displayLabel {
    final prefix = source == RecordDurationSource.actual ? '実測' : '目安';
    return '$prefix $minutes分';
  }
}

/// 提案の目安時間から、実測時間を採用できる上限を求める。
int actualDurationLimitMinutes(int estimatedMinutes) {
  return math.min(
    math.max(estimatedMinutes * 3, minimumActualDurationLimitMinutes),
    maximumActualDurationLimitMinutes,
  );
}

/// 実測時間が信頼できる場合は最も近い整数分へ丸めて採用し、
/// それ以外は提案の目安時間へフォールバックする。
RecordDuration resolveRecordDuration(SuggestionRecord record) {
  final estimatedDuration = RecordDuration(
    minutes: record.estimatedMinutes,
    source: RecordDurationSource.estimated,
  );
  if (record.status != SuggestionRecordStatus.done) {
    return estimatedDuration;
  }

  final startedAt = record.startedAt;
  final completedAt = record.completedAt;
  if (startedAt == null ||
      completedAt == null ||
      !completedAt.isAfter(startedAt)) {
    return estimatedDuration;
  }

  final elapsed = completedAt.difference(startedAt);
  final limit = Duration(
    minutes: actualDurationLimitMinutes(record.estimatedMinutes),
  );
  if (elapsed > limit) {
    return estimatedDuration;
  }

  final roundedMinutes = math.max(
    (elapsed.inSeconds / Duration.secondsPerMinute).round(),
    1,
  );
  return RecordDuration(
    minutes: roundedMinutes,
    source: RecordDurationSource.actual,
  );
}
