import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final VoidCallback? onGoogleSignIn;

  const LoginScreen({
    super.key,
    this.onLogin,
    this.onForgotPassword,
    this.onSignUp,
    this.onGoogleSignIn,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color sageGreen = Color(0xFFA5D6A7);
  static const Color mint = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF5FAF5);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);
  static const Color borderColor = Color(0xFFDDE8DD);
  static const Color logoGreen = Color(0xFF317E3D);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _blinkController;
  late final Animation<double> _blink;

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();

    // Same blinking animation as the splash screen logo.
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
    _blinkController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required double scale,
    Widget? suffixIcon,
  }) {
    final double radius = 14 * scale;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: secondaryText.withValues(alpha: 0.75),
        fontSize: 13 * scale,
      ),
      prefixIcon: Icon(icon, color: secondaryGreen, size: 21 * scale),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 17 * scale,
      ),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(primaryGreen, 1.5),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.5),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.onLogin != null) {
      widget.onLogin!();
    } else {
      _showMessage('Login UI is ready. Connect authentication to continue.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the full screen size (not the keyboard-reduced size) so the
    // layout does not jump when the keyboard opens.
    final Size screen = MediaQuery.sizeOf(context);

    // Scale is derived from both width and height,
    // so the layout fits correctly on every device.
    final double scale =
        (screen.width / 390 < screen.height / 800
                ? screen.width / 390
                : screen.height / 800)
            .clamp(0.8, 1.35)
            .toDouble();

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
                final double horizontalPadding =
                    (constraints.maxWidth * 0.065).clamp(20.0, 32.0).toDouble();

                // Scrolls only when content does not fit (small screens or
                // keyboard open). Otherwise the content stays centered.
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 20 * scale,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Behtar logo (same as splash screen).
                                Center(child: _buildLogo(0.80 * scale)),

                                SizedBox(height: 14 * scale),

                                Center(
                                  child: Text(
                                    'Behtar',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                      letterSpacing: -0.9 * scale,
                                      height: 1.15,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 14 * scale),

                                Text(
                                  'Welcome Back!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 23 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: primaryText,
                                  ),
                                ),

                                SizedBox(height: 6 * scale),

                                Text(
                                  'Continue your journey towards a better you.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5 * scale,
                                    height: 1.6,
                                    color: secondaryText,
                                  ),
                                ),

                                SizedBox(height: 28 * scale),

                                // Email
                                _label('Email Address', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5 * scale,
                                    color: primaryText,
                                  ),
                                  decoration: _inputDecoration(
                                    hint: 'Enter your email address',
                                    icon: Icons.email_outlined,
                                    scale: scale,
                                  ),
                                  validator: (value) {
                                    final email = value?.trim() ?? '';

                                    if (email.isEmpty) {
                                      return 'Please enter your email address';
                                    }

                                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(email)) {
                                      return 'Please enter a valid email address';
                                    }

                                    return null;
                                  },
                                ),

                                SizedBox(height: 18 * scale),

                                // Password
                                _label('Password', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  autofillHints: const [AutofillHints.password],
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5 * scale,
                                    color: primaryText,
                                  ),
                                  decoration: _inputDecoration(
                                    hint: 'Enter your password',
                                    icon: Icons.lock_outline_rounded,
                                    scale: scale,
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: secondaryText,
                                        size: 21 * scale,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }

                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }

                                    return null;
                                  },
                                ),

                                SizedBox(height: 10 * scale),

                                // Remember me and Forgot password
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24 * scale,
                                      height: 24 * scale,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: primaryGreen,
                                        side: const BorderSide(
                                          color: borderColor,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _rememberMe = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8 * scale),
                                    Expanded(
                                      child: Text(
                                        'Remember me',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12 * scale,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: widget.onForgotPassword ??
                                          () => _showMessage(
                                                'Forgot Password screen is not connected yet.',
                                              ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryGreen,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4 * scale,
                                        ),
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12 * scale,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 18 * scale),

                                // Login button
                                SizedBox(
                                  height: 54 * scale,
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
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
                                          'Login',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15.5 * scale,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 10 * scale),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 19 * scale,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 22 * scale),

                                // Divider
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(color: borderColor),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14 * scale,
                                      ),
                                      child: Text(
                                        'OR CONTINUE WITH',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10 * scale,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(color: borderColor),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 18 * scale),

                                // Google button
                                SizedBox(
                                  height: 52 * scale,
                                  child: OutlinedButton(
                                    onPressed: widget.onGoogleSignIn ??
                                        () => _showMessage(
                                              'Google Sign-In is not connected yet.',
                                            ),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: primaryText,
                                      side: const BorderSide(
                                        color: borderColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14 * scale),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
  'assets/icons/google.png',
  width: 24 * scale,
  height: 24 * scale,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    // Fallback if the asset path is wrong.
    return Icon(
      Icons.g_mobiledata_rounded,
      size: 28 * scale,
      color: primaryGreen,
    );
  },
),
                                        SizedBox(width: 11 * scale),
                                        Text(
                                          'Continue with Google',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13 * scale,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 24 * scale),

                                // Sign up
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5 * scale,
                                        color: secondaryText,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: widget.onSignUp ??
                                          () => _showMessage(
                                                'Sign Up screen is not connected yet.',
                                              ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: primaryGreen,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2 * scale,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Sign Up',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5 * scale,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 14 * scale),

                            
                              ],
                            ),
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

  // Field label.
  Widget _label(String text, double scale) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13 * scale,
        fontWeight: FontWeight.w600,
        color: primaryText,
      ),
    );
  }

  // Animated Behtar logo (same design as the splash screen).
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
              color: logoGreen,
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
                border: Border.all(color: logoGreen, width: 8 * scale),
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

// Decorative background shapes 
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
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) => false;
}