import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const primary = Color(0xFFD86E42);
  static const primarySoft = Color(0xFFFFF0E8);
  static const secondary = Color(0xFF718875);
  static const background = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF2F302C);
  static const muted = Color(0xFF85847E);
  static const border = Color(0xFFECE7DF);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppPalette.primary,
          secondary: AppPalette.secondary,
          surface: AppPalette.surface,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppPalette.background,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 29,
          height: 1.16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          color: AppPalette.ink,
          fontSize: 23,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: AppPalette.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppPalette.ink, fontSize: 15, height: 1.55),
        bodyMedium: TextStyle(
          color: AppPalette.muted,
          fontSize: 13,
          height: 1.45,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surface,
        hintStyle: const TextStyle(color: AppPalette.muted),
        prefixIconColor: AppPalette.muted,
        suffixIconColor: AppPalette.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.surface,
        elevation: 1.5,
        shadowColor: AppPalette.ink.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
