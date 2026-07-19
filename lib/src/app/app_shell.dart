import 'dart:async';

import 'package:flutter/material.dart';

import '../features/notifications/notification_service.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/suggestion_page.dart';
import '../repositories/settings_repository.dart';
import '../widgets/neumorphic_surface.dart';

const Duration _tabFadeDuration = Duration(milliseconds: 200);
const Duration _completionNavigationDuration = Duration(milliseconds: 400);
const ValueKey<String> _completionHistoryPageKey =
    ValueKey<String>('completion-history');

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
      bottomNavigationBar: NeumorphicNavigationSurface(
        child: NavigationBar(
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
      ),
    );
  }
}
