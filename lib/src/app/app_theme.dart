import 'package:flutter/material.dart';

import 'yorimiti_neumorphic_theme.dart';

/// UI プロトタイプのカラーパレット（`よりみち日和 UIプロトタイプ/` の定数 C に対応）。
const Color _primarySeedColor = Color(0xFF3F6F44);
const Color _pageBackgroundColor = Color(0xFFF8FBF3);
const Color _surfaceVariantColor = Color(0xFFEEF5E8);
const Color _primaryContainerColor = Color(0xFFC2E8C0);
const Color _darkPageBackgroundColor = Color(0xFF1D221C);
const Color _darkSurfaceVariantColor = Color(0xFF242B23);

/// Issue #66 のニューモーフィズムトークンを集約したアプリテーマ。
ThemeData buildYorimitiBiyoriTheme({Brightness brightness = Brightness.light}) {
  final baseColorScheme = ColorScheme.fromSeed(
    seedColor: _primarySeedColor,
    brightness: brightness,
  );
  final isDark = brightness == Brightness.dark;
  final surfaceColor = isDark ? _darkPageBackgroundColor : _pageBackgroundColor;
  final surfaceVariantColor = isDark
      ? _darkSurfaceVariantColor
      : _surfaceVariantColor;
  final colorScheme = baseColorScheme.copyWith(
    primary: isDark ? baseColorScheme.primary : _primarySeedColor,
    primaryContainer: isDark
        ? baseColorScheme.primaryContainer
        : _primaryContainerColor,
    surface: surfaceColor,
    surfaceContainerLowest: surfaceColor,
    surfaceContainerLow: surfaceColor,
    surfaceContainer: surfaceColor,
    surfaceContainerHigh: surfaceVariantColor,
    surfaceContainerHighest: surfaceVariantColor,
  );
  final roundedButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.buttonRadius),
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    fontFamily: 'ZenMaruGothic',
    fontFamilyFallback: const ['Noto Sans JP', 'sans-serif'],
    scaffoldBackgroundColor: surfaceColor,
    canvasColor: surfaceColor,
    extensions: [buildYorimitiNeumorphicTheme(brightness: brightness)],
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.cardRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      elevation: 0,
      indicatorColor: colorScheme.primaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.pillRadius),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: Colors.transparent,
      disabledColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      showCheckmark: false,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.chipRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        elevation: 0,
        shape: roundedButtonShape,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        elevation: 0,
        backgroundColor: surfaceColor,
        side: BorderSide.none,
        shape: roundedButtonShape,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide.none),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? colorScheme.primaryContainer
              : Colors.transparent;
        }),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(YorimitiNeumorphicTheme.heroRadius),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(YorimitiNeumorphicTheme.heroRadius),
        ),
      ),
    ),
  );
}
