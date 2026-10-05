import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // H1 - Screen title (Poppins, 24px, 600)
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF2B2B2B),
  );

  // H2 - Section title (Poppins, 20px, 600)
  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF2B2B2B),
  );

  // H3 - Card title (Poppins, 16px, 500)
  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF2B2B2B),
  );

  // Body - Supporting text (Inter, 14px, 400)
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6B7280),
  );

  // Label - Caption (Inter, 12px, 500)
  static TextStyle label = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF6B7280),
  );
}