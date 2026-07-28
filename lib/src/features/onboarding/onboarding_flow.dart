import 'package:flutter/material.dart';

import '../../models/user_settings.dart';
import '../../repositories/settings_repository.dart';
import '../notifications/notification_service.dart';
import 'category_select_page.dart';
import 'notification_permission_page.dart';
import 'welcome_page.dart';

/// 初回起動時のオンボーディング：
/// ウェルカム → カテゴリ選択 → 通知許可 の 3 ステップ。
/// 3 ステップとも全画面ページで、2 ステップ目以降は前へ戻れる。
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

  void _goTo(_OnboardingStep step) {
    setState(() {
      _step = step;
    });
  }

  /// 前のステップへ戻る。最初のステップでは何もしない。
  void _goBack() {
    switch (_step) {
      case _OnboardingStep.welcome:
        break;
      case _OnboardingStep.category:
        _goTo(_OnboardingStep.welcome);
      case _OnboardingStep.notification:
        _goTo(_OnboardingStep.category);
    }
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

  Widget _buildStep() {
    switch (_step) {
      case _OnboardingStep.welcome:
        return WelcomePage(onStart: () => _goTo(_OnboardingStep.category));
      case _OnboardingStep.category:
        return CategorySelectPage(
          initialSelectedCategoryIds: _selectedCategoryIds,
          onSelectionChanged: (selectedCategoryIds) {
            // 戻ってきたときに選び直さなくて済むよう、都度覚えておく。
            _selectedCategoryIds = selectedCategoryIds;
          },
          onBack: _goBack,
          onNext: (selectedCategoryIds) {
            _selectedCategoryIds = selectedCategoryIds;
            _goTo(_OnboardingStep.notification);
          },
        );
      case _OnboardingStep.notification:
        return NotificationPermissionPage(
          onSelected: _complete,
          onBack: _goBack,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 最初のステップより前には戻さず、端末の戻る操作は通常どおり扱う。
      canPop: _step == _OnboardingStep.welcome,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _goBack();
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_step), child: _buildStep()),
      ),
    );
  }
}
