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
import 'theme_mode_scope.dart';

/// UI プロトタイプのカラーパレット（`よりみち日和 UIプロトタイプ/` の定数 C に対応）。
const Color _primarySeedColor = Color(0xFF3F6F44);
const Color _pageBackgroundColor = Color(0xFFF8FBF3);
const Color _cardOutlineColor = Color(0xFFDFE6D9);

/// プロトタイプのカードは角丸 20〜28px。代表値として大きめの 24 に揃える。
const double _cardCornerRadius = 24;
const Duration _tabFadeDuration = Duration(milliseconds: 200);
const Duration _completionNavigationDuration = Duration(milliseconds: 400);
const ValueKey<String> _completionHistoryPageKey =
    ValueKey<String>('completion-history');

/// アプリ全体のテーマ。カードの見た目（白地・薄縁・角丸）はここに集約し、
/// 各画面の Card では個別指定しない。
ThemeData buildYorimitiBiyoriTheme({
  Brightness brightness = Brightness.light,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeedColor,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final scaffoldBackgroundColor =
      isDark ? colorScheme.surface : _pageBackgroundColor;
  final cardBackgroundColor =
      isDark ? colorScheme.surfaceContainerLow : Colors.white;
  final cardOutlineColor =
      isDark ? colorScheme.outlineVariant : _cardOutlineColor;

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBackgroundColor,
    cardTheme: CardThemeData(
      elevation: 0,
      color: cardBackgroundColor,
      surfaceTintColor: Colors.transparent,
      // 画面側は SizedBox で間隔を管理しているため、既定の外側余白は持たせない。
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardCornerRadius),
        side: BorderSide(color: cardOutlineColor),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
      isNotificationEnabled =
          await widget.notificationController.requestPermission();
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

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  late final NotificationController _notificationController;
  late final AnimationController _historyImpactController;
  late final Animation<double> _historyImpactScale;
  final GlobalKey _historyDestinationKey = GlobalKey();
  int _currentIndex = 0;
  bool _isCompletionNavigation = false;
  String? _highlightedRecordId;

  @override
  void initState() {
    super.initState();
    _notificationController =
        widget.notificationController ?? NotificationService();
    _historyImpactController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _historyImpactScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.18), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.94), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1), weight: 30),
    ]).animate(
      CurvedAnimation(
        parent: _historyImpactController,
        curve: Curves.easeOut,
      ),
    );
    unawaited(_initializeNotifications());
  }

  @override
  void dispose() {
    _historyImpactController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await _notificationController.initialize(
      onNotificationTap: (_) {
        if (!mounted) {
          return;
        }
        _selectTab(0);
      },
    );
    final settings = await SettingsRepository().loadSettings();
    await _notificationController.applySettings(settings);
  }

  void _selectTab(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _isCompletionNavigation = false;
      _highlightedRecordId = null;
    });
  }

  void _handleSuggestionCompleted(String recordId) {
    if (!mounted) {
      return;
    }
    setState(() {
      _currentIndex = 1;
      _isCompletionNavigation = true;
      _highlightedRecordId = recordId;
    });
    _historyImpactController.forward(from: 0);
  }

  Widget _buildTabTransition(
    Widget child,
    Animation<double> animation,
  ) {
    final fadedChild = FadeTransition(opacity: animation, child: child);
    if (child.key != _completionHistoryPageKey) {
      return fadedChild;
    }

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );
    return SlideTransition(position: slideAnimation, child: fadedChild);
  }

  @override
  Widget build(BuildContext context) {
    // 履歴の空状態から提案タブへ切り替えられるようコールバックを渡すため、
    // ページはビルド時に組み立てる（タブ切替時に再生成され履歴も読み直される）。
    final pages = <Widget>[
      SuggestionPage(
        historyDestinationKey: _historyDestinationKey,
        onSuggestionCompleted: _handleSuggestionCompleted,
      ),
      HistoryPage(
        highlightedRecordId: _highlightedRecordId,
        onGoToSuggestions: () => _selectTab(0),
        onSuggestionRevived: () => _selectTab(0),
      ),
      SettingsPage(notificationController: _notificationController),
    ];
    final pageKey = _isCompletionNavigation
        ? _completionHistoryPageKey
        : ValueKey<int>(_currentIndex);

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: _isCompletionNavigation
              ? _completionNavigationDuration
              : _tabFadeDuration,
          transitionBuilder: _buildTabTransition,
          child: KeyedSubtree(
            key: pageKey,
            child: pages[_currentIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: '提案',
          ),
          NavigationDestination(
            icon: KeyedSubtree(
              key: _historyDestinationKey,
              child: const Icon(Icons.history_outlined),
            ),
            selectedIcon: ScaleTransition(
              scale: _historyImpactScale,
              child: const Icon(Icons.history),
            ),
            label: '履歴',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
