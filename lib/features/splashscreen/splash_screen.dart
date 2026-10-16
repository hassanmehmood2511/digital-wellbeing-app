import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Behtar app splash screen.
///
/// Displays the animated logo, app tagline, splash illustration, feature

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Behtar brand colors.
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color sageGreen = Color(0xFFA5D6A7);
  static const Color mint = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF5FAF5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);
  static const Color borderColor = Color(0xFFDDE8DD);

  late final AnimationController _progressController;
  late final AnimationController _blinkController;
  late final Animation<double> _blink;

  @override
  void initState() {
    super.initState();
    _initializeProgressAnimation();
    _initializeBlinkAnimation();
  }

  /// Starts the five-second loading progress and notifies the parent on finish.
  void _initializeProgressAnimation() {
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          widget.onFinished();
        }
      });

    _progressController.forward();
  }

  /// Creates a quick blink followed by a longer pause between blinks.
  void _initializeBlinkAnimation() {
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _blink = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.08).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 5,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.08, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 5,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(1.0),
        weight: 90,
      ),
    ]).animate(_blinkController);

    _blinkController.repeat();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Paint the decorative background separately from animated content.
          const RepaintBoundary(
            child: CustomPaint(
              painter: _BackgroundPainter(
                lightGreen: lightGreen,
                sageGreen: sageGreen,
                mint: mint,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isSmallScreen = constraints.maxHeight < 680;

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: isSmallScreen ? 8 : 12,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // Animated Behtar logo.
                      RepaintBoundary(child: _buildLogo()),
                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // App name.
                      Text(
                        'Behtar',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 42 : 48,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          letterSpacing: -1.5,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Short app tagline.
                      Text(
                        'Turn Small Steps Into Big Results',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w400,
                          color: secondaryText,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 1),

                      // Splash illustration.
                      Center(
                        child: Image.asset(
                          'assets/images/Splash-icon.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 1),

                      // Three core app benefits: Track, Improve, and Build.
                      Transform.translate(
                        offset: const Offset(0, 25),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FeatureItem(
                              icon: Icons.search_rounded,
                              title: 'Track',
                            ),
                            FeatureItem(
                              icon: Icons.memory_rounded,
                              title: 'Improve',
                            ),
                            FeatureItem(
                              icon: Icons.verified_user_rounded,
                              title: 'Build',
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 22 : 32),

                      // Animated loading progress bar.
                      Transform.translate(
                        offset: const Offset(0, 20),
                        child: SizedBox(
                          width: 250,
                          height: 6,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: _progressController.value,
                                  minHeight: 5,
                                  backgroundColor: borderColor,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    primaryGreen,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 20),

                      // Loading status text.
                      Transform.translate(
                        offset: const Offset(0, 20),
                        child: Text(
                          'Loading...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                            color: primaryGreen,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Footer branding and app version.
                      Transform.translate(
                        offset: const Offset(0, -7),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Powered by AI',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Transform.translate(
                              offset: const Offset(0, 5),
                              child: Text(
                                'Version 1.0',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the logo frame and its two animated circular eyes.
  Widget _buildLogo() {
    Widget buildBlinkingEye(double left) {
      return Positioned(
        left: left,
        top: 40,
        child: AnimatedBuilder(
          animation: _blink,
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFF317E3D),
              shape: BoxShape.circle,
            ),
          ),
          builder: (context, child) {
            return Transform.scale(
              alignment: Alignment.center,
              scaleY: _blink.value,
              child: child,
            );
          },
        ),
      );
    }

    return Container(
      width: 92,
      height: 147,
      decoration: BoxDecoration(
        color: white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sageGreen.withValues(alpha: 0.55),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Logo outline.
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF317E3D),
                width: 8,
              ),
            ),
          ),
          // Eye positions match the original logo proportions.
          buildBlinkingEye(22),
          buildBlinkingEye(52),
        ],
      ),
    );
  }
}

/// A circular icon and label for one of the splash screen features.
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color mint = Color(0xFFE8F5E9);
  static const Color borderColor = Color(0xFFDDE8DD);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: mint,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
      ],
    );
  }
}

/// Draws the static decorative shapes behind the splash screen content.
class _BackgroundPainter extends CustomPainter {
  final Color lightGreen;
  final Color sageGreen;
  final Color mint;

  const _BackgroundPainter({
    required this.lightGreen,
    required this.sageGreen,
    required this.mint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Soft organic shape in the top-left corner.
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

    paint.color = mint.withValues(alpha: 0.95);
    canvas.drawPath(topPath, paint);

    // Soft wave along the bottom edge.
    final Path bottomWave = Path()
      ..moveTo(0, size.height * 0.999)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.88,
        size.width * 0.30,
        size.height * 0.98,
        size.width * 0.50,
        size.height * 0.98,
      )
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.98,
        size.width * 0.80,
        size.height * 0.88,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    paint.color = lightGreen.withValues(alpha: 0.20);
    canvas.drawPath(bottomWave, paint);

    // Decorative leaf near the bottom-right corner.
    _drawLeaf(
      canvas,
      Offset(size.width * 0.92, size.height * 0.945),
      0.85,
      2.45,
    );
  }

  /// Draws one decorative leaf and its central vein.
  void _drawLeaf(
    Canvas canvas,
    Offset origin,
    double scale,
    double angle,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    canvas.scale(scale);

    final Path leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-25, -34, 0, -70)
      ..quadraticBezierTo(25, -35, 0, 0)
      ..close();

    final Paint leafPaint = Paint()
      ..color = lightGreen.withValues(alpha: 0.48)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(leafPath, leafPaint);

    final Paint veinPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawLine(
      const Offset(0, 0),
      const Offset(0, -61),
      veinPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return lightGreen != oldDelegate.lightGreen ||
        sageGreen != oldDelegate.sageGreen ||
        mint != oldDelegate.mint;
  }
}
