/// 提案候補データ（assets/data/suggestions.json の1件）を表すモデル。
class Suggestion {
  const Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.detail,
    required this.category,
    required this.tags,
    required this.budgetYen,
    required this.whereToTry,
    required this.estimatedMinutes,
    required this.weight,
  });

  final String id;
  final String title;
  final String description;
  final String detail;
  final String category;
  final List<String> tags;
  final int budgetYen;
  final String whereToTry;
  final int estimatedMinutes;
  final double weight;

  /// 必須フィールドが欠損・不正な場合は例外を投げず null を返す。
  /// 呼び出し側（suggestions.json 読み込み処理）はこの1件をスキップできる。
  static Suggestion? fromJson(Map<String, dynamic> json) {
    try {
      return Suggestion(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        detail: json['detail'] as String,
        category: json['category'] as String,
        tags: (json['tags'] as List<dynamic>)
            .map((tag) => tag as String)
            .toList(),
        budgetYen: (json['budget_yen'] as num).toInt(),
        whereToTry: json['where_to_try'] as String,
        estimatedMinutes: (json['estimated_minutes'] as num).toInt(),
        weight: (json['weight'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'detail': detail,
      'category': category,
      'tags': tags,
      'budget_yen': budgetYen,
      'where_to_try': whereToTry,
      'estimated_minutes': estimatedMinutes,
      'weight': weight,
    };
  }
}
