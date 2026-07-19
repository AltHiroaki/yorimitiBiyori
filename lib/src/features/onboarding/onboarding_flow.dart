import 'package:flutter/material.dart';

import '../../models/user_settings.dart';
import '../../repositories/settings_repository.dart';
import '../notifications/notification_service.dart';
import 'category_select_page.dart';
import 'notification_permission_dialog.dart';
import 'welcome_modal.dart';

/// 初回起動時のオンボーディング：
/// ウェルカムモーダル → カテゴリ選択 → 通知許可 の 3 ステップ。
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
