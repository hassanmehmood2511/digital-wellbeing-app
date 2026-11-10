import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles (Poppins via google_fonts) used across the app.
abstract final class AppTypography {
  // H1 - Primary page/hero headings (Poppins, 32px, Bold)
  static final TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // H2 - Section headings (Poppins, 24px, SemiBold)
  static final TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // H3 - Card and component headings (Poppins, 20px, SemiBold)
  static final TextStyle h3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body - Main supporting content (Poppins, 16px, Regular)
  static final TextStyle body = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Small - Labels, metadata and secondary content (Poppins, 14px, Regular)
  static final TextStyle small = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Button Text (Poppins, 16px, Medium)
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Semi-bold button text (used on primary actions in Habits)
  static final TextStyle buttonBold = button.copyWith(
    fontWeight: FontWeight.w600,
  );
}
