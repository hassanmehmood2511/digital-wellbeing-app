import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Green
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF4CAF50);

  // Supporting Greens
  // Primary Green Palette
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF2F7164);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color sage = Color(0xFFA5D6A7);
  static const Color mint = Color(0xFFE8F5E9);

  // Background & Surface
  static const Color background = Color(0xFFF5FAF5);
  static const Color white = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1B4332);
  static const Color textSecondary = Color(0xFF5C6B63);

  // Border
  static const Color border = Color(0xFFDDE8DD);
  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF5FAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1B4332);
  static const Color textSecondary = Color(0xFF5C6B63);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);

  // Borders & Dividers
  static const Color border = Color(0xFFDDE8DD);

  // Status & Accents
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color primarySoft = Color(0xFFE8F5E9);
}

abstract class BehtarColors {
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color lightGreen = AppColors.lightGreen;
  static const Color sage = AppColors.sage;
  static const Color mint = AppColors.mint;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color white = AppColors.white;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color primaryText = AppColors.primaryText;
  static const Color secondaryText = AppColors.secondaryText;
  static const Color border = AppColors.border;
  static const Color warning = AppColors.warning;
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
}

abstract class BehtarSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

abstract class BehtarRadii {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double control = 12.0;
  static const double card = 16.0;
  static const double lg = 24.0;
  static const double pill = 999.0;
}
