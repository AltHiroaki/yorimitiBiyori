import 'hour_minute.dart';

/// 初回起動時・保存データが壊れているときに使うデフォルトの選択カテゴリ。
/// 企画書 ver6 の MVP コアカテゴリ（音楽・料理・読書・映画）から選ぶ。
const List<String> defaultSelectedCategoryIds = ['music', 'read', 'movie'];

/// 通知時間帯のデフォルト。この範囲内で毎日1回ランダムな時刻に通知する。
const String defaultNotificationStartTime = '17:00';
const String defaultNotificationEndTime = '21:00';

/// shared_preferences に保存するユーザー設定 JSON の現行スキーマバージョン。
const int userSettingsSchemaVersion = 1;

/// テーマモード設定。system は端末の設定に追従する。
enum ThemeModeSetting {
  system,
  light,
  dark;

  /// 保存値（`name` 文字列）から復元する。
  /// 不明な値・未保存は [defaultThemeMode] にフォールバックする。
  static ThemeModeSetting fromJson(dynamic value) {
    if (value is String) {
      for (final setting in ThemeModeSetting.values) {
        if (setting.name == value) {
          return setting;
        }
      }
    }
    return defaultThemeMode;
  }
}

/// 表示テーマのデフォルト（issue #131）。
/// ニューモーフィズムのハイライト・影は明るい背景を前提に設計しているため、
/// 端末設定に追従せずライトを基本の見た目とする。
/// 「システム」はユーザーが明示的に選べば引き続き使える。
const ThemeModeSetting defaultThemeMode = ThemeModeSetting.light;

/// ユーザー設定（選択カテゴリ・カテゴリ別詳細設定・通知設定・直近提案IDなど）。
class UserSettings {
  const UserSettings({
    this.selectedCategories = defaultSelectedCategoryIds,
    this.detailSettings = const {},
    this.notificationEnabled = true,
    this.notificationStartTime = defaultNotificationStartTime,
    this.notificationEndTime = defaultNotificationEndTime,
    this.firstLaunchCompleted = false,
    this.recentSuggestionIds = const [],
    this.themeMode = defaultThemeMode,
  });

  /// 選択中の興味カテゴリ id（例：`music`）。
  final List<String> selectedCategories;

  /// カテゴリ id → 詳細設定グループ id → 選択値の一覧。
  /// グループが未設定・空配列の場合は「指定なし」として扱う。
  final Map<String, Map<String, List<String>>> detailSettings;

  final bool notificationEnabled;

  /// `HH:mm` 形式の通知時間帯の開始時刻。この範囲内で毎日1回ランダムな時刻に
  /// 通知する。開始 == 終了は「固定時刻に通知」として扱う（旧
  /// `notification_time` からの移行結果もこの形になる）。
  final String notificationStartTime;

  /// `HH:mm` 形式の通知時間帯の終了時刻。
  final String notificationEndTime;

  final bool firstLaunchCompleted;

  /// 直近重複除外用の直近3件の提案ID。
  final List<String> recentSuggestionIds;

  /// 表示テーマ（システム追従・ライト固定・ダーク固定）。
  final ThemeModeSetting themeMode;

  /// フィールドごとに壊れたデータを検出し、そのフィールドだけデフォルト値に
  /// フォールバックする。1つのフィールドが壊れていても他のフィールドは保持する。
  static UserSettings fromJson(Map<String, dynamic> json) {
    final notificationRange = _parseNotificationRange(json);
    return UserSettings(
      selectedCategories: _parseStringList(
        json['selected_categories'],
        defaultSelectedCategoryIds,
      ),
      detailSettings: _parseDetailSettings(json['detail_settings']),
      notificationEnabled: json['notification_enabled'] is bool
          ? json['notification_enabled'] as bool
          : true,
      notificationStartTime: notificationRange.start,
      notificationEndTime: notificationRange.end,
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
      'version': userSettingsSchemaVersion,
      'selected_categories': selectedCategories,
      'detail_settings': detailSettings,
      'notification_enabled': notificationEnabled,
      'notification_start_time': notificationStartTime,
      'notification_end_time': notificationEndTime,
      'first_launch_completed': firstLaunchCompleted,
      'recent_suggestion_ids': recentSuggestionIds,
      'theme_mode': themeMode.name,
    };
  }

  UserSettings copyWith({
    List<String>? selectedCategories,
    Map<String, Map<String, List<String>>>? detailSettings,
    bool? notificationEnabled,
    String? notificationStartTime,
    String? notificationEndTime,
    bool? firstLaunchCompleted,
    List<String>? recentSuggestionIds,
    ThemeModeSetting? themeMode,
  }) {
    return UserSettings(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      detailSettings: detailSettings ?? this.detailSettings,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationStartTime:
          notificationStartTime ?? this.notificationStartTime,
      notificationEndTime: notificationEndTime ?? this.notificationEndTime,
      firstLaunchCompleted:
          firstLaunchCompleted ?? this.firstLaunchCompleted,
      recentSuggestionIds: recentSuggestionIds ?? this.recentSuggestionIds,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class _NotificationRange {
  const _NotificationRange(this.start, this.end);

  final String start;
  final String end;
}

/// 通知時間帯を復元する。
/// 新キー（`notification_start_time` / `notification_end_time`）があれば
/// フィールド単位で採用し、両方無ければ旧 `notification_time` を
/// 開始＝終了の縮退範囲として引き継ぐ（従来の固定時刻動作を保存する移行）。
/// どちらも無効ならデフォルト、開始 > 終了なら両方デフォルトへ戻す。
_NotificationRange _parseNotificationRange(Map<String, dynamic> json) {
  final startValue = json['notification_start_time'];
  final endValue = json['notification_end_time'];
  final hasRangeKeys =
      _isValidNotificationTime(startValue) || _isValidNotificationTime(endValue);

  String start;
  String end;
  if (hasRangeKeys) {
    start = _isValidNotificationTime(startValue)
        ? startValue as String
        : defaultNotificationStartTime;
    end = _isValidNotificationTime(endValue)
        ? endValue as String
        : defaultNotificationEndTime;
  } else if (_isValidNotificationTime(json['notification_time'])) {
    final legacyTime = json['notification_time'] as String;
    start = legacyTime;
    end = legacyTime;
  } else {
    start = defaultNotificationStartTime;
    end = defaultNotificationEndTime;
  }

  final startMinutes = HourMinute.tryParse(start)!.totalMinutes;
  final endMinutes = HourMinute.tryParse(end)!.totalMinutes;
  if (startMinutes > endMinutes) {
    return const _NotificationRange(
      defaultNotificationStartTime,
      defaultNotificationEndTime,
    );
  }
  return _NotificationRange(start, end);
}

/// 保存値が `HH:mm` 形式の文字列かどうか。
bool _isValidNotificationTime(dynamic value) {
  return value is String && HourMinute.tryParse(value) != null;
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
