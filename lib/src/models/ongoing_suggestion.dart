/// 実施中のよりみち（issue #48）。「やってみる」を押してから
/// 完了／スキップするまでの間、提案 ID と開始時刻を保持する。
class OngoingSuggestion {
  const OngoingSuggestion({
    required this.suggestionId,
    required this.startedAt,
    this.revivedFromRecordId,
  });

  final String suggestionId;
  final DateTime startedAt;

  /// スキップ履歴からの復活で実施中になった場合、元のスキップ履歴の ID。
  /// 完了時にそのスキップ履歴を削除するために使う（issue #101）。
  /// 提案タブから直接「やってみる」した場合は null。
  final String? revivedFromRecordId;

  /// 必須フィールドの欠損・型不一致・日時パース失敗の場合は例外を投げず
  /// null を返す。呼び出し側は「実施中なし」として扱える。
  static OngoingSuggestion? fromJson(Map<String, dynamic> json) {
    try {
      return OngoingSuggestion(
        suggestionId: json['suggestion_id'] as String,
        startedAt: DateTime.parse(json['started_at'] as String),
        revivedFromRecordId: json['revived_from_record_id'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestion_id': suggestionId,
      'started_at': startedAt.toUtc().toIso8601String(),
      if (revivedFromRecordId case final String revivedFromRecordId)
        'revived_from_record_id': revivedFromRecordId,
    };
  }
}
