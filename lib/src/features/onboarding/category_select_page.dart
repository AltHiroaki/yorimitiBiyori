import 'package:flutter/material.dart';

import '../../models/interest_category.dart';
import '../../widgets/neumorphic_surface.dart';

/// オンボーディングのカテゴリ選択ステップ。
class CategorySelectPage extends StatefulWidget {
  const CategorySelectPage({
    super.key,
    required this.initialSelectedCategoryIds,
    required this.onNext,
  });

  final List<String> initialSelectedCategoryIds;
  final ValueChanged<List<String>> onNext;

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

  void _toggleCategory(String categoryId) {
    setState(() {
      if (!_selectedCategoryIds.remove(categoryId)) {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _submit() {
    final selectedCategoryIds = [
      for (final category in InterestCategories.all)
        if (_selectedCategoryIds.contains(category.id)) category.id,
    ];
    widget.onNext(selectedCategoryIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _OnboardingProgress(currentStep: 2),
            const SizedBox(height: 28),
            const Text(
              '興味のあるよりみちを選んでください',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('気になるカテゴリを複数選べます。詳細設定はあとから調整できます。'),
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
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
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
        ),
      ),
    );
  }
}

class _OnboardingProgress extends StatelessWidget {
  const _OnboardingProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var step = 1; step <= 3; step++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: step <= currentStep
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (step != 3) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
