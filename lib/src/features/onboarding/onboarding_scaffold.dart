import 'package:flutter/material.dart';

import 'onboarding_progress.dart';

/// オンボーディング3ステップ共通の器。
///
/// 上部に「戻る」と進捗、中央にスクロールする本文、下部に固定の操作ボタンを置く。
/// 3ステップで同じ構造にすることで、モーダルと全画面が混ざった見え方を避ける。
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.currentStep,
    required this.children,
    required this.footer,
    this.onBack,
  });

  final int currentStep;

  /// 本文。ListView の children としてそのまま並べる。
  final List<Widget> children;

  /// 画面下部に固定する操作ボタン。文字サイズを大きくしても隠れない。
  final Widget footer;

  /// 前のステップへ戻る。最初のステップでは null。
  /// null でも領域は確保し、進捗バーの位置がステップ間でずれないようにする。
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final onBack = this.onBack;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox.square(
                  dimension: 48,
                  child: onBack == null
                      ? null
                      : IconButton(
                          onPressed: onBack,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: '前のステップに戻る',
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OnboardingProgress(currentStep: currentStep),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                children: children,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: footer,
        ),
      ),
    );
  }
}
