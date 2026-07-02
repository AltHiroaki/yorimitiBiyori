/// 初回起動時・保存データが壊れているときに使うデフォルトの選択カテゴリ。
/// 企画書 ver6 の MVP コアカテゴリ（音楽・料理・読書・映画）から選ぶ。
const List<String> defaultSelectedCategoryIds = ['music', 'read', 'movie'];

const String defaultNotificationTime = '17:30';

/// ユーザー設定（選択カテゴリ・カテゴリ別詳細設定・通知設定・直近提案IDなど）。
class UserSettings {
  const UserSettings({
    this.selectedCategories = defaultSelectedCategoryIds,
    this.detailSettings = const {},
    this.notificationEnabled = true,
    this.notificationTime = defaultNotificationTime,
    this.firstLaunchCompleted = false,
    this.recentSuggestionIds = const [],
  });

  /// 選択中の興味カテゴリ id（例：`music`）。
  final List<String> selectedCategories;

  /// カテゴリ id → 詳細設定グループ id → 選択値の一覧。
  /// グループが未設定・空配列の場合は「指定なし」として扱う。
  final Map<String, Map<String, List<String>>> detailSettings;

  final bool notificationEnabled;

  /// `HH:mm` 形式の通知時刻。
  final String notificationTime;

  final bool firstLaunchCompleted;

  /// 直近重複除外用の直近3件の提案ID。
  final List<String> recentSuggestionIds;

  /// フィールドごとに壊れたデータを検出し、そのフィールドだけデフォルト値に
  /// フォールバックする。1つのフィールドが壊れていても他のフィールドは保持する。
  static UserSettings fromJson(Map<String, dynamic> json) {
    return UserSettings(
      selectedCategories: _parseStringList(
        json['selected_categories'],
        defaultSelectedCategoryIds,
      ),
      detailSettings: _parseDetailSettings(json['detail_settings']),
      notificationEnabled: json['notification_enabled'] is bool
          ? json['notification_enabled'] as bool
          : true,
      notificationTime: json['notification_time'] is String
          ? json['notification_time'] as String
          : defaultNotificationTime,
      firstLaunchCompleted: json['first_launch_completed'] is bool
          ? json['first_launch_completed'] as bool
          : false,
      recentSuggestionIds: _parseStringList(
        json['recent_suggestion_ids'],
        const [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selected_categories': selectedCategories,
      'detail_settings': detailSettings,
      'notification_enabled': notificationEnabled,
      'notification_time': notificationTime,
      'first_launch_completed': firstLaunchCompleted,
      'recent_suggestion_ids': recentSuggestionIds,
    };
  }

  UserSettings copyWith({
    List<String>? selectedCategories,
    Map<String, Map<String, List<String>>>? detailSettings,
    bool? notificationEnabled,
    String? notificationTime,
    bool? firstLaunchCompleted,
    List<String>? recentSuggestionIds,
  }) {
    return UserSettings(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      detailSettings: detailSettings ?? this.detailSettings,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      firstLaunchCompleted:
          firstLaunchCompleted ?? this.firstLaunchCompleted,
      recentSuggestionIds: recentSuggestionIds ?? this.recentSuggestionIds,
    );
  }
}

List<String> _parseStringList(dynamic value, List<String> fallback) {
  if (value is! List) {
    return fallback;
  }

  final parsedValues = <String>[];
  for (final item in value) {
    if (item is String) {
      parsedValues.add(item);
    }
  }
  return parsedValues;
}

Map<String, Map<String, List<String>>> _parseDetailSettings(dynamic value) {
  if (value is! Map) {
    return const {};
  }

  final parsedDetailSettings = <String, Map<String, List<String>>>{};
  value.forEach((categoryId, detailSettingGroups) {
    if (categoryId is! String || detailSettingGroups is! Map) {
      return;
    }

    final parsedGroups = <String, List<String>>{};
    detailSettingGroups.forEach((groupId, selectedOptions) {
      if (groupId is! String) {
        return;
      }
      parsedGroups[groupId] = _parseStringList(selectedOptions, const []);
    });
    parsedDetailSettings[categoryId] = parsedGroups;
  });
  return parsedDetailSettings;
}
