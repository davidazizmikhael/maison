import 'package:flutter/material.dart';

/// Fixed brand constants — used on the always-dark surfaces (onboarding,
/// bootstrap, camera, the navy hero cards) that look the same in both themes.
class MaisonColors {
  static const ink = Color(0xFF1B2432);
  static const inkSoft = Color(0xFF4A5568);
  static const paper = Color(0xFFFAF7F2);
  static const card = Colors.white;
  static const accent = Color(0xFFD97742);
  static const accentDeep = Color(0xFFB85C2E);
  static const navy = Color(0xFF1F3A5F);
  static const green = Color(0xFF3E7A5E);
  static const red = Color(0xFFB0492F);
  static const line = Color(0xFFE4DDD2);
  static const accentWash = Color(0xFFFBE9DD);
  static const navyWash = Color(0xFFE2E9F2);
  static const greenWash = Color(0xFFE0EFE7);
}

/// Theme-aware palette. Widgets read it via `context.mc` so every screen
/// adapts to light/dark automatically.
class MaisonPalette extends ThemeExtension<MaisonPalette> {
  const MaisonPalette({
    required this.paper,
    required this.card,
    required this.ink,
    required this.inkSoft,
    required this.line,
    required this.accent,
    required this.accentDeep,
    required this.navy,
    required this.green,
    required this.red,
    required this.accentWash,
    required this.navyWash,
    required this.greenWash,
  });

  final Color paper;
  final Color card;
  final Color ink;
  final Color inkSoft;
  final Color line;
  final Color accent;
  final Color accentDeep;
  final Color navy;
  final Color green;
  final Color red;
  final Color accentWash;
  final Color navyWash;
  final Color greenWash;

  static const light = MaisonPalette(
    paper: MaisonColors.paper,
    card: MaisonColors.card,
    ink: MaisonColors.ink,
    inkSoft: MaisonColors.inkSoft,
    line: MaisonColors.line,
    accent: MaisonColors.accent,
    accentDeep: MaisonColors.accentDeep,
    navy: MaisonColors.navy,
    green: MaisonColors.green,
    red: MaisonColors.red,
    accentWash: MaisonColors.accentWash,
    navyWash: MaisonColors.navyWash,
    greenWash: MaisonColors.greenWash,
  );

  static const dark = MaisonPalette(
    paper: Color(0xFF15181F),
    card: Color(0xFF1F242E),
    ink: Color(0xFFEFEAE2),
    inkSoft: Color(0xFF9AA3B2),
    line: Color(0xFF313845),
    accent: Color(0xFFE2854F),
    accentDeep: Color(0xFFF0A379),
    navy: Color(0xFF9DB8DC),
    green: Color(0xFF7FBF9E),
    red: Color(0xFFE07B62),
    accentWash: Color(0xFF3B2A1F),
    navyWash: Color(0xFF263141),
    greenWash: Color(0xFF1F3329),
  );

  @override
  MaisonPalette copyWith() => this;

  @override
  MaisonPalette lerp(MaisonPalette? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension MaisonThemeX on BuildContext {
  MaisonPalette get mc => Theme.of(this).extension<MaisonPalette>()!;
}

ThemeData maisonTheme(Brightness brightness) {
  final p = brightness == Brightness.dark ? MaisonPalette.dark : MaisonPalette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: brightness,
      primary: p.accent,
      secondary: p.navy,
      surface: p.paper,
    ),
    scaffoldBackgroundColor: p.paper,
  );
  return base.copyWith(
    extensions: [p],
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: p.paper,
      foregroundColor: p.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: p.ink, fontSize: 18, fontWeight: FontWeight.w800),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.accent,
      foregroundColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark ? const Color(0xFF2E3644) : MaisonColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Small rounded tag chip used across screens. Defaults follow the theme.
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.color, this.textColor});
  final String label;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? context.mc.navyWash,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: textColor ?? context.mc.navy)),
    );
  }
}
