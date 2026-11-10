import 'package:flutter/material.dart';

/// Behtar's colour palette — the single source of truth for every colour.
/// `BehtarColors` (in app_theme.dart) exposes the same values for widgets
/// that use the theme's naming.
class AppColors {
  AppColors._();

  // Primary Green Palette
  static const Color primary = Color(0xFF10B982);
  static const Color secondary = Color(0xFF075B49);

  // Supporting Greens
  static const Color primaryDark = Color(0xFF075B49);
  static const Color lightGreen = Color(0xFF10B982);
  static const Color sage = Color(0xFF667873);
  static const Color mint = Color(0xFFD0FAE4);

  // Background & Surface
  static const Color background = Color(0xFFF4F8F7);
  static const Color white = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF172B27);
  static const Color textSecondary = Color(0xFF667873);

  // Border
  static const Color border = Color(0xFFDCE8E3);
  // Backgrounds & Surfaces
  static const Color surface = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF172B27);
  static const Color secondaryText = Color(0xFF667873);

  // Status & Accents
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B982);
  static const Color error = Color(0xFFEF4444);
  static const Color primarySoft = Color(0xFFD0FAE4);
}
