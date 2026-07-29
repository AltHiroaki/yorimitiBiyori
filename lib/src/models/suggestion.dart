/// 提案候補データ（assets/data/suggestions/*.json の1件）を表すモデル。
class Suggestion {
  const Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.whereToTry,
    required this.estimatedMinutes,
    required this.weight,
    this.recipe,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;

  /// 入手先・実践先の案内（例：「音楽配信アプリで〜を検索する」）。全カテゴリ共通。
  final String whereToTry;
  final int estimatedMinutes;
  final double weight;

  /// 料理カテゴリ（cook）だけが持つレシピ本文。他カテゴリは null。
  final String? recipe;

  /// 必須フィールドが欠損・不正な場合は例外を投げず null を返す。
  /// 呼び出し側（提案JSON読み込み処理）はこの1件をスキップできる。
  static Suggestion? fromJson(Map<String, dynamic> json) {
    try {
      return Suggestion(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        tags: (json['tags'] as List<dynamic>)
            .map((tag) => tag as String)
            .toList(),
        whereToTry: json['where_to_try'] as String,
        estimatedMinutes: (json['estimated_minutes'] as num).toInt(),
        weight: (json['weight'] as num).toDouble(),
        recipe: json['recipe'] as String?,
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
      'category': category,
      'tags': tags,
      'where_to_try': whereToTry,
      'estimated_minutes': estimatedMinutes,
      'weight': weight,
      if (recipe != null) 'recipe': recipe,
    };
  }
}
