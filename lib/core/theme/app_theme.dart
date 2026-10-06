import 'package:flutter/material.dart';

abstract final class BehtarColors {
  static const background = Color(0xFFFAFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF2B2B2B);
  static const secondaryText = Color(0xFF6B7280);
  static const primary = Color(0xFF3E8E7E);
  static const primaryDark = Color(0xFF2F7164);
  static const primarySoft = Color(0xFFE6F3F0);
  static const secondary = Color(0xFF8B7BB8);
  static const success = Color(0xFF2F9E72);
  static const warning = Color(0xFFD99A3D);
  static const error = Color(0xFFC95F5F);
  static const border = Color(0xFFE5E3DC);
}

abstract final class BehtarSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

abstract final class BehtarRadii {
  static const card = 20.0;
  static const control = 14.0;
  static const pill = 100.0;
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: BehtarColors.primary,
      onPrimary: BehtarColors.surface,
      secondary: BehtarColors.secondary,
      surface: BehtarColors.surface,
      onSurface: BehtarColors.primaryText,
      error: BehtarColors.error,
      onError: BehtarColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BehtarColors.background,
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: BehtarColors.primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: BehtarColors.primaryText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: BehtarColors.secondaryText,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: BehtarColors.secondaryText,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BehtarColors.background,
        foregroundColor: BehtarColors.primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: BehtarColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BehtarRadii.card),
          side: const BorderSide(color: BehtarColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BehtarColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BehtarSpacing.base,
          vertical: BehtarSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BehtarRadii.control),
          borderSide: const BorderSide(color: BehtarColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BehtarRadii.control),
          borderSide: const BorderSide(color: BehtarColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BehtarRadii.control),
          borderSide: const BorderSide(color: BehtarColors.primary, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BehtarColors.border,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BehtarColors.surface;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BehtarColors.primary;
          }
          return null;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: BehtarColors.primary,
          foregroundColor: BehtarColors.surface,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BehtarRadii.control),
          ),
        ),
      ),
    );
  }
}
