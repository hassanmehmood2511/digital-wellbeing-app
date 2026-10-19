import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors shared by all onboarding screens.
class OnboardingColors {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color sageGreen = Color(0xFFA5D6A7);
  static const Color mint = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF5FAF5);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);
  static const Color borderColor = Color(0xFFDDE8DD);
}

/// Smooth fade + slide transition between onboarding pages.
Route<void> onboardingRoute(Widget page) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Common page structure used by every onboarding screen.
class OnboardingLayout extends StatelessWidget {
  final int pageIndex;
  final int pageCount;
  final Widget illustration;
  final String title;
  final String description;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onNext;

  /// Skip button is hidden when this is null.
  final VoidCallback? onSkip;

  /// Back button is hidden when this is null.
  final VoidCallback? onBack;

  const OnboardingLayout({
    super.key,
    required this.pageIndex,
    required this.pageCount,
    required this.illustration,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onNext,
    this.onSkip,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // Scale is derived from both width and height,
    // so the layout fits correctly on every device.
    final Size screen = MediaQuery.sizeOf(context);
    final double scale = (screen.width / 390 < screen.height / 800
            ? screen.width / 390
            : screen.height / 800)
        .clamp(0.8, 1.35)
        .toDouble();

    return Scaffold(
      backgroundColor: OnboardingColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(
            child: CustomPaint(painter: _OnboardingBackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Very short screens (e.g. landscape) scroll instead of overflow.
                final double contentHeight =
                    math.max(constraints.maxHeight, 560.0);
                final double horizontalPadding =
                    (constraints.maxWidth * 0.07).clamp(20.0, 32.0).toDouble();

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: SizedBox(
                        height: contentHeight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 12 * scale,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTopBar(scale),

                              // Illustration takes all the free space.
                              Expanded(
                                child: _FadeSlide(
                                  duration: const Duration(milliseconds: 700),
                                  offset: 24,
                                  child: LayoutBuilder(
                                    builder: (context, box) {
                                      final double side = math.min(
                                        math.min(box.maxWidth, box.maxHeight),
                                        330 * scale,
                                      );

                                      return Center(
                                        child: SizedBox(
                                          width: side,
                                          height: side,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: SizedBox(
                                              width: 300,
                                              height: 300,
                                              child: illustration,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(height: 8 * scale),

                              _FadeSlide(
                                duration: const Duration(milliseconds: 800),
                                offset: 18,
                                child: Column(
                                  children: [
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 27 * scale,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        letterSpacing: -0.6 * scale,
                                        color: OnboardingColors.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: 12 * scale),
                                    Text(
                                      description,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13.5 * scale,
                                        height: 1.65,
                                        color: OnboardingColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 22 * scale),

                              _buildIndicators(scale),

                              SizedBox(height: 22 * scale),

                              _FadeSlide(
                                duration: const Duration(milliseconds: 900),
                                offset: 14,
                                child: SizedBox(
                                  height: 54 * scale,
                                  child: ElevatedButton(
                                    onPressed: onNext,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          OnboardingColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15 * scale),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          buttonLabel,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15.5 * scale,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 10 * scale),
                                        Icon(buttonIcon, size: 19 * scale),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 8 * scale),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(double scale) {
    return SizedBox(
      height: 44 * scale,
      child: Row(
        children: [
          if (onBack != null)
            Material(
              color: Colors.white,
              shape: const CircleBorder(
                side: BorderSide(color: OnboardingColors.borderColor),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onBack,
                child: SizedBox(
                  width: 40 * scale,
                  height: 40 * scale,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16 * scale,
                    color: OnboardingColors.primaryText,
                  ),
                ),
              ),
            )
          else
            SizedBox(width: 40 * scale),
          const Spacer(),
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: OnboardingColors.secondaryText,
              ),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 13.5 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicators(double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool active = index == pageIndex;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 8, end: active ? 28 : 8),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            builder: (context, width, _) {
              return Container(
                width: width * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                  color: active
                      ? OnboardingColors.primaryGreen
                      : OnboardingColors.sageGreen.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

/// Fades a widget in while sliding it up slightly.
class _FadeSlide extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const _FadeSlide({
    required this.child,
    required this.duration,
    this.offset = 20,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Soft circular backdrop for illustrations (design size 300 x 300).
class OnboardingIllustrationFrame extends StatelessWidget {
  final Widget child;

  const OnboardingIllustrationFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: _FramePainter()),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _FramePainter extends CustomPainter {
  const _FramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double r = size.width / 2;

    final Paint paint = Paint()..isAntiAlias = true;

    paint
      ..style = PaintingStyle.fill
      ..color = OnboardingColors.mint;
    canvas.drawCircle(center, r * 0.92, paint);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = OnboardingColors.sageGreen.withValues(alpha: 0.55);
    canvas.drawCircle(center, r * 0.99, paint);

    paint
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawCircle(center, r * 0.66, paint);

    paint.color = OnboardingColors.lightGreen.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.30), 6, paint);
    canvas.drawCircle(Offset(size.width * 0.90, size.height * 0.72), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.88), 5, paint);
    canvas.drawCircle(Offset(size.width * 0.84, size.height * 0.16), 4, paint);
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) => false;
}

/// Small floating info card used inside illustrations.
class OnboardingChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const OnboardingChip({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor = OnboardingColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OnboardingColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: OnboardingColors.primaryGreen.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: OnboardingColors.mint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  height: 1.2,
                  color: OnboardingColors.secondaryText,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: OnboardingColors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Decorative background shapes (same as the other auth screens).
class _OnboardingBackgroundPainter extends CustomPainter {
  const _OnboardingBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Top-left organic shape.
    final Path topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.30, 0)
      ..cubicTo(
        size.width * 0.23,
        size.height * 0.09,
        size.width * 0.12,
        size.height * 0.09,
        0,
        size.height * 0.14,
      )
      ..close();

    paint.color = const Color(0xFFE8F5E9);
    canvas.drawPath(topPath, paint);

    // // Bottom wave.
    // final Path bottomWave = Path()
    //   ..moveTo(0, size.height)
    //   ..cubicTo(
    //     size.width * 0.25,
    //     size.height * 0.88,
    //     size.width * 0.30,
    //     size.height * 0.98,
    //     size.width * 0.50,
    //     size.height * 0.98,
    //   )
    //   ..cubicTo(
    //     size.width * 0.70,
    //     size.height * 0.98,
    //     size.width * 0.80,
    //     size.height * 0.88,
    //     size.width,
    //     size.height * 0.88,
    //   )
    //   ..lineTo(size.width, size.height)
    //   ..close();

    // paint.color = const Color(0x3381C784);
    // canvas.drawPath(bottomWave, paint);

    // // Bottom-right decorative leaf.
    // canvas.save();
    // canvas.translate(size.width * 0.92, size.height * 0.945);
    // canvas.rotate(2.45);
    // canvas.scale(0.85);

    // final Path leafPath = Path()
    //   ..moveTo(0, 0)
    //   ..quadraticBezierTo(-25, -34, 0, -70)
    //   ..quadraticBezierTo(25, -35, 0, 0)
    //   ..close();

    // paint.color = const Color(0x7B81C784);
    // canvas.drawPath(leafPath, paint);

    // final Paint veinPaint = Paint()
    //   ..color = const Color(0x734CAF50)
    //   ..strokeWidth = 1.2
    //   ..style = PaintingStyle.stroke
    //   ..isAntiAlias = true;

    // canvas.drawLine(const Offset(0, 0), const Offset(0, -61), veinPaint);
    // canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OnboardingBackgroundPainter oldDelegate) =>
      false;
}