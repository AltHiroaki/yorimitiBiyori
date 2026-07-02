import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';

/// shared_preferences の保存キー（仕様書 5.4）。
const String settingsPreferenceKey = 'yorimiti_biyori_settings';

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

    try {
      final decodedJson = jsonDecode(source);
      if (decodedJson is! Map<String, dynamic>) {
        return const UserSettings();
      }
      return UserSettings.fromJson(decodedJson);
    } on FormatException {
      return const UserSettings();
    }
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
