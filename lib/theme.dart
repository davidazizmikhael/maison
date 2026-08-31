import 'package:flutter/material.dart';

/// Maison brand palette — mirrors the concept deck.
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

ThemeData maisonTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MaisonColors.accent,
      primary: MaisonColors.accent,
      secondary: MaisonColors.navy,
      surface: MaisonColors.paper,
    ),
    scaffoldBackgroundColor: MaisonColors.paper,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: MaisonColors.ink,
      displayColor: MaisonColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: MaisonColors.paper,
      foregroundColor: MaisonColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: MaisonColors.ink,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: MaisonColors.accent,
      foregroundColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MaisonColors.accent,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MaisonColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Small rounded tag chip used across screens.
class Tag extends StatelessWidget {
  const Tag(this.label, {super.key, this.color = MaisonColors.navyWash, this.textColor = MaisonColors.navy});
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: textColor)),
    );
  }
}
