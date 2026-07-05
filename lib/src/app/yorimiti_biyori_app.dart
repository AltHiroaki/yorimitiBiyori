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

class YorimitiBiyoriApp extends StatelessWidget {
  const YorimitiBiyoriApp({
    super.key,
    this.settingsRepository,
    this.notificationController,
  });

  /// テスト用に差し替え可能。null なら通常の [SettingsRepository] を使う。
  final SettingsRepository? settingsRepository;
  final NotificationController? notificationController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'よりみち日和',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // UI プロトタイプのグリーン基調（primary #3F6F44）に合わせる。
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F6F44)),
        useMaterial3: true,
      ),
      home: OnboardingGate(
        settingsRepository: settingsRepository ?? SettingsRepository(),
        notificationController: notificationController ?? NotificationService(),
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

    final completedSettings = widget.initialSettings.copyWith(
      selectedCategories: _selectedCategoryIds,
      detailSettings: const {},
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
      HistoryPage(
        onGoToSuggestions: () => setState(() => _currentIndex = 0),
      ),
      SettingsPage(notificationController: _notificationController),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
