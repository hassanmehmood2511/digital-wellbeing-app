import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_layout.dart';
import 'screen_02.dart';

class OnboardingScreenOne extends StatelessWidget {
  /// Called when onboarding ends (Skip or Get Started on the last page).
  final VoidCallback onFinished;

  const OnboardingScreenOne({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      pageIndex: 0,
      pageCount: 3,
      illustration: const _TrackIllustration(),
      title: 'Track Your Digital Habits',
      description:
          'See exactly where your time goes. Behtar shows your daily screen time and app usage in one simple, clear view.',
      buttonLabel: 'Next',
      buttonIcon: Icons.arrow_forward_rounded,
      onSkip: onFinished,
      onNext: () => Navigator.of(context).push(
        onboardingRoute(OnboardingScreenTwo(onFinished: onFinished)),
      ),
    );
  }
}

class _TrackIllustration extends StatelessWidget {
  const _TrackIllustration();

  @override
  Widget build(BuildContext context) {
    return OnboardingIllustrationFrame(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Usage ring.
          Positioned(
            left: 70,
            top: 70,
            width: 160,
            height: 160,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _DonutPainter()),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '3h 20m',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: OnboardingColors.primaryText,
                        ),
                      ),
                      Text(
                        'Today',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: OnboardingColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            top: 34,
            right: 0,
            child: OnboardingChip(
              icon: Icons.groups_rounded,
              title: 'Social',
              value: '1h 05m',
            ),
          ),

          const Positioned(
            bottom: 32,
            left: 0,
            child: OnboardingChip(
              icon: Icons.play_circle_outline_rounded,
              title: 'Video',
              value: '48m',
            ),
          ),

          Positioned(
            right: 34,
            bottom: 50,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: OnboardingColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        OnboardingColors.primaryGreen.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 16;
    final Rect rect = (Offset.zero & size).deflate(stroke / 2);

    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = OnboardingColors.borderColor
      ..isAntiAlias = true;

    canvas.drawArc(rect, 0, 2 * math.pi, false, base);

    final List<double> fractions = [0.42, 0.28, 0.16];
    final List<Color> colors = [
      OnboardingColors.primaryGreen,
      OnboardingColors.secondaryGreen,
      OnboardingColors.lightGreen,
    ];

    double start = -math.pi / 2;

    for (int i = 0; i < fractions.length; i++) {
      final double sweep = fractions[i] * 2 * math.pi;

      final Paint segment = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = colors[i]
        ..isAntiAlias = true;

      canvas.drawArc(rect, start + 0.16, sweep - 0.32, false, segment);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}