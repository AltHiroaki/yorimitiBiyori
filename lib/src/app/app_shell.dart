import 'dart:async';

import 'package:flutter/material.dart';

import '../features/notifications/notification_service.dart';
import '../pages/history_page.dart';
import '../pages/settings_page.dart';
import '../pages/suggestion_page.dart';
import '../repositories/settings_repository.dart';
import '../widgets/neumorphic_surface.dart';

/// 隣接タブ（提案 ↔ 履歴 ↔ 設定）をタップしたときのスライド時間。
/// 横スワイプで指を離したときの吸着と同じ見え方になる長さにする。
const Duration appShellTabSlideDuration = Duration(milliseconds: 260);

/// 飛び越し（提案 ↔ 設定）のフェード時間。中間の履歴ページは見せない。
const Duration appShellTabFadeDuration = Duration(milliseconds: 200);

/// 完了 → 履歴の特別演出の時間。通常のタブ移動と区別できるよう長めにとる。
const Duration appShellCompletionNavigationDuration =
    Duration(milliseconds: 400);

/// 完了演出でページを滑り込ませる量（ページ幅に対する比率）。
const Offset _completionSlideBegin = Offset(0.12, 0);

/// タブ本体に掛かるスライドを取り出すためのキー（テスト用）。
const Key appShellTabSlideKey = ValueKey<String>('app-shell-tab-slide');

/// タブ本体に掛かるフェードを取り出すためのキー（テスト用）。
const Key appShellTabFadeKey = ValueKey<String>('app-shell-tab-fade');

const Animation<Offset> _noSlide = AlwaysStoppedAnimation<Offset>(Offset.zero);

/// UI プロトタイプどおりの 3 タブ構成。ホーム画面は持たず、提案タブをトップにする。
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.notificationController});

  final NotificationController? notificationController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  late final NotificationController _notificationController;
  late final AnimationController _historyImpactController;
  late final Animation<double> _historyImpactScale;
  late final PageController _pageController;

  /// 飛び越し・完了演出のときだけ 0 → 1 で動かす。
  /// 通常時とスワイプ中は 1.0（＝演出なし）で止めておく。
  late final AnimationController _jumpTransitionController;
  late final Animation<Offset> _completionSlide;

  final GlobalKey _historyDestinationKey = GlobalKey();
  int _currentIndex = 0;
  bool _isCompletionNavigation = false;
  bool _disableAnimations = false;
  String? _highlightedRecordId;

  @override
  void initState() {
    super.initState();
    _notificationController =
        widget.notificationController ?? NotificationService();
    _pageController = PageController();
    _jumpTransitionController = AnimationController(
      vsync: this,
      duration: appShellTabFadeDuration,
      value: 1,
    );
    _completionSlide = Tween<Offset>(
      begin: _completionSlideBegin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _jumpTransitionController,
        curve: Curves.easeOutCubic,
      ),
    );
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
    _jumpTransitionController.dispose();
    _pageController.dispose();
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

  /// タブのタップ・アプリ内からのタブ切替の入口。
  /// 隣接（±1）はスライド、飛び越し（±2）は中間ページを見せずフェードする。
  void _selectTab(int index) {
    if (index == _currentIndex) {
      return;
    }
    final isAdjacent = (index - _currentIndex).abs() == 1;
    setState(() {
      _currentIndex = index;
      _isCompletionNavigation = false;
      _highlightedRecordId = null;
    });

    if (_disableAnimations) {
      _jumpToPage(index, fadeDuration: null);
    } else if (isAdjacent) {
      _slideToPage(index);
    } else {
      _jumpToPage(index, fadeDuration: appShellTabFadeDuration);
    }
  }

  /// 横スワイプ・[PageController] のアニメーションによるページ変更を
  /// タブの選択状態へ反映する。タップ由来の移動は先に [_currentIndex] を
  /// 更新しているため、ここでは何もしない。
  void _handlePageChanged(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
      _isCompletionNavigation = false;
      _highlightedRecordId = null;
    });
  }

  void _slideToPage(int index) {
    _jumpTransitionController.value = 1;
    if (!_pageController.hasClients) {
      return;
    }
    unawaited(
      _pageController.animateToPage(
        index,
        duration: appShellTabSlideDuration,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// 中間ページを見せずに切り替える。
  /// [fadeDuration] が null のときはフェードもせず即時に差し替える。
  void _jumpToPage(int index, {required Duration? fadeDuration}) {
    if (_pageController.hasClients) {
      _pageController.jumpToPage(index);
    }
    if (fadeDuration == null) {
      _jumpTransitionController.value = 1;
      return;
    }
    _jumpTransitionController.duration = fadeDuration;
    _jumpTransitionController.forward(from: 0);
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
    // 完了直後は提案カードが吸い込まれた後なので、隣へスライドさせるより
    // 履歴ページを滑り込ませたほうが「記録された」感触が強く残る。
    _jumpToPage(
      1,
      fadeDuration:
          _disableAnimations ? null : appShellCompletionNavigationDuration,
    );
    _historyImpactController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    _disableAnimations = MediaQuery.disableAnimationsOf(context);

    // 履歴の空状態から提案タブへ切り替えられるようコールバックを渡すため、
    // ページはビルド時に組み立てる（タブ切替時に再生成され履歴も読み直される）。
    final pages = <Widget>[
      SuggestionPage(
        historyDestinationKey: _historyDestinationKey,
        onSuggestionCompleted: _handleSuggestionCompleted,
      ),
      HistoryPage(
        // スワイプ中は隣のページも build されるため、履歴タブとして
        // 表示が確定してから読み込ませる。
        isActive: _currentIndex == 1,
        highlightedRecordId: _highlightedRecordId,
        onGoToSuggestions: () => _selectTab(0),
        onSuggestionRevived: () => _selectTab(0),
      ),
      SettingsPage(notificationController: _notificationController),
    ];

    return Scaffold(
      body: SafeArea(
        child: SlideTransition(
          key: appShellTabSlideKey,
          position: _isCompletionNavigation ? _completionSlide : _noSlide,
          child: FadeTransition(
            key: appShellTabFadeKey,
            opacity: _jumpTransitionController,
            child: PageView(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              children: pages,
            ),
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
