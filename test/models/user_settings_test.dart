import 'package:flutter_test/flutter_test.dart';

import 'package:yorimichi_biyori/src/models/user_settings.dart';

void main() {
  test('デフォルト値がカテゴリ [music, read, movie] ・詳細設定は指定なしになる', () {
    const settings = UserSettings();

    expect(settings.selectedCategories, ['music', 'read', 'movie']);
    expect(settings.detailSettings, isEmpty);
    expect(settings.maxEstimatedMinutes, isNull);
    expect(settings.notificationEnabled, isTrue);
    expect(settings.notificationStartTime, '17:00');
    expect(settings.notificationEndTime, '21:00');
    expect(settings.firstLaunchCompleted, isFalse);
    expect(settings.recentSuggestionIds, isEmpty);
    expect(settings.themeMode, ThemeModeSetting.light);
  });

  test('fromJson/toJson が往復する', () {
    final json = {
      'version': userSettingsSchemaVersion,
      'selected_categories': ['music', 'movie'],
      'detail_settings': {
        'music': {
          'mood': ['作業向け'],
          'genre': ['ジャズ'],
        },
      },
      'max_estimated_minutes': 30,
      'notification_enabled': false,
      'notification_start_time': '18:00',
      'notification_end_time': '20:30',
      'first_launch_completed': true,
      'recent_suggestion_ids': ['music_jazz_focus'],
      'theme_mode': 'dark',
    };

    final settings = UserSettings.fromJson(json);

    expect(settings.toJson(), json);
  });

  test('時間の上限は15・30・60だけを読み込む', () {
    for (final minutes in allowedMaxEstimatedMinutes) {
      final settings = UserSettings.fromJson({
        'max_estimated_minutes': minutes,
      });

      expect(settings.maxEstimatedMinutes, minutes);
    }
  });

  test('時間の上限が欠落・null・型違い・許容外なら指定なしになる', () {
    for (final value in <Object?>[null, '15', 0, 10, 120, 15.0]) {
      final settings = UserSettings.fromJson({'max_estimated_minutes': value});

      expect(settings.maxEstimatedMinutes, isNull, reason: 'value: $value');
    }
  });

  test('toJson は旧キー notification_time を出力しない', () {
    const settings = UserSettings();

    expect(settings.toJson().containsKey('notification_time'), isFalse);
  });

  test('旧形式（notification_time のみ）は開始＝終了の縮退範囲として引き継ぐ', () {
    final settings = UserSettings.fromJson({'notification_time': '12:15'});

    expect(settings.notificationStartTime, '12:15');
    expect(settings.notificationEndTime, '12:15');
  });

  test('旧形式の notification_time が不正ならデフォルト範囲になる', () {
    final settings = UserSettings.fromJson({'notification_time': '25:99'});

    expect(settings.notificationStartTime, '17:00');
    expect(settings.notificationEndTime, '21:00');
  });

  test('新キーがあれば旧キーより優先される', () {
    final settings = UserSettings.fromJson({
      'notification_time': '12:15',
      'notification_start_time': '18:00',
      'notification_end_time': '22:00',
    });

    expect(settings.notificationStartTime, '18:00');
    expect(settings.notificationEndTime, '22:00');
  });

  test('新キーの片方が壊れていればそのフィールドだけデフォルトになる', () {
    final settings = UserSettings.fromJson({
      'notification_start_time': '18:30',
      'notification_end_time': 999,
    });

    expect(settings.notificationStartTime, '18:30');
    expect(settings.notificationEndTime, '21:00');
  });

  test('開始 > 終了の範囲は両方デフォルトへ戻す', () {
    final settings = UserSettings.fromJson({
      'notification_start_time': '22:00',
      'notification_end_time': '18:00',
    });

    expect(settings.notificationStartTime, '17:00');
    expect(settings.notificationEndTime, '21:00');
  });

  test('開始 == 終了は正当な値として保持される', () {
    final settings = UserSettings.fromJson({
      'notification_start_time': '19:00',
      'notification_end_time': '19:00',
    });

    expect(settings.notificationStartTime, '19:00');
    expect(settings.notificationEndTime, '19:00');
  });

  test('壊れたデータ（Map ではない detail_settings）でもクラッシュせずデフォルトにフォールバックする', () {
    final settings = UserSettings.fromJson({
      'selected_categories': ['music'],
      'detail_settings': '指定なし',
      'max_estimated_minutes': '30',
      'notification_enabled': 'yes',
      'notification_start_time': 999,
      'notification_end_time': null,
      'first_launch_completed': null,
      'recent_suggestion_ids': null,
      'theme_mode': 'midnight',
    });

    expect(settings.selectedCategories, ['music']);
    expect(settings.detailSettings, isEmpty);
    expect(settings.maxEstimatedMinutes, isNull);
    expect(settings.notificationEnabled, isTrue);
    expect(settings.notificationStartTime, '17:00');
    expect(settings.notificationEndTime, '21:00');
    expect(settings.firstLaunchCompleted, isFalse);
    expect(settings.recentSuggestionIds, isEmpty);
    expect(settings.themeMode, ThemeModeSetting.light);
  });

  test('完全に不正な JSON（空 Map）でもクラッシュせずデフォルト値になる', () {
    final settings = UserSettings.fromJson(<String, dynamic>{});

    expect(settings.selectedCategories, ['music', 'read', 'movie']);
    expect(settings.notificationStartTime, '17:00');
    expect(settings.notificationEndTime, '21:00');
    expect(settings.themeMode, ThemeModeSetting.light);
  });

  test('保存済みの system は初期値変更後も維持される', () {
    final settings = UserSettings.fromJson({'theme_mode': 'system'});

    expect(settings.themeMode, ThemeModeSetting.system);
  });

  test('copyWith で一部フィールドだけ変更できる', () {
    const settings = UserSettings(maxEstimatedMinutes: 30);

    final updated = settings.copyWith(notificationEnabled: false);

    expect(updated.notificationEnabled, isFalse);
    expect(updated.selectedCategories, settings.selectedCategories);
    expect(updated.maxEstimatedMinutes, 30);
  });

  test('copyWith で通知時間帯だけ変更できる', () {
    const settings = UserSettings();

    final updated = settings.copyWith(
      notificationStartTime: '18:00',
      notificationEndTime: '22:00',
    );

    expect(updated.notificationStartTime, '18:00');
    expect(updated.notificationEndTime, '22:00');
    expect(updated.notificationEnabled, settings.notificationEnabled);
  });

  test('copyWith でテーマモードだけ変更できる', () {
    const settings = UserSettings();

    final updated = settings.copyWith(themeMode: ThemeModeSetting.dark);

    expect(updated.themeMode, ThemeModeSetting.dark);
    expect(updated.notificationEnabled, settings.notificationEnabled);
  });

  test('withMaxEstimatedMinutes で時間上限を設定・解除できる', () {
    const settings = UserSettings(notificationEnabled: false);

    final limited = settings.withMaxEstimatedMinutes(30);
    final cleared = limited.withMaxEstimatedMinutes(null);

    expect(limited.maxEstimatedMinutes, 30);
    expect(limited.notificationEnabled, isFalse);
    expect(cleared.maxEstimatedMinutes, isNull);
    expect(cleared.notificationEnabled, isFalse);
  });
}
