import 'package:flutter/material.dart';

/// よりみち日和のニューモーフィズム用デザイントークン。
///
/// Material の elevation では表現できない、左上の光と右下の影を
/// [ThemeExtension] として一元管理する。
@immutable
class YorimichiNeumorphicTheme extends ThemeExtension<YorimichiNeumorphicTheme> {
  const YorimichiNeumorphicTheme({
    required this.surfaceColor,
    required this.recessedColor,
    required this.convexShadows,
    required this.primaryButtonShadows,
    required this.secondaryButtonShadows,
    required this.navigationShadows,
    required this.recessedGradient,
    required this.selectedRecessedGradient,
  });

  static const double cardRadius = 24;
  static const double heroRadius = 32;
  static const double chipRadius = 14;
  static const double pillRadius = 10;
  static const double buttonRadius = 24;

  final Color surfaceColor;
  final Color recessedColor;
  final List<BoxShadow> convexShadows;
  final List<BoxShadow> primaryButtonShadows;
  final List<BoxShadow> secondaryButtonShadows;
  final List<BoxShadow> navigationShadows;
  final LinearGradient recessedGradient;
  final LinearGradient selectedRecessedGradient;

  static YorimichiNeumorphicTheme of(BuildContext context) {
    final materialTheme = Theme.of(context);
    return materialTheme.extension<YorimichiNeumorphicTheme>() ??
        buildYorimichiNeumorphicTheme(brightness: materialTheme.brightness);
  }

  @override
  YorimichiNeumorphicTheme copyWith({
    Color? surfaceColor,
    Color? recessedColor,
    List<BoxShadow>? convexShadows,
    List<BoxShadow>? primaryButtonShadows,
    List<BoxShadow>? secondaryButtonShadows,
    List<BoxShadow>? navigationShadows,
    LinearGradient? recessedGradient,
    LinearGradient? selectedRecessedGradient,
  }) {
    return YorimichiNeumorphicTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      recessedColor: recessedColor ?? this.recessedColor,
      convexShadows: convexShadows ?? this.convexShadows,
      primaryButtonShadows: primaryButtonShadows ?? this.primaryButtonShadows,
      secondaryButtonShadows:
          secondaryButtonShadows ?? this.secondaryButtonShadows,
      navigationShadows: navigationShadows ?? this.navigationShadows,
      recessedGradient: recessedGradient ?? this.recessedGradient,
      selectedRecessedGradient:
          selectedRecessedGradient ?? this.selectedRecessedGradient,
    );
  }

  @override
  YorimichiNeumorphicTheme lerp(
    covariant YorimichiNeumorphicTheme? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }
    return YorimichiNeumorphicTheme(
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      recessedColor: Color.lerp(recessedColor, other.recessedColor, t)!,
      convexShadows: BoxShadow.lerpList(convexShadows, other.convexShadows, t)!,
      primaryButtonShadows: BoxShadow.lerpList(
        primaryButtonShadows,
        other.primaryButtonShadows,
        t,
      )!,
      secondaryButtonShadows: BoxShadow.lerpList(
        secondaryButtonShadows,
        other.secondaryButtonShadows,
        t,
      )!,
      navigationShadows: BoxShadow.lerpList(
        navigationShadows,
        other.navigationShadows,
        t,
      )!,
      recessedGradient: LinearGradient.lerp(
        recessedGradient,
        other.recessedGradient,
        t,
      )!,
      selectedRecessedGradient: LinearGradient.lerp(
        selectedRecessedGradient,
        other.selectedRecessedGradient,
        t,
      )!,
    );
  }
}

YorimichiNeumorphicTheme buildYorimichiNeumorphicTheme({
  required Brightness brightness,
}) {
  if (brightness == Brightness.dark) {
    const surfaceColor = Color(0xFF1D221C);
    const recessedColor = Color(0xFF242B23);
    return const YorimichiNeumorphicTheme(
      surfaceColor: surfaceColor,
      recessedColor: recessedColor,
      convexShadows: [
        BoxShadow(
          offset: Offset(5, 5),
          blurRadius: 14,
          color: Color(0xB3000000),
        ),
        BoxShadow(
          offset: Offset(-5, -5),
          blurRadius: 14,
          color: Color(0x663D493B),
        ),
      ],
      primaryButtonShadows: [
        BoxShadow(
          offset: Offset(0, 3),
          blurRadius: 10,
          color: Color(0xA6000000),
        ),
        BoxShadow(
          offset: Offset(0, 1),
          blurRadius: 4,
          color: Color(0x66000000),
        ),
      ],
      secondaryButtonShadows: [
        BoxShadow(
          offset: Offset(3, 3),
          blurRadius: 9,
          color: Color(0xA6000000),
        ),
        BoxShadow(
          offset: Offset(-3, -3),
          blurRadius: 9,
          color: Color(0x593D493B),
        ),
      ],
      navigationShadows: [
        BoxShadow(
          offset: Offset(0, -4),
          blurRadius: 12,
          color: Color(0x73000000),
        ),
        BoxShadow(
          offset: Offset(0, -1),
          blurRadius: 4,
          color: Color(0x3D000000),
        ),
      ],
      recessedGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF10140F), Color(0xFF354033)],
      ),
      selectedRecessedGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF142417), Color(0xFF456447)],
      ),
    );
  }

  const surfaceColor = Color(0xFFF8FBF3);
  const recessedColor = Color(0xFFEEF5E8);
  return const YorimichiNeumorphicTheme(
    surfaceColor: surfaceColor,
    recessedColor: recessedColor,
    convexShadows: [
      BoxShadow(offset: Offset(5, 5), blurRadius: 14, color: Color(0x6B8CAA86)),
      BoxShadow(
        offset: Offset(-5, -5),
        blurRadius: 14,
        color: Color(0xD9FFFFFF),
      ),
    ],
    primaryButtonShadows: [
      BoxShadow(offset: Offset(0, 3), blurRadius: 10, color: Color(0x594F8050)),
      BoxShadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x334F8050)),
    ],
    secondaryButtonShadows: [
      BoxShadow(offset: Offset(3, 3), blurRadius: 9, color: Color(0x618CAA86)),
      BoxShadow(
        offset: Offset(-3, -3),
        blurRadius: 9,
        color: Color(0xD9FFFFFF),
      ),
    ],
    navigationShadows: [
      BoxShadow(
        offset: Offset(0, -4),
        blurRadius: 12,
        color: Color(0x338CAA86),
      ),
      BoxShadow(offset: Offset(0, -1), blurRadius: 4, color: Color(0x1F8CAA86)),
    ],
    recessedGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x4D8CAA86), Color(0xCCFFFFFF)],
    ),
    selectedRecessedGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0x47807850), Color(0xD1D7FAD7)],
    ),
  );
}
