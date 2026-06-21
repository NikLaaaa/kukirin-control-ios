import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppPalette {
  static const background = Color(0xFFF5F6F8);
  static const backgroundSoft = Color(0xFFFFFFFF);
  static const panel = Color(0xFFFFFFFF);
  static const panelRaised = Color(0xFFF0F2F5);
  static const accent = Color(0xFFFF6B00);
  static const accentWarm = Color(0xFFFF8A1F);
  static const accentGreen = Color(0xFF22C55E);
  static const accentDanger = Color(0xFFFF4D4F);
  static const textPrimary = Color(0xFF101114);
  static const textSecondary = Color(0xFF6C7280);
  static const textTertiary = Color(0xFF9AA1AE);
  static const stroke = Color(0xFFE6E9EF);
  static const graphite = Color(0xFF1D1F24);
}

class AppTheme {
  static ThemeData get themeData {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppPalette.accent,
        secondary: AppPalette.accentGreen,
        surface: AppPalette.panel,
        error: AppPalette.accentDanger,
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppPalette.textPrimary,
      displayColor: AppPalette.textPrimary,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppPalette.panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppPalette.stroke),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppPalette.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 78,
        backgroundColor: AppPalette.panel.withValues(alpha: 0.96),
        elevation: 0,
        indicatorColor: AppPalette.accent.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 25,
            color: states.contains(WidgetState.selected)
                ? AppPalette.accent
                : AppPalette.textTertiary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppPalette.accent
                : AppPalette.textSecondary,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppPalette.panelRaised,
        selectedColor: AppPalette.accent.withValues(alpha: 0.12),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: AppPalette.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.panelRaised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.accent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppPalette.panelRaised,
          disabledForegroundColor: AppPalette.textTertiary,
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.textPrimary,
          disabledForegroundColor: AppPalette.textTertiary,
          side: const BorderSide(color: AppPalette.stroke),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.panelRaised,
          foregroundColor: AppPalette.textPrimary,
          disabledBackgroundColor: AppPalette.panelRaised,
          disabledForegroundColor: AppPalette.textTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppPalette.accent
              : const Color(0xFFDCE0E6),
        ),
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerTheme: const DividerThemeData(color: AppPalette.stroke),
    );
  }
}
