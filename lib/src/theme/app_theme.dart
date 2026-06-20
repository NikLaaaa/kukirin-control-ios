import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const background = Color(0xFF07111F);
  static const backgroundSoft = Color(0xFF0E1C31);
  static const panel = Color(0xFF132742);
  static const panelRaised = Color(0xFF183556);
  static const accent = Color(0xFF15D1A3);
  static const accentWarm = Color(0xFFFFB24D);
  static const accentDanger = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF4F7FB);
  static const textSecondary = Color(0xFFA5B6CC);
  static const stroke = Color(0xFF25476F);
}

class AppTheme {
  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.accent,
        secondary: AppPalette.accentWarm,
        surface: AppPalette.panel,
        error: AppPalette.accentDanger,
      ),
    );

    final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
      bodyColor: AppPalette.textPrimary,
      displayColor: AppPalette.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppPalette.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppPalette.stroke),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppPalette.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.backgroundSoft,
        indicatorColor: AppPalette.accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppPalette.textPrimary
                : AppPalette.textSecondary,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppPalette.panelRaised,
        selectedColor: AppPalette.accent.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppPalette.stroke),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.panelRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppPalette.accent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.accent,
          foregroundColor: AppPalette.background,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.textPrimary,
          side: const BorderSide(color: AppPalette.stroke),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppPalette.stroke),
    );
  }
}
