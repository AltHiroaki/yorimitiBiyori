/// 実施中のよりみち（issue #48）。「やってみる」を押してから
/// 完了／スキップするまでの間、提案 ID と開始時刻を保持する。
class OngoingSuggestion {
  const OngoingSuggestion({
    required this.suggestionId,
    required this.startedAt,
  });

  final String suggestionId;
  final DateTime startedAt;

  /// 必須フィールドの欠損・型不一致・日時パース失敗の場合は例外を投げず
  /// null を返す。呼び出し側は「実施中なし」として扱える。
  static OngoingSuggestion? fromJson(Map<String, dynamic> json) {
    try {
      return OngoingSuggestion(
        suggestionId: json['suggestion_id'] as String,
        startedAt: DateTime.parse(json['started_at'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestion_id': suggestionId,
      'started_at': startedAt.toIso8601String(),
    };
  }
}
