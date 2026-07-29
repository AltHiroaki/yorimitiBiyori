import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

/// shared_preferences の保存キー（仕様書 5.4）。
const String settingsPreferenceKey = 'yorimichi_biyori_settings';
const int _legacyUserSettingsSchemaVersion = 1;

/// ユーザー設定を shared_preferences に JSON 文字列で保存・復元する repository。
class SettingsRepository {
  /// 保存済みのユーザー設定を読み込む。
  /// 未保存・JSON 破損時はデフォルト値の [UserSettings] に安全フォールバックする。
  /// フィールド単位の欠損・型違いは [UserSettings.fromJson] 側で補正される。
  Future<UserSettings> loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final source = preferences.getString(settingsPreferenceKey);
    if (source == null) {
      return const UserSettings();
    }

    return parseSettingsJsonSource(source);
  }

  /// ユーザー設定を保存する。既存の保存内容は上書きされる。
  Future<void> saveSettings(UserSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      settingsPreferenceKey,
      jsonEncode(settings.toJson()),
    );
  }
}

/// 保存文字列からユーザー設定を復元する入口。
/// 将来スキーマが変わったときは、ここで version を見て移行処理を挟む。
UserSettings parseSettingsJsonSource(String source) {
  try {
    return parseSettingsJson(jsonDecode(source));
  } on FormatException {
    return const UserSettings();
  }
}

UserSettings parseSettingsJson(Object? decodedJson) {
  if (decodedJson is! Map<String, dynamic>) {
    return const UserSettings();
  }

  final version = decodedJson['version'];
  if (version == userSettingsSchemaVersion) {
    return UserSettings.fromJson(decodedJson);
  }
  if (version == null || version == _legacyUserSettingsSchemaVersion) {
    return UserSettings.fromJson(_migrateLegacySettings(decodedJson));
  }

  return const UserSettings();
}

Map<String, dynamic> _migrateLegacySettings(
  Map<String, dynamic> legacySettings,
) {
  return {
    ...legacySettings,
    'version': userSettingsSchemaVersion,
    'max_estimated_minutes': null,
  };
}
