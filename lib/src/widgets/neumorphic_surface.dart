import 'package:flutter/material.dart';

import '../app/yorimiti_neumorphic_theme.dart';

/// 左上のハイライトと右下の影で、背景から浮き上がる面を描画する。
class NeumorphicSurface extends StatelessWidget {
  const NeumorphicSurface({
    required this.child,
    this.radius = YorimitiNeumorphicTheme.cardRadius,
    this.padding,
    super.key,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final neumorphicTheme = YorimitiNeumorphicTheme.of(context);
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: neumorphicTheme.surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: neumorphicTheme.convexShadows,
      ),
      child: child,
    );
  }
}

/// 既存の Material ボタンを保ったままニューモーフィズムの影を追加する。
class NeumorphicButtonFrame extends StatelessWidget {
  const NeumorphicButtonFrame({
    required this.child,
    this.isPrimary = false,
    this.isEnabled = true,
    super.key,
  });

  final Widget child;
  final bool isPrimary;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final neumorphicTheme = YorimitiNeumorphicTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          YorimitiNeumorphicTheme.buttonRadius,
        ),
        boxShadow: isEnabled
            ? (isPrimary
                  ? neumorphicTheme.primaryButtonShadows
                  : neumorphicTheme.secondaryButtonShadows)
            : const [],
      ),
      child: child,
    );
  }
}

/// CSS の inset shadow を、暗→明の細い内側リムで近似する。
///
/// [FilterChip] や [ChoiceChip] 自体を子に残すため、Material の操作性と
/// セマンティクスは維持される。
class NeumorphicChipFrame extends StatelessWidget {
  const NeumorphicChipFrame({
    required this.child,
    this.isSelected = false,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final bool isSelected;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final neumorphicTheme = YorimitiNeumorphicTheme.of(context);
    final radius = BorderRadius.circular(YorimitiNeumorphicTheme.chipRadius);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: isSelected
            ? neumorphicTheme.selectedRecessedGradient
            : neumorphicTheme.recessedGradient,
        borderRadius: radius,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : neumorphicTheme.recessedColor),
          borderRadius: radius,
        ),
        child: child,
      ),
    );
  }
}

/// 選択コントロール全体を背景へ沈ませるための凹型サーフェス。
class NeumorphicRecessedSurface extends StatelessWidget {
  const NeumorphicRecessedSurface({
    required this.child,
    this.radius = YorimitiNeumorphicTheme.buttonRadius,
    super.key,
  });

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final neumorphicTheme = YorimitiNeumorphicTheme.of(context);
    final borderRadius = BorderRadius.circular(radius);
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: neumorphicTheme.recessedGradient,
        borderRadius: borderRadius,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: neumorphicTheme.recessedColor,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

/// 上方向の影で画面本体から浮かせたナビゲーション領域。
class NeumorphicNavigationSurface extends StatelessWidget {
  const NeumorphicNavigationSurface({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final neumorphicTheme = YorimitiNeumorphicTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: neumorphicTheme.surfaceColor,
        boxShadow: neumorphicTheme.navigationShadows,
      ),
      child: child,
    );
  }
}
