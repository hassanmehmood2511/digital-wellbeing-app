import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Spacing scale — based on 4px
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Corner radius
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 32.0;

  // Common screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(base);

  // Common card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(base);

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationHigh = 4.0;
}
