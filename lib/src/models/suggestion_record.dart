/// 提案を実施したか、スキップしたかを表す。
enum SuggestionRecordStatus { done, skipped }

/// 実施時のフィードバック。スキップの場合は feedback を持たない（null）。
enum SuggestionFeedback { good, normal, bad }

/// 提案の実施・スキップ履歴（records の1件）。
class SuggestionRecord {
  const SuggestionRecord({
    required this.id,
    required this.suggestionId,
    required this.suggestionTitle,
    required this.category,
    required this.estimatedMinutes,
    required this.status,
    required this.feedback,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  final String id;
  final String suggestionId;

  /// 提案データが後で更新・削除されても履歴表示が壊れないよう非正規化して保持する。
  final String suggestionTitle;
  final String category;
  final int estimatedMinutes;
  final SuggestionRecordStatus status;
  final SuggestionFeedback? feedback;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// 必須フィールドの欠損・型不一致・不正な enum 値・日時パース失敗の場合は
  /// 例外を投げず null を返す。呼び出し側はこの1件をスキップできる。
  static SuggestionRecord? fromJson(Map<String, dynamic> json) {
    try {
      return SuggestionRecord(
        id: json['id'] as String,
        suggestionId: json['suggestion_id'] as String,
        suggestionTitle: json['suggestion_title'] as String,
        category: json['category'] as String,
        estimatedMinutes: (json['estimated_minutes'] as num).toInt(),
        status: SuggestionRecordStatus.values.byName(json['status'] as String),
        feedback: _feedbackFromJson(json['feedback'] as String?),
        createdAt: DateTime.parse(json['created_at'] as String),
        startedAt: _optionalDateTimeFromJson(json['started_at']),
        completedAt: _optionalDateTimeFromJson(json['completed_at']),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'suggestion_id': suggestionId,
      'suggestion_title': suggestionTitle,
      'category': category,
      'estimated_minutes': estimatedMinutes,
      'status': status.name,
      'feedback': feedback?.name,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toUtc().toIso8601String(),
      'completed_at': completedAt?.toUtc().toIso8601String(),
    };
  }
}

SuggestionFeedback? _feedbackFromJson(String? value) {
  if (value == null) {
    return null;
  }
  return SuggestionFeedback.values.byName(value);
}

DateTime? _optionalDateTimeFromJson(Object? value) {
  if (value is! String) {
    return null;
  }
  return DateTime.tryParse(value);
}
