import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color sageGreen = Color(0xFFA5D6A7);
  static const Color background = Color(0xFFF5FAF5);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);
  static const Color borderColor = Color(0xFFDDE8DD);

  late final AnimationController _progressController;
  late final AnimationController _blinkController;
  late final Animation<double> _blink;

  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_finished && mounted) {
        _finished = true;
        widget.onFinished();
      }
    });

    _progressController.forward();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _blink = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.08)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.08, end: 1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
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
          const RepaintBoundary(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final double height = constraints.maxHeight;

                // Scale is derived from both width and height,
                // so the layout fits correctly on every device.
                final double scale =
                    (width / 390 < height / 800 ? width / 390 : height / 800)
                        .clamp(0.7, 1.4)
                        .toDouble();

                final double contentWidth = (width < 520 ? width : 520) - 32;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    // FittedBox: if the content is too large for any screen,
                    // it shrinks automatically, so there is no overflow.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: contentWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo with blinking eyes
                            _buildLogo(scale),
                            SizedBox(height: 18 * scale),

                            // App name
                            Text(
                              'Behtar',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 44 * scale,
                                fontWeight: FontWeight.w700,
                                height: 1.12,
                                letterSpacing: -1.2 * scale,
                                color: primaryText,
                              ),
                            ),
                            SizedBox(height: 8 * scale),

                            // Tagline
                            Text(
                              'Turn Small Steps Into Big Results',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14 * scale,
                                height: 1.45,
                                color: secondaryText,
                              ),
                            ),
                            SizedBox(height: 22 * scale),

                            // Illustration
                            SizedBox(
                              width: 270 * scale,
                              height: 200 * scale,
                              child: Image.asset(
                                'assets/images/Splash-icon.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 32,
                                      color: secondaryText,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 22 * scale),

                            // Track, Improve, Build
                            SizedBox(
                              width: 300 * scale,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FeatureItem(
                                      icon: Icons.track_changes_rounded,
                                      title: 'Track',
                                      scale: scale,
                                    ),
                                  ),
                                  Expanded(
                                    child: FeatureItem(
                                      icon: Icons.trending_up_rounded,
                                      title: 'Improve',
                                      scale: scale,
                                    ),
                                  ),
                                  Expanded(
                                    child: FeatureItem(
                                      icon: Icons.flag_rounded,
                                      title: 'Build',
                                      scale: scale,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 28 * scale),

                            // Loading bar
                            SizedBox(
                              width: 280 * scale,
                              height: 6 * scale,
                              child: AnimatedBuilder(
                                animation: _progressController,
                                builder: (context, child) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: _progressController.value,
                                      minHeight: 6 * scale,
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
                            SizedBox(height: 12 * scale),

                            // Loading text
                            Text(
                              'Loading...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                                color: primaryGreen,
                              ),
                            ),
                            SizedBox(height: 28 * scale),

                            // Footer
                            Text(
                              'Powered by AI',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w600,
                                color: primaryText,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              'Version 1.0',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12 * scale,
                                color: secondaryText,
                              ),
                            ),
                          ],
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

  // Animated Behtar logo.
  Widget _buildLogo(double scale) {
    Widget buildEye(double left) {
      return Positioned(
        left: left * scale,
        top: 40 * scale,
        child: AnimatedBuilder(
          animation: _blink,
          child: Container(
            width: 16 * scale,
            height: 16 * scale,
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

    return SizedBox(
      width: 92 * scale,
      height: 147 * scale,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(color: sageGreen.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withValues(alpha: 0.07),
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
                border: Border.all(
                  color: const Color(0xFF317E3D),
                  width: 8 * scale,
                ),
              ),
            ),
            buildEye(22),
            buildEye(52),
          ],
        ),
      ),
    );
  }
}

// Responsive feature icon and label.
class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final double scale;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    this.scale = 1,
  });

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color mint = Color(0xFFE8F5E9);
  static const Color borderColor = Color(0xFFDDE8DD);

  @override
  Widget build(BuildContext context) {
    final double iconSize = 48 * scale;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: mint,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, size: iconSize * 0.50, color: primaryGreen),
          ),
          SizedBox(height: 7 * scale),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Decorative background shapes.
class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter();

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

    // Bottom wave.
    final Path bottomWave = Path()
      ..moveTo(0, size.height)
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
      ..close();

    paint.color = const Color(0x3381C784);
    canvas.drawPath(bottomWave, paint);

    // Bottom-right decorative leaf.
    canvas.save();
    canvas.translate(size.width * 0.92, size.height * 0.945);
    canvas.rotate(2.45);
    canvas.scale(0.85);

    final Path leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-25, -34, 0, -70)
      ..quadraticBezierTo(25, -35, 0, 0)
      ..close();

    paint.color = const Color(0x7B81C784);
    canvas.drawPath(leafPath, paint);

    final Paint veinPaint = Paint()
      ..color = const Color(0x734CAF50)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawLine(const Offset(0, 0), const Offset(0, -61), veinPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => false;
}