import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yorimiti_biyori/src/models/user_settings.dart';
import 'package:yorimiti_biyori/src/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('保存した設定を読込で復元できる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository();
    const settings = UserSettings(
      selectedCategories: ['music', 'walk'],
      detailSettings: {
        'music': {
          'mood': ['作業向け'],
          'genre': ['ジャズ', 'クラシック'],
        },
        'walk': {
          'time': ['15分以内'],
        },
      },
      notificationEnabled: false,
      notificationTime: '12:15',
      firstLaunchCompleted: true,
      recentSuggestionIds: ['music_jazz_focus'],
    );

    await repository.saveSettings(settings);
    final loadedSettings = await repository.loadSettings();

    expect(loadedSettings.selectedCategories, ['music', 'walk']);
    expect(loadedSettings.detailSettings, {
      'music': {
        'mood': ['作業向け'],
        'genre': ['ジャズ', 'クラシック'],
      },
      'walk': {
        'time': ['15分以内'],
      },
    });
    expect(loadedSettings.notificationEnabled, isFalse);
    expect(loadedSettings.notificationTime, '12:15');
    expect(loadedSettings.firstLaunchCompleted, isTrue);
    expect(loadedSettings.recentSuggestionIds, ['music_jazz_focus']);
  });

  test('未保存のときはデフォルト設定を返す', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository();

    final loadedSettings = await repository.loadSettings();

    expect(loadedSettings.selectedCategories, defaultSelectedCategoryIds);
    expect(loadedSettings.detailSettings, isEmpty);
    expect(loadedSettings.notificationEnabled, isTrue);
    expect(loadedSettings.notificationTime, defaultNotificationTime);
    expect(loadedSettings.firstLaunchCompleted, isFalse);
    expect(loadedSettings.recentSuggestionIds, isEmpty);
  });

  test('JSON として壊れたデータはデフォルト設定にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: '{{not json',
    });
    final repository = SettingsRepository();

    final loadedSettings = await repository.loadSettings();

    expect(loadedSettings.selectedCategories, defaultSelectedCategoryIds);
    expect(loadedSettings.detailSettings, isEmpty);
  });

  test('オブジェクト以外の JSON はデフォルト設定にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey: '[1, 2, 3]',
    });
    final repository = SettingsRepository();

    final loadedSettings = await repository.loadSettings();

    expect(loadedSettings.selectedCategories, defaultSelectedCategoryIds);
  });

  test('フィールド単位の型違いはそのフィールドだけデフォルトに補正される', () async {
    SharedPreferences.setMockInitialValues({
      settingsPreferenceKey:
          '{"selected_categories": 123, "notification_time": "08:45"}',
    });
    final repository = SettingsRepository();

    final loadedSettings = await repository.loadSettings();

    expect(loadedSettings.selectedCategories, defaultSelectedCategoryIds);
    expect(loadedSettings.notificationTime, '08:45');
  });

  test('2回保存すると後の設定で上書きされる', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SettingsRepository();

    await repository.saveSettings(
      const UserSettings(selectedCategories: ['music']),
    );
    await repository.saveSettings(
      const UserSettings(selectedCategories: ['cook', 'movie']),
    );
    final loadedSettings = await repository.loadSettings();

    expect(loadedSettings.selectedCategories, ['cook', 'movie']);
  });
}
