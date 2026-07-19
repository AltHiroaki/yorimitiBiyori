import 'package:flutter/material.dart';

import '../features/notifications/notification_service.dart';
import '../features/onboarding/onboarding_gate.dart';
import '../models/user_settings.dart';
import '../repositories/settings_repository.dart';
import 'app_theme.dart';
import 'theme_mode_scope.dart';

/// アプリのルート。テーマ・テーマモードの適用と、
/// オンボーディング分岐（[OnboardingGate]）への引き渡しだけを行う。
class YorimitiBiyoriApp extends StatefulWidget {
  const YorimitiBiyoriApp({
    super.key,
    this.settingsRepository,
    this.notificationController,
  });

  /// テスト用に差し替え可能。null なら通常の [SettingsRepository] を使う。
  final SettingsRepository? settingsRepository;
  final NotificationController? notificationController;

  @override
  State<YorimitiBiyoriApp> createState() => _YorimitiBiyoriAppState();
}

class _YorimitiBiyoriAppState extends State<YorimitiBiyoriApp> {
  late final SettingsRepository _settingsRepository;
  ThemeModeSetting _themeModeSetting = ThemeModeSetting.system;

  @override
  void initState() {
    super.initState();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _loadThemeModeSetting();
  }

  Future<void> _loadThemeModeSetting() async {
    final settings = await _settingsRepository.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _themeModeSetting = settings.themeMode;
    });
  }

  /// 設定画面が保存済みのテーマモードを [ThemeModeScope] 経由で通知してくる。
  /// ここでは表示への反映（MaterialApp の themeMode 更新）だけを行う。
  void _handleThemeModeSettingChanged(ThemeModeSetting setting) {
    setState(() {
      _themeModeSetting = setting;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      themeModeSetting: _themeModeSetting,
      onThemeModeSettingChanged: _handleThemeModeSettingChanged,
      child: MaterialApp(
        title: 'よりみち日和',
        debugShowCheckedModeBanner: false,
        theme: buildYorimitiBiyoriTheme(),
        darkTheme: buildYorimitiBiyoriTheme(brightness: Brightness.dark),
        themeMode: themeModeFromSetting(_themeModeSetting),
        home: OnboardingGate(
          settingsRepository: _settingsRepository,
          notificationController:
              widget.notificationController ?? NotificationService(),
        ),
      ),
    );
  }
}
