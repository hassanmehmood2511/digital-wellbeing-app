import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_background_painter.dart';
import '../../../core/backend/backend.dart';
import '../widgets/auth_ui.dart';

class LoginScreen extends StatefulWidget {
  /// Signs the user in. Throw to show an error message on this screen.
  final Future<void> Function(String email, String password, bool rememberMe)?
  onLogin;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final Future<void> Function()? onGoogleSignIn;

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
  static const Color primaryGreen = Color(0xFF10B982);
  static const Color secondaryGreen = Color(0xFF075B49);
  static const Color background = Color(0xFFF4F8F7);
  static const Color primaryText = Color(0xFF172B27);
  static const Color secondaryText = Color(0xFF667873);
  static const Color borderColor = Color(0xFFDCE8E3);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _blinkController;
  late final Animation<double> _blink;

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSubmitting = false;

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
        tween: Tween<double>(
          begin: 1,
          end: 0.08,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 5,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 90),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final onLogin = widget.onLogin;
    if (onLogin == null) {
      _showMessage('Login is not available right now.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await onLogin(
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
        _rememberMe,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showMessage(friendlyErrorMessage(error));
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final onGoogleSignIn = widget.onGoogleSignIn;
    if (onGoogleSignIn == null) {
      _showMessage('Google Sign-In is not available right now.');
      return;
    }
    try {
      await onGoogleSignIn();
    } catch (error) {
      if (mounted) _showMessage(friendlyErrorMessage(error));
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
            child: CustomPaint(painter: AuthBackgroundPainter()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double horizontalPadding = (constraints.maxWidth * 0.065)
                    .clamp(20.0, 32.0)
                    .toDouble();

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
                                Center(child: BehtarBlinkingLogo(blink: _blink, scale: 0.80 * scale)),

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
                                AuthFieldLabel('Email Address', scale: scale),
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

                                    if (!RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(email)) {
                                      return 'Please enter a valid email address';
                                    }

                                    return null;
                                  },
                                ),

                                SizedBox(height: 18 * scale),

                                // Password
                                AuthFieldLabel('Password', scale: scale),
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
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
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
                                      onPressed:
                                          widget.onForgotPassword ??
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
                                    onPressed: _isSubmitting
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15 * scale,
                                        ),
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
                                    onPressed: _isSubmitting
                                        ? null
                                        : _handleGoogleSignIn,
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: primaryText,
                                      side: const BorderSide(
                                        color: borderColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          14 * scale,
                                        ),
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
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                // Fallback if the asset path is wrong.
                                                return Icon(
                                                  Icons.g_mobiledata_rounded,
                                                  size: 28 * scale,
                                                  color: primaryGreen,
                                                );
                                              },
                                        ),
                                        SizedBox(width: 11 * scale),
                                        Flexible(
                                          child: Text(
                                            'Continue with Google',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13 * scale,
                                              fontWeight: FontWeight.w500,
                                            ),
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
                                      onPressed:
                                          widget.onSignUp ??
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
}
