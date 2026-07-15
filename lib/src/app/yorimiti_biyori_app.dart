import 'dart:async';

import 'package:flutter/material.dart';

import '../features/notifications/notification_service.dart';
import '../features/onboarding/category_select_page.dart';
import '../features/onboarding/notification_permission_dialog.dart';
import '../features/onboarding/welcome_modal.dart';
import '../models/user_settings.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/suggestion_page.dart';
import '../repositories/settings_repository.dart';
import '../widgets/neumorphic_surface.dart';
import 'theme_mode_scope.dart';
import 'yorimiti_neumorphic_theme.dart';

/// UI プロトタイプのカラーパレット（`よりみち日和 UIプロトタイプ/` の定数 C に対応）。
const Color _primarySeedColor = Color(0xFF3F6F44);
const Color _pageBackgroundColor = Color(0xFFF8FBF3);
const Color _surfaceVariantColor = Color(0xFFEEF5E8);
const Color _primaryContainerColor = Color(0xFFC2E8C0);
const Color _darkPageBackgroundColor = Color(0xFF1D221C);
const Color _darkSurfaceVariantColor = Color(0xFF242B23);

/// Issue #66 のニューモーフィズムトークンを集約したアプリテーマ。
ThemeData buildYorimitiBiyoriTheme({Brightness brightness = Brightness.light}) {
  final baseColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeedColor,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final surfaceColor = isDark ? _darkPageBackgroundColor : _pageBackgroundColor;
  final surfaceVariantColor = isDark
      ? _darkSurfaceVariantColor
      : _surfaceVariantColor;
  final colorScheme = baseColorScheme.copyWith(
    primary: isDark ? baseColorScheme.primary : _primarySeedColor,
    primaryContainer: isDark
        ? baseColorScheme.primaryContainer
        : _primaryContainerColor,
    surface: surfaceColor,
    surfaceContainerLowest: surfaceColor,
    surfaceContainerLow: surfaceColor,
    surfaceContainer: surfaceColor,
    surfaceContainerHigh: surfaceVariantColor,
    surfaceContainerHighest: surfaceVariantColor,
  );
  final roundedButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.buttonRadius),
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    fontFamily: 'ZenMaruGothic',
    fontFamilyFallback: const ['Noto Sans JP', 'sans-serif'],
    scaffoldBackgroundColor: surfaceColor,
    canvasColor: surfaceColor,
    extensions: [buildYorimitiNeumorphicTheme(brightness: brightness)],
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.cardRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.pillRadius),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: Colors.transparent,
      disabledColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.chipRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: roundedButtonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        elevation: 0,
        backgroundColor: surfaceColor,
        side: BorderSide.none,
        shape: roundedButtonShape,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.primaryContainer
              : Colors.transparent;
        }),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.heroRadius),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(YorimitiNeumorphicTheme.heroRadius),
        ),
      ),
    ),
  );
}

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

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({
    super.key,
    required this.settingsRepository,
    required this.notificationController,
  });

  final SettingsRepository settingsRepository;
  final NotificationController notificationController;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  UserSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.settingsRepository.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
    });
  }

  void _handleOnboardingCompleted(UserSettings settings) {
    setState(() {
      _settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!settings.firstLaunchCompleted) {
      return OnboardingFlow(
        initialSettings: settings,
        settingsRepository: widget.settingsRepository,
        notificationController: widget.notificationController,
        onCompleted: _handleOnboardingCompleted,
      );
    }

    return AppShell(notificationController: widget.notificationController);
  }
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.initialSettings,
    required this.settingsRepository,
    required this.notificationController,
    required this.onCompleted,
  });

  final UserSettings initialSettings;
  final SettingsRepository settingsRepository;
  final NotificationController notificationController;
  final ValueChanged<UserSettings> onCompleted;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

enum _OnboardingStep { welcome, category, notification }

class _OnboardingFlowState extends State<OnboardingFlow> {
  _OnboardingStep _step = _OnboardingStep.welcome;
  List<String> _selectedCategoryIds = const [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = widget.initialSettings.selectedCategories;
  }

  Future<void> _complete(NotificationPermissionChoice choice) async {
    var isNotificationEnabled = false;
    if (choice == NotificationPermissionChoice.allow) {
      isNotificationEnabled = await widget.notificationController
          .requestPermission();
    }

    // 詳細設定は消さず、オンボーディングで選ばれなかったカテゴリの分だけ落とす。
    final retainedDetailSettings = <String, Map<String, List<String>>>{
      for (final entry in widget.initialSettings.detailSettings.entries)
        if (_selectedCategoryIds.contains(entry.key)) entry.key: entry.value,
    };
    final completedSettings = widget.initialSettings.copyWith(
      selectedCategories: _selectedCategoryIds,
      detailSettings: retainedDetailSettings,
      notificationEnabled: isNotificationEnabled,
      firstLaunchCompleted: true,
    );
    await widget.settingsRepository.saveSettings(completedSettings);
    await widget.notificationController.applySettings(completedSettings);
    widget.onCompleted(completedSettings);
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _OnboardingStep.welcome:
        return Scaffold(
          body: Center(
            child: WelcomeModal(
              onStart: () {
                setState(() {
                  _step = _OnboardingStep.category;
                });
              },
            ),
          ),
        );
      case _OnboardingStep.category:
        return CategorySelectPage(
          initialSelectedCategoryIds: _selectedCategoryIds,
          onNext: (selectedCategoryIds) {
            setState(() {
              _selectedCategoryIds = selectedCategoryIds;
              _step = _OnboardingStep.notification;
            });
          },
        );
      case _OnboardingStep.notification:
        return Scaffold(
          body: Center(
            child: NotificationPermissionDialog(onSelected: _complete),
          ),
        );
    }
  }
}

/// UI プロトタイプどおりの 3 タブ構成。ホーム画面は持たず、提案タブをトップにする。
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.notificationController});

  final NotificationController? notificationController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final NotificationController _notificationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _notificationController =
        widget.notificationController ?? NotificationService();
    unawaited(_initializeNotifications());
  }

  Future<void> _initializeNotifications() async {
    await _notificationController.initialize(
      onNotificationTap: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _currentIndex = 0;
        });
      },
    );
    final settings = await SettingsRepository().loadSettings();
    await _notificationController.applySettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    // 履歴の空状態から提案タブへ切り替えられるようコールバックを渡すため、
    // ページはビルド時に組み立てる（タブ切替時に再生成され履歴も読み直される）。
    final pages = <Widget>[
      const SuggestionPage(),
      HistoryPage(onGoToSuggestions: () => setState(() => _currentIndex = 0)),
      SettingsPage(notificationController: _notificationController),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: NeumorphicNavigationSurface(
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.lightbulb_outline),
              selectedIcon: Icon(Icons.lightbulb),
              label: '提案',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: '履歴',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: '設定',
            ),
          ],
        ),
      ),
    );
  }
}
