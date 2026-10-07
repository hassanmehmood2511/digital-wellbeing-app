import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BehtarColors {
  static const primary = Color(0xFF2E7D32);
  static const secondary = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFF81C784);
  static const sage = Color(0xFFA5D6A7);
  static const mint = Color(0xFFE8F5E9);
  static const background = Color(0xFFF5FAF5);
  static const surface = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1B4332);
  static const secondaryText = Color(0xFF5C6B63);
  static const border = Color(0xFFDDE8DD);
}

abstract final class BehtarSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class BehtarRadii {
  static const card = 24.0;
  static const control = 16.0;
  static const hero = 32.0;
  static const pill = 100.0;
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: BehtarColors.primary,
      onPrimary: BehtarColors.surface,
      primaryContainer: BehtarColors.mint,
      onPrimaryContainer: BehtarColors.primary,
      secondary: BehtarColors.secondary,
      onSecondary: BehtarColors.surface,
      secondaryContainer: BehtarColors.mint,
      onSecondaryContainer: BehtarColors.primary,
      tertiary: BehtarColors.lightGreen,
      onTertiary: BehtarColors.primaryText,
      tertiaryContainer: BehtarColors.sage,
      onTertiaryContainer: BehtarColors.primaryText,
      errorContainer: BehtarColors.mint,
      onErrorContainer: BehtarColors.primaryText,
      error: BehtarColors.primaryText,
      onError: BehtarColors.surface,
      surface: BehtarColors.surface,
      onSurface: BehtarColors.primaryText,
      onSurfaceVariant: BehtarColors.secondaryText,
      surfaceContainerLowest: BehtarColors.surface,
      surfaceContainerLow: BehtarColors.background,
      surfaceContainer: BehtarColors.mint,
      surfaceContainerHigh: BehtarColors.sage,
      surfaceContainerHighest: BehtarColors.sage,
      surfaceDim: BehtarColors.background,
      surfaceBright: BehtarColors.surface,
      outline: BehtarColors.border,
      outlineVariant: BehtarColors.border,
      shadow: BehtarColors.primaryText,
      scrim: BehtarColors.primaryText,
      inverseSurface: BehtarColors.primaryText,
      onInverseSurface: BehtarColors.surface,
      inversePrimary: BehtarColors.lightGreen,
      surfaceTint: BehtarColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: BehtarColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      fontFamilyFallback: const ['sans-serif'],
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: BehtarColors.secondaryText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: BehtarColors.secondaryText,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 14,
          color: BehtarColors.secondaryText,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: BehtarColors.background,
        foregroundColor: BehtarColors.primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BehtarColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: BehtarColors.mint,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? BehtarColors.primary : BehtarColors.sage,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? BehtarColors.primary : BehtarColors.sage,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: BehtarColors.surface,
        elevation: 1,
        shadowColor: BehtarColors.primaryText.withValues(alpha: 0.04),
        surfaceTintColor: Colors.transparent,
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
        thumbColor: WidgetStateProperty.all(BehtarColors.surface),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? BehtarColors.secondary
              : BehtarColors.sage;
        }),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: BehtarColors.mint,
          foregroundColor: BehtarColors.primary,
          side: const BorderSide(color: BehtarColors.mint),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BehtarRadii.control),
          ),
        ),
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
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: BehtarColors.mint,
        contentTextStyle: TextStyle(color: BehtarColors.primaryText),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BehtarColors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: BehtarColors.primaryText,
        ).copyWith(fontFamilyFallback: const ['Inter']),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 16,
          color: BehtarColors.secondaryText,
        ),
      ),
    );
  }
}
