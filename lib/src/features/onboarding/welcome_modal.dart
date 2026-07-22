import 'package:flutter/material.dart';

import '../../app/yorimichi_neumorphic_theme.dart';
import '../../widgets/neumorphic_surface.dart';

/// 初回起動時に表示するウェルカムモーダル。
class WelcomeModal extends StatelessWidget {
  const WelcomeModal({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: NeumorphicSurface(
        radius: YorimichiNeumorphicTheme.heroRadius,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'よりみち日和へようこそ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('空いた時間にできる、小さなよりみちを提案します。まずは気になるカテゴリを選んでみましょう。'),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: NeumorphicButtonFrame(
                isPrimary: true,
                child: FilledButton(
                  onPressed: onStart,
                  child: const Text('はじめる'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
