import 'package:flutter/material.dart';

const int onboardingStepCount = 3;

/// オンボーディング全画面で現在位置を一貫して示す進捗表示。
class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({super.key, required this.currentStep})
    : assert(currentStep >= 1 && currentStep <= onboardingStepCount);

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'オンボーディング ステップ $currentStep / $onboardingStepCount',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ステップ $currentStep / $onboardingStepCount',
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var step = 1; step <= onboardingStepCount; step++) ...[
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
                if (step != onboardingStepCount) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
