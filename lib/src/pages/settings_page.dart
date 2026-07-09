import 'package:flutter/material.dart';

import '../features/notifications/notification_service.dart';
import '../models/user_settings.dart';
import '../repositories/records_repository.dart';
import '../repositories/settings_repository.dart';
import '../widgets/section_card.dart';
import 'suggestion_settings_page.dart';

typedef NotificationTimePicker = Future<TimeOfDay?> Function(
  BuildContext context,
  TimeOfDay initialTime,
);

/// 設定タブ。
/// UI プロトタイプの「03 設定」に対応する。
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.recordsRepository,
    this.settingsRepository,
    this.notificationController,
    this.notificationTimePicker,
  });

  /// テスト用に差し替え可能。null なら通常の repository を使う。
  final RecordsRepository? recordsRepository;
  final SettingsRepository? settingsRepository;
  final NotificationController? notificationController;
  final NotificationTimePicker? notificationTimePicker;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final RecordsRepository _recordsRepository;
  late final SettingsRepository _settingsRepository;
  late final NotificationController _notificationController;

  /// 履歴削除のインライン確認を表示中かどうか（仕様書 3.3）。
  bool _showDeleteConfirm = false;
  bool _isNotificationSaving = false;
  UserSettings _settings = const UserSettings();

  @override
  void initState() {
    super.initState();
    _recordsRepository = widget.recordsRepository ?? RecordsRepository();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _notificationController =
        widget.notificationController ?? NotificationService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepository.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
    });
  }

  /// 履歴削除を実行し、確認を閉じてから完了を SnackBar で知らせる。
  /// 取り消しはできない。
  Future<void> _deleteAllRecords() async {
    await _recordsRepository.deleteAllRecords();
    if (!mounted) {
      return;
    }
    setState(() {
      _showDeleteConfirm = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('履歴を削除しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          '設定',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          '興味カテゴリ、通知時刻、履歴を管理します。',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildSuggestionSettingsCard(),
        const SizedBox(height: 12),
        const SectionCard(
          title: '興味カテゴリ',
          description: '音楽、料理、読書、映画から複数選択できるようにします。',
        ),
        const SizedBox(height: 12),
        _buildNotificationCard(),
        const SizedBox(height: 12),
        _buildDeleteHistoryCard(),
      ],
    );
  }

  Widget _buildSuggestionSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '提案設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('興味カテゴリとカテゴリ別の詳細設定を調整できます。'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: _openSuggestionSettings,
                child: const Text('提案設定を開く'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSuggestionSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SuggestionSettingsPage(
          settingsRepository: _settingsRepository,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadSettings();
  }

  Widget _buildNotificationCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '通知',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: _settings.notificationEnabled,
                  onChanged:
                      _isNotificationSaving ? null : _updateNotificationEnabled,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '毎日 ${_settings.notificationTime} によりみちのきっかけを届けます。',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '通知時刻：${_settings.notificationTime}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                OutlinedButton(
                  onPressed:
                      _isNotificationSaving ? null : _pickNotificationTime,
                  child: const Text('変更'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateNotificationEnabled(bool isEnabled) async {
    var nextSettings = _settings.copyWith(notificationEnabled: isEnabled);
    if (isEnabled) {
      final isGranted = await _notificationController.requestPermission();
      nextSettings = nextSettings.copyWith(notificationEnabled: isGranted);
      if (!isGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('通知を有効にするには、端末の通知許可が必要です')),
        );
      }
    }
    await _saveNotificationSettings(nextSettings);
  }

  Future<void> _pickNotificationTime() async {
    final initialTime = _parseTimeOfDay(_settings.notificationTime);
    final picker = widget.notificationTimePicker ?? _showNotificationTimePicker;
    final pickedTime = await picker(context, initialTime);
    if (pickedTime == null) {
      return;
    }

    await _saveNotificationSettings(
      _settings.copyWith(notificationTime: _formatTimeOfDay(pickedTime)),
    );
  }

  Future<TimeOfDay?> _showNotificationTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
  ) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: '通知時刻',
      cancelText: 'キャンセル',
      confirmText: '決定',
    );
  }

  Future<void> _saveNotificationSettings(UserSettings settings) async {
    setState(() {
      _isNotificationSaving = true;
    });

    try {
      await _settingsRepository.saveSettings(settings);
      await _notificationController.applySettings(settings);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isNotificationSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('通知設定を保存できませんでした')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _settings = settings;
      _isNotificationSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知設定を保存しました')),
    );
  }

  TimeOfDay _parseTimeOfDay(String source) {
    final notificationTime = parseNotificationTime(source);
    return TimeOfDay(
      hour: notificationTime.hour,
      minute: notificationTime.minute,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 履歴削除カード：通常時は「削除」ボタン、タップするとインライン確認に切り替わる。
  Widget _buildDeleteHistoryCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _showDeleteConfirm
            ? _buildDeleteConfirmContent()
            : _buildDeleteNormalContent(colorScheme),
      ),
    );
  }

  /// 通常状態：タイトル（赤字）とサブ文言、右に「削除」ボタン。
  Widget _buildDeleteNormalContent(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '履歴削除',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '端末内に保存した履歴を削除',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _showDeleteConfirm = true;
            });
          },
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: const Text('削除'),
        ),
      ],
    );
  }

  /// 確認状態：注意文言と「キャンセル」「削除する」ボタン。
  Widget _buildDeleteConfirmContent() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('本当に削除しますか？この操作は取り消せません。'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () {
                  setState(() {
                    _showDeleteConfirm = false;
                  });
                },
                child: const Text('キャンセル'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: _deleteAllRecords,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                child: const Text('削除する'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
