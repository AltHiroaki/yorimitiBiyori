import 'package:flutter_test/flutter_test.dart';

import 'package:yorimiti_biyori/src/models/user_settings.dart';

void main() {
  test('デフォルト値がカテゴリ [music, read, movie] ・詳細設定は指定なしになる', () {
    const settings = UserSettings();

    expect(settings.selectedCategories, ['music', 'read', 'movie']);
    expect(settings.detailSettings, isEmpty);
    expect(settings.notificationEnabled, isTrue);
    expect(settings.notificationTime, '17:30');
    expect(settings.firstLaunchCompleted, isFalse);
    expect(settings.recentSuggestionIds, isEmpty);
    expect(settings.themeMode, ThemeModeSetting.system);
  });

  test('fromJson/toJson が往復する', () {
    final json = {
      'selected_categories': ['music', 'movie'],
      'detail_settings': {
        'music': {
          'mood': ['作業向け'],
          'genre': ['ジャズ'],
        },
      },
      'notification_enabled': false,
      'notification_time': '20:00',
      'first_launch_completed': true,
      'recent_suggestion_ids': ['music_jazz_focus'],
      'theme_mode': 'dark',
    };

    final settings = UserSettings.fromJson(json);

    expect(settings.toJson(), json);
  });

  test('壊れたデータ（Map ではない detail_settings）でもクラッシュせずデフォルトにフォールバックする', () {
    final settings = UserSettings.fromJson({
      'selected_categories': ['music'],
      'detail_settings': '指定なし',
      'notification_enabled': 'yes',
      'notification_time': 999,
      'first_launch_completed': null,
      'recent_suggestion_ids': null,
      'theme_mode': 'midnight',
    });

    expect(settings.selectedCategories, ['music']);
    expect(settings.detailSettings, isEmpty);
    expect(settings.notificationEnabled, isTrue);
    expect(settings.notificationTime, '17:30');
    expect(settings.firstLaunchCompleted, isFalse);
    expect(settings.recentSuggestionIds, isEmpty);
    expect(settings.themeMode, ThemeModeSetting.system);
  });

  test('完全に不正な JSON（空 Map）でもクラッシュせずデフォルト値になる', () {
    final settings = UserSettings.fromJson(<String, dynamic>{});

    expect(settings.selectedCategories, ['music', 'read', 'movie']);
  });

  test('copyWith で一部フィールドだけ変更できる', () {
    const settings = UserSettings();

    final updated = settings.copyWith(notificationEnabled: false);

    expect(updated.notificationEnabled, isFalse);
    expect(updated.selectedCategories, settings.selectedCategories);
  });

  test('copyWith でテーマモードだけ変更できる', () {
    const settings = UserSettings();

    final updated = settings.copyWith(themeMode: ThemeModeSetting.dark);

    expect(updated.themeMode, ThemeModeSetting.dark);
    expect(updated.notificationEnabled, settings.notificationEnabled);
  });
}
