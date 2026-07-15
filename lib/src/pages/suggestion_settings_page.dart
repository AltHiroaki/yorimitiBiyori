import 'package:flutter/material.dart';

import '../models/interest_category.dart';
import '../models/user_settings.dart';
import '../repositories/settings_repository.dart';
import '../widgets/neumorphic_surface.dart';

/// 提案設定画面（サブ画面・二段階方式）。
/// 仕様書 3.4 に対応する。第 1 段階で興味カテゴリを、
/// 第 2 段階で選択中カテゴリごとの詳細設定グループを FilterChip で編集する。
class SuggestionSettingsPage extends StatefulWidget {
  const SuggestionSettingsPage({super.key, this.settingsRepository});

  /// テスト用に差し替え可能。null なら通常の [SettingsRepository] を使う。
  final SettingsRepository? settingsRepository;

  @override
  State<SuggestionSettingsPage> createState() => _SuggestionSettingsPageState();
}

class _SuggestionSettingsPageState extends State<SuggestionSettingsPage> {
  late final SettingsRepository _settingsRepository;

  /// 読込済みの設定。通知設定など、この画面で編集しないフィールドを
  /// 保存時に温存するために保持する。
  UserSettings? _loadedSettings;

  final Set<String> _selectedCategoryIds = {};

  /// カテゴリ id → グループ id → 選択値。
  /// カテゴリの選択を外しても編集内容は残し、保存時に選択中カテゴリ分だけ刈り込む。
  final Map<String, Map<String, Set<String>>> _detailSelections = {};

  @override
  void initState() {
    super.initState();
    _settingsRepository = widget.settingsRepository ?? SettingsRepository();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepository.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() {
      _loadedSettings = settings;
      _selectedCategoryIds
        ..clear()
        ..addAll(settings.selectedCategories);
      _detailSelections.clear();
      settings.detailSettings.forEach((categoryId, groups) {
        _detailSelections[categoryId] = {
          for (final entry in groups.entries) entry.key: entry.value.toSet(),
        };
      });
    });
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (!_selectedCategoryIds.remove(categoryId)) {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _toggleDetailValue(String categoryId, String groupId, String value) {
    setState(() {
      final groupSelections = _detailSelections
          .putIfAbsent(categoryId, () => {})
          .putIfAbsent(groupId, () => {});
      if (!groupSelections.remove(value)) {
        groupSelections.add(value);
      }
    });
  }

  /// カテゴリを初期値（音楽・読書・散歩）に、詳細設定をすべて未選択（指定なし）に戻す。
  /// 「この条件で保存」を押すまで永続化はしない。
  void _resetToDefaults() {
    setState(() {
      _selectedCategoryIds
        ..clear()
        ..addAll(defaultSelectedCategoryIds);
      _detailSelections.clear();
    });
  }

  Future<void> _save() async {
    // マスター定義の順序でカテゴリを並べ、表示順と保存順を一致させる。
    final selectedCategories = [
      for (final category in InterestCategories.all)
        if (_selectedCategoryIds.contains(category.id)) category.id,
    ];

    // 選択中カテゴリの、値が選ばれているグループだけを保存する。
    // 未選択グループは含めない＝「指定なし」として扱われる。
    final detailSettings = <String, Map<String, List<String>>>{};
    for (final categoryId in selectedCategories) {
      final groups = _detailSelections[categoryId];
      if (groups == null) {
        continue;
      }
      final selectedGroups = <String, List<String>>{
        for (final entry in groups.entries)
          if (entry.value.isNotEmpty) entry.key: entry.value.toList(),
      };
      if (selectedGroups.isNotEmpty) {
        detailSettings[categoryId] = selectedGroups;
      }
    }

    final settings = (_loadedSettings ?? const UserSettings()).copyWith(
      selectedCategories: selectedCategories,
      detailSettings: detailSettings,
    );
    await _settingsRepository.saveSettings(settings);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('提案設定')),
      body: _loadedSettings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('よりみちの条件を調整できます。'),
                const SizedBox(height: 16),
                _buildCategoryCard(),
                for (final category in InterestCategories.all)
                  if (_selectedCategoryIds.contains(category.id)) ...[
                    const SizedBox(height: 12),
                    _buildDetailSettingsCard(category),
                  ],
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: NeumorphicButtonFrame(
                  isPrimary: true,
                  isEnabled: _loadedSettings != null,
                  child: FilledButton(
                    onPressed: _loadedSettings == null ? null : _save,
                    child: const Text('この条件で保存'),
                  ),
                ),
              ),
              TextButton(
                onPressed: _resetToDefaults,
                child: const Text('初期設定に戻す'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 第 1 段階：興味カテゴリの複数選択。
  Widget _buildCategoryCard() {
    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '興味カテゴリ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in InterestCategories.all)
                  NeumorphicChipFrame(
                    isSelected: _selectedCategoryIds.contains(category.id),
                    child: FilterChip(
                      label: Text('${category.emoji} ${category.label}'),
                      selected: _selectedCategoryIds.contains(category.id),
                      onSelected: (_) => _toggleCategory(category.id),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${_selectedCategoryIds.length}つ選択中'),
          ],
        ),
      ),
    );
  }

  /// 第 2 段階：選択中カテゴリ 1 件分の詳細設定グループ。
  Widget _buildDetailSettingsCard(InterestCategory category) {
    final categorySelections = _detailSelections[category.id] ?? const {};

    return NeumorphicSurface(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${category.emoji} ${category.label}の詳細設定',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '未選択のグループは「指定なし」として絞り込みません。',
              style: TextStyle(fontSize: 12),
            ),
            for (final group in category.detailSettingGroups) ...[
              const SizedBox(height: 12),
              Text(
                group.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in group.options)
                    NeumorphicChipFrame(
                      isSelected:
                          categorySelections[group.id]?.contains(option) ??
                          false,
                      child: FilterChip(
                        label: Text(option),
                        selected:
                            categorySelections[group.id]?.contains(option) ??
                            false,
                        onSelected: (_) =>
                            _toggleDetailValue(category.id, group.id, option),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
