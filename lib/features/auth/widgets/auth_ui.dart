import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// Bold label shown above an auth form field.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {required this.scale, super.key});

  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// The Behtar phone logo with blinking eyes (same design as the splash).
/// [blink] runs from 1 (open) to ~0 (closed).
class BehtarBlinkingLogo extends StatelessWidget {
  const BehtarBlinkingLogo({
    required this.blink,
    required this.scale,
    super.key,
  });

  final Animation<double> blink;
  final double scale;

  static const Color _logoGreen = AppColors.secondary;

  Widget _eye(double left) {
    return Positioned(
      left: left * scale,
      top: 40 * scale,
      child: AnimatedBuilder(
        animation: blink,
        child: Container(
          width: 16 * scale,
          height: 16 * scale,
          decoration: const BoxDecoration(
            color: _logoGreen,
            shape: BoxShape.circle,
          ),
        ),
        builder: (context, child) {
          return Transform.scale(
            alignment: Alignment.center,
            scaleY: blink.value,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92 * scale,
      height: 147 * scale,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: AppColors.sage.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.07),
              blurRadius: 24 * scale,
              offset: Offset(0, 10 * scale),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20 * scale),
                border: Border.all(color: _logoGreen, width: 8 * scale),
              ),
            ),
            _eye(22),
            _eye(52),
          ],
        ),
      ),
    );
  }
}
