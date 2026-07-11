import 'package:flutter/material.dart';

import '../models/user_settings.dart';

/// [ThemeModeSetting] を Flutter の [ThemeMode] へ変換する。
ThemeMode themeModeFromSetting(ThemeModeSetting setting) {
  switch (setting) {
    case ThemeModeSetting.system:
      return ThemeMode.system;
    case ThemeModeSetting.light:
      return ThemeMode.light;
    case ThemeModeSetting.dark:
      return ThemeMode.dark;
  }
}

/// 設定画面など子孫ウィジェットからテーマモードの変更をアプリルートへ
/// 伝えるための scope。scope が無い場合（単体テストなど）でも動くよう、
/// 参照側は [maybeOf] を使う。
class ThemeModeScope extends InheritedWidget {
  const ThemeModeScope({
    super.key,
    required this.themeModeSetting,
    required this.onThemeModeSettingChanged,
    required super.child,
  });

  final ThemeModeSetting themeModeSetting;
  final ValueChanged<ThemeModeSetting> onThemeModeSettingChanged;

  static ThemeModeScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeScope>();
  }

  @override
  bool updateShouldNotify(ThemeModeScope oldWidget) {
    return themeModeSetting != oldWidget.themeModeSetting;
  }
}
