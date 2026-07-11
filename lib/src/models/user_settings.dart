/// 初回起動時・保存データが壊れているときに使うデフォルトの選択カテゴリ。
/// 企画書 ver6 の MVP コアカテゴリ（音楽・料理・読書・映画）から選ぶ。
const List<String> defaultSelectedCategoryIds = ['music', 'read', 'movie'];

const String defaultNotificationTime = '17:30';

/// テーマモード設定。system は端末の設定に追従する。
enum ThemeModeSetting {
  system,
  light,
  dark;

  /// 保存値（`name` 文字列）から復元する。不明な値は [system] にフォールバックする。
  static ThemeModeSetting fromJson(dynamic value) {
    if (value is String) {
      for (final setting in ThemeModeSetting.values) {
        if (setting.name == value) {
          return setting;
        }
      }
    }
    return ThemeModeSetting.system;
  }
}

/// ユーザー設定（選択カテゴリ・カテゴリ別詳細設定・通知設定・直近提案IDなど）。
class UserSettings {
  const UserSettings({
    this.selectedCategories = defaultSelectedCategoryIds,
    this.detailSettings = const {},
    this.notificationEnabled = true,
    this.notificationTime = defaultNotificationTime,
    this.firstLaunchCompleted = false,
    this.recentSuggestionIds = const [],
    this.themeMode = ThemeModeSetting.system,
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

  /// 表示テーマ（システム追従・ライト固定・ダーク固定）。
  final ThemeModeSetting themeMode;

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
      themeMode: ThemeModeSetting.fromJson(json['theme_mode']),
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
      'theme_mode': themeMode.name,
    };
  }

  UserSettings copyWith({
    List<String>? selectedCategories,
    Map<String, Map<String, List<String>>>? detailSettings,
    bool? notificationEnabled,
    String? notificationTime,
    bool? firstLaunchCompleted,
    List<String>? recentSuggestionIds,
    ThemeModeSetting? themeMode,
  }) {
    return UserSettings(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      detailSettings: detailSettings ?? this.detailSettings,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      firstLaunchCompleted:
          firstLaunchCompleted ?? this.firstLaunchCompleted,
      recentSuggestionIds: recentSuggestionIds ?? this.recentSuggestionIds,
      themeMode: themeMode ?? this.themeMode,
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
