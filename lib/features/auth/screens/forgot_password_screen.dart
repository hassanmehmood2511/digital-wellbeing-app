import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/auth_background_painter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  /// Called with the email after validation passes.
  /// Connect your backend here (e.g. Firebase sendPasswordResetEmail).
  /// If it throws, an error message is shown.
  final Future<void> Function(String email)? onSendLink;
  final VoidCallback? onBackToLogin;

  const ForgotPasswordScreen({super.key, this.onSendLink, this.onBackToLogin});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color sageGreen = Color(0xFFA5D6A7);
  static const Color mint = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF5FAF5);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);
  static const Color borderColor = Color(0xFFDDE8DD);

  // Seconds the user must wait before requesting another link.
  static const int _resendSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  Timer? _timer;
  bool _isLoading = false;
  bool _linkSent = false;
  int _cooldown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Logic
  // ---------------------------------------------------------------------------

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim().toLowerCase();

    if (email.isEmpty) return 'Please enter your email address';

    final valid = RegExp(
      r'^[a-z0-9._%+\-]+@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.[a-z]{2,}$',
    ).hasMatch(email);

    if (!valid || email.contains('..')) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _resendSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _sendLink() async {
    FocusScope.of(context).unfocus();

    // When the form is hidden (success screen), the email is already valid.
    if (!_linkSent && !_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();

    setState(() => _isLoading = true);

    try {
      if (widget.onSendLink != null) {
        await widget.onSendLink!(email);
      } else {
        // Demo mode until a backend is connected.
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _linkSent = true;
      });
      _startCooldown();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Something went wrong. Please try again.');
    }
  }

  void _useDifferentEmail() {
    _timer?.cancel();
    setState(() {
      _linkSent = false;
      _cooldown = 0;
    });
  }

  void _backToLogin() {
    if (widget.onBackToLogin != null) {
      widget.onBackToLogin!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required double scale,
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
      filled: true,
      fillColor: Colors.white,
      errorMaxLines: 2,
      errorStyle: GoogleFonts.poppins(fontSize: 11 * scale),
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

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required double scale,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      height: 54 * scale,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryGreen.withValues(alpha: 0.75),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15 * scale),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 22 * scale,
                height: 22 * scale,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 15.5 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Icon(icon, size: 19 * scale),
                ],
              ),
      ),
    );
  }

  Widget _backToLoginLink(double scale) {
    return Center(
      child: TextButton.icon(
        onPressed: _backToLogin,
        style: TextButton.styleFrom(foregroundColor: primaryGreen),
        icon: Icon(Icons.arrow_back_rounded, size: 18 * scale),
        label: Text(
          'Back to Login',
          style: GoogleFonts.poppins(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Step 1: enter email.
  // Removed only the extra lock icon. All other form styling is unchanged.
  Widget _buildForm(double scale) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        key: const ValueKey('form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8 * scale),
          Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 25 * scale,
              fontWeight: FontWeight.w700,
              color: primaryText,
              letterSpacing: -0.5 * scale,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            "No worries! Enter the email linked to your account and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5 * scale,
              height: 1.6,
              color: secondaryText,
            ),
          ),
          SizedBox(height: 28 * scale),
          Text(
            'Email Address',
            style: GoogleFonts.poppins(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: 8 * scale),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onFieldSubmitted: (_) => _sendLink(),
            style: GoogleFonts.poppins(
              fontSize: 13.5 * scale,
              color: primaryText,
            ),
            decoration: _inputDecoration(
              hint: 'Enter your email address',
              icon: Icons.email_outlined,
              scale: scale,
            ),
            validator: _validateEmail,
          ),
          SizedBox(height: 22 * scale),
          _primaryButton(
            label: 'Send Reset Link',
            icon: Icons.send_rounded,
            scale: scale,
            onPressed: _sendLink,
            loading: _isLoading,
          ),
          SizedBox(height: 14 * scale),
          _backToLoginLink(scale),
        ],
      ),
    );
  }

  // Step 2: confirmation.
  Widget _buildSuccess(double scale) {
    final String email = _emailController.text.trim().toLowerCase();
    final bool canResend = _cooldown == 0 && !_isLoading;

    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72 * scale,
            height: 72 * scale,
            decoration: BoxDecoration(
              color: mint,
              shape: BoxShape.circle,
              border: Border.all(color: sageGreen.withValues(alpha: 0.7)),
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              color: primaryGreen,
              size: 34 * scale,
            ),
          ),
        ),
        SizedBox(height: 18 * scale),
        Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 25 * scale,
            fontWeight: FontWeight.w700,
            color: primaryText,
            letterSpacing: -0.5 * scale,
          ),
        ),
        SizedBox(height: 10 * scale),
        Text.rich(
          TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 12.5 * scale,
              height: 1.6,
              color: secondaryText,
            ),
            children: [
              const TextSpan(text: 'If an account exists for '),
              TextSpan(
                text: email,
                style: GoogleFonts.poppins(
                  fontSize: 12.5 * scale,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              const TextSpan(
                text:
                    ', you will receive a password reset link shortly. The link expires soon, so use it right away.',
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16 * scale),
        Container(
          padding: EdgeInsets.all(14 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: secondaryGreen,
                size: 18 * scale,
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  "Can't find it? Check your spam or junk folder.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5 * scale,
                    height: 1.5,
                    color: secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24 * scale),
        _primaryButton(
          label: 'Back to Login',
          icon: Icons.arrow_forward_rounded,
          scale: scale,
          onPressed: _backToLogin,
        ),
        SizedBox(height: 14 * scale),
        Center(
          child: TextButton(
            onPressed: canResend ? _sendLink : null,
            style: TextButton.styleFrom(foregroundColor: primaryGreen),
            child: Text(
              _cooldown > 0
                  ? 'Resend link in ${_cooldown}s'
                  : _isLoading
                  ? 'Sending...'
                  : 'Resend link',
              style: GoogleFonts.poppins(
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _useDifferentEmail,
            style: TextButton.styleFrom(foregroundColor: secondaryText),
            child: Text(
              'Use a different email',
              style: GoogleFonts.poppins(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Full screen size (not keyboard-reduced) so the layout does not jump.
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

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 2 * scale,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Only the requested image is displayed here.
                              // No fallback icon and no Behtar text.
                              Center(
                                child: SizedBox(
                                  width: 550 * 0.6 * scale,
                                  height: 550 * 0.6 * scale,
                                  child: Image.asset(
                                    'assets/icons/forgot.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              SizedBox(height: 5 * scale),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                child: _linkSent
                                    ? _buildSuccess(scale)
                                    : _buildForm(scale),
                              ),

                              SizedBox(height: 22 * scale),
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
}

// Decorative background shapes (same as the other auth screens).
