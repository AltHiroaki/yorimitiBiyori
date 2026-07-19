import 'package:flutter/material.dart';

import '../../app/app_shell.dart';
import '../../models/user_settings.dart';
import '../../repositories/settings_repository.dart';
import '../notifications/notification_service.dart';
import 'onboarding_flow.dart';

/// 初回起動が完了していなければ [OnboardingFlow] を、
/// 完了済みなら [AppShell]（3 タブ本体）を表示する分岐点。
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
