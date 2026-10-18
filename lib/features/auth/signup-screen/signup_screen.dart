import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  /// Called after all validation passes. Connect your backend here.
  /// The phone number is in full international format, e.g. +923001234567.
  final void Function(
    String name,
    String email,
    String phone,
    String password,
  )? onSignUp;
  final VoidCallback? onLogin;

  const SignUpScreen({
    super.key,
    this.onSignUp,
    this.onLogin,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF4CAF50);
  static const Color sageGreen = Color(0xFFA5D6A7);
  static const Color background = Color(0xFFF5FAF5);
  static const Color primaryText = Color(0xFF1B4332);
  static const Color secondaryText = Color(0xFF5C6B63);
  static const Color borderColor = Color(0xFFDDE8DD);
  static const Color logoGreen = Color(0xFF317E3D);

  // Known disposable / temporary email providers.
  // Extend this list over time. A server-side check is still recommended.
  static const Set<String> _blockedDomains = {
    'mailinator.com',
    'tempmail.com',
    'temp-mail.org',
    'temp-mail.io',
    'tempmailo.com',
    'tempr.email',
    '10minutemail.com',
    '10minutemail.net',
    'guerrillamail.com',
    'guerrillamail.net',
    'sharklasers.com',
    'yopmail.com',
    'yopmail.net',
    'trashmail.com',
    'throwawaymail.com',
    'getnada.com',
    'maildrop.cc',
    'dispostable.com',
    'fakeinbox.com',
    'mohmal.com',
    'emailondeck.com',
    'mintemail.com',
    'mailnesia.com',
    'discard.email',
    'burnermail.io',
    'moakt.com',
    'spamgourmet.com',
    'mytemp.email',
    'tmail.ws',
    'fakemail.net',
    'example.com',
    'test.com',
  };

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late final AnimationController _blinkController;
  late final Animation<double> _blink;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  bool _termsError = false;

  // Selected country for the phone number (default: Pakistan).
  String _dialCode = '92';
  String _flag = '🇵🇰';
  String _isoCode = 'PK';

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validateName(String? value) {
    final name = (value ?? '').trim();

    if (name.isEmpty) return 'Please enter your name';

    // Letters (any language), spaces, dots, apostrophes and hyphens only.
    final valid = RegExp(
      r"^[\p{L}][\p{L}\s.'\-]{1,49}$",
      unicode: true,
    ).hasMatch(name);
    if (!valid) return 'Please enter a valid name';

    return null;
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim().toLowerCase();

    if (email.isEmpty) return 'Please enter your email address';

    final valid = RegExp(
      r'^[a-z0-9._%+\-]+@[a-z0-9\-]+(\.[a-z0-9\-]+)*\.[a-z]{2,}$',
    ).hasMatch(email);
    if (!valid) return 'Please enter a valid email address';

    if (email.contains('..')) return 'Please enter a valid email address';

    final domain = email.split('@').last;
    final isBlocked = _blockedDomains.any(
      (blocked) => domain == blocked || domain.endsWith('.$blocked'),
    );
    if (isBlocked) {
      return 'Temporary or fake email addresses are not allowed';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Please enter your phone number';

    // Remove non-digits and any leading zeros (local trunk prefix).
    final digits = (value ?? '')
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^0+'), '');

    if (_isoCode == 'PK') {
      if (digits.length != 10 || !digits.startsWith('3')) {
        return 'Enter a valid mobile number, e.g. 3001234567';
      }
    } else if (digits.length < 6 || digits.length > 14) {
      return 'Enter a valid phone number';
    }

    // Reject obviously fake numbers like 3333333333.
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) {
      return 'Please enter a real phone number';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Please enter a password';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Add at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Add at least one lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) return 'Add at least one number';
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 'Add at least one special character';
    }

    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  // Password strength: 0 (empty) to 4 (strong).
  int _strength(String password) {
    if (password.isEmpty) return 0;

    var score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score.clamp(1, 4);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['PK', 'IN', 'US', 'GB', 'AE', 'SA'],
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(20),
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.7,
        inputDecoration: InputDecoration(
          hintText: 'Search country or code',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
        ),
      ),
      onSelect: (country) {
        setState(() {
          _dialCode = country.phoneCode;
          _flag = country.flagEmoji;
          _isoCode = country.countryCode;
        });
      },
    );
  }

  void _handleSignUp() {
    FocusScope.of(context).unfocus();

    final formValid = _formKey.currentState!.validate();

    setState(() => _termsError = !_acceptedTerms);

    if (!formValid || !_acceptedTerms) return;

    final phone = _phoneController.text
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^0+'), '');

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final fullPhone = '+$_dialCode$phone';

    if (widget.onSignUp != null) {
      widget.onSignUp!(name, email, fullPhone, _passwordController.text);
    } else {
      _showMessage('Sign Up UI is ready. Connect your backend to continue.');
    }
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required double scale,
    Widget? suffixIcon,
    Widget? prefix,
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
      prefixIcon:
          prefix ?? Icon(icon, color: secondaryGreen, size: 21 * scale),
      prefixIconConstraints: prefix != null
          ? const BoxConstraints(minWidth: 0, minHeight: 0)
          : null,
      suffixIcon: suffixIcon,
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

  TextStyle _fieldStyle(double scale) {
    return GoogleFonts.poppins(
      fontSize: 13.5 * scale,
      color: primaryText,
    );
  }

  // Flag + dial code button shown inside the phone field.
  Widget _countryButton(double scale) {
    return InkWell(
      borderRadius: BorderRadius.circular(14 * scale),
      onTap: _pickCountry,
      child: Padding(
        padding: EdgeInsets.only(left: 12 * scale, right: 6 * scale),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_flag, style: TextStyle(fontSize: 18 * scale)),
            SizedBox(width: 6 * scale),
            Text(
              '+$_dialCode',
              style: GoogleFonts.poppins(
                fontSize: 13.5 * scale,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20 * scale,
              color: secondaryText,
            ),
            Container(
              width: 1,
              height: 22 * scale,
              margin: EdgeInsets.only(left: 6 * scale),
              color: borderColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _strengthMeter(double scale) {
    final int strength = _strength(_passwordController.text);

    const labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      borderColor,
      Colors.redAccent,
      Colors.orange,
      Colors.lightGreen,
      primaryGreen,
    ];

    return Padding(
      padding: EdgeInsets.only(top: 10 * scale),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(4, (index) {
                final bool active = index < strength;
                return Expanded(
                  child: Container(
                    height: 4 * scale,
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 5 * scale),
                    decoration: BoxDecoration(
                      color: active ? colors[strength] : borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: 10 * scale),
          SizedBox(
            width: 44 * scale,
            child: Text(
              labels[strength],
              style: GoogleFonts.poppins(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w600,
                color: colors[strength],
              ),
            ),
          ),
        ],
      ),
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
    final double scale = (screen.width / 390 < screen.height / 800
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

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Behtar logo (same as splash screen).
                                Center(child: _buildLogo(0.6 * scale)),

                                SizedBox(height: 12 * scale),

                                Text(
                                  'Create Account',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 25 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                    letterSpacing: -0.5 * scale,
                                  ),
                                ),

                                SizedBox(height: 6 * scale),

                                Text(
                                  'Join Behtar and start building better habits.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5 * scale,
                                    height: 1.6,
                                    color: secondaryText,
                                  ),
                                ),

                                SizedBox(height: 24 * scale),

                                // Full name
                                _label('Full Name', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.name],
                                  style: _fieldStyle(scale),
                                  decoration: _inputDecoration(
                                    hint: 'Enter your full name',
                                    icon: Icons.person_outline_rounded,
                                    scale: scale,
                                  ),
                                  validator: _validateName,
                                ),

                                SizedBox(height: 16 * scale),

                                // Email
                                _label('Email Address', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(
                                      RegExp(r'\s'),
                                    ),
                                  ],
                                  style: _fieldStyle(scale),
                                  decoration: _inputDecoration(
                                    hint: 'Enter your email address',
                                    icon: Icons.email_outlined,
                                    scale: scale,
                                  ),
                                  validator: _validateEmail,
                                ),

                                SizedBox(height: 16 * scale),

                                // Phone (worldwide country picker)
                                _label('Phone Number', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumberNational,
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(15),
                                  ],
                                  style: _fieldStyle(scale),
                                  decoration: _inputDecoration(
                                    hint: 'Phone number',
                                    icon: Icons.phone_outlined,
                                    scale: scale,
                                    prefix: _countryButton(scale),
                                  ),
                                  validator: _validatePhone,
                                ),

                                SizedBox(height: 16 * scale),

                                // Password
                                _label('Password', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  style: _fieldStyle(scale),
                                  decoration: _inputDecoration(
                                    hint: 'Create a strong password',
                                    icon: Icons.lock_outline_rounded,
                                    scale: scale,
                                    suffixIcon: IconButton(
                                      tooltip: _obscurePassword
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed: () => setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      }),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: secondaryText,
                                        size: 21 * scale,
                                      ),
                                    ),
                                  ),
                                  validator: _validatePassword,
                                ),

                                _strengthMeter(scale),

                                SizedBox(height: 6 * scale),

                                Text(
                                  'Use 8+ characters with uppercase, lowercase, a number and a symbol.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5 * scale,
                                    height: 1.5,
                                    color: secondaryText,
                                  ),
                                ),

                                SizedBox(height: 16 * scale),

                                // Confirm password
                                _label('Confirm Password', scale),
                                SizedBox(height: 8 * scale),
                                TextFormField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleSignUp(),
                                  style: _fieldStyle(scale),
                                  decoration: _inputDecoration(
                                    hint: 'Re-enter your password',
                                    icon: Icons.lock_reset_rounded,
                                    scale: scale,
                                    suffixIcon: IconButton(
                                      tooltip: _obscureConfirm
                                          ? 'Show password'
                                          : 'Hide password',
                                      onPressed: () => setState(() {
                                        _obscureConfirm = !_obscureConfirm;
                                      }),
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: secondaryText,
                                        size: 21 * scale,
                                      ),
                                    ),
                                  ),
                                  validator: _validateConfirm,
                                ),

                                SizedBox(height: 14 * scale),

                                // Terms
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 24 * scale,
                                      height: 24 * scale,
                                      child: Checkbox(
                                        value: _acceptedTerms,
                                        activeColor: primaryGreen,
                                        side: BorderSide(
                                          color: _termsError
                                              ? Colors.redAccent
                                              : borderColor,
                                          width: 1.5,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _acceptedTerms = value ?? false;
                                            if (_acceptedTerms) {
                                              _termsError = false;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10 * scale),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 3 * scale),
                                        child: Text(
                                          'I agree to the Terms of Service and Privacy Policy, and I confirm I am using my own real email and phone number.',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11 * scale,
                                            height: 1.55,
                                            color: _termsError
                                                ? Colors.redAccent
                                                : secondaryText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20 * scale),

                                // Sign up button
                                SizedBox(
                                  height: 54 * scale,
                                  child: ElevatedButton(
                                    onPressed: _handleSignUp,
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Create Account',
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

                                SizedBox(height: 20 * scale),

                                // Back to login
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12.5 * scale,
                                        color: secondaryText,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: widget.onLogin ??
                                          () => Navigator.of(context).maybePop(),
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
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5 * scale,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),



                               
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

// Decorative background shapes (same as the splash and login screens).
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