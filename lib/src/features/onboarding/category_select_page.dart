import 'package:flutter/material.dart';

import '../../models/interest_category.dart';
import '../../widgets/neumorphic_surface.dart';
import 'onboarding_scaffold.dart';

/// オンボーディング2ステップ目。興味カテゴリを選ぶ。
class CategorySelectPage extends StatefulWidget {
  const CategorySelectPage({
    super.key,
    required this.initialSelectedCategoryIds,
    required this.onNext,
    this.onBack,
    this.onSelectionChanged,
  });

  final List<String> initialSelectedCategoryIds;
  final ValueChanged<List<String>> onNext;

  /// 前のステップへ戻る。null のときは戻る操作を表示しない。
  final VoidCallback? onBack;

  /// 戻ってきたときに選択を復元できるよう、変更のたびに親へ通知する。
  final ValueChanged<List<String>>? onSelectionChanged;

  @override
  State<CategorySelectPage> createState() => _CategorySelectPageState();
}

class _CategorySelectPageState extends State<CategorySelectPage> {
  final Set<String> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds.addAll(widget.initialSelectedCategoryIds);
  }

  /// 表示順（[InterestCategories.all] の順）に揃えた選択結果。
  List<String> get _orderedSelectedCategoryIds => [
    for (final category in InterestCategories.all)
      if (_selectedCategoryIds.contains(category.id)) category.id,
  ];

  void _toggleCategory(String categoryId) {
    setState(() {
      if (!_selectedCategoryIds.remove(categoryId)) {
        _selectedCategoryIds.add(categoryId);
      }
    });
    widget.onSelectionChanged?.call(_orderedSelectedCategoryIds);
  }

  void _submit() {
    widget.onNext(_orderedSelectedCategoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      currentStep: 2,
      onBack: widget.onBack,
      children: [
        const Text(
          '興味のあるよりみちを選んでください',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('選んだカテゴリの中から提案します。多めに選ぶほど、提案の幅が広がります。あとから変えられます。'),
        const SizedBox(height: 24),
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
        const SizedBox(height: 16),
        Text('${_selectedCategoryIds.length}つ選択中'),
      ],
      footer: SizedBox(
        width: double.infinity,
        child: NeumorphicButtonFrame(
          isPrimary: true,
          isEnabled: _selectedCategoryIds.isNotEmpty,
          child: FilledButton(
            onPressed: _selectedCategoryIds.isEmpty ? null : _submit,
            child: const Text('次へ'),
          ),
        ),
      ),
    );
  }
}
