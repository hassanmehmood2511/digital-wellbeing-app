import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/backend/backend.dart';
import '../widgets/auth_background_painter.dart';

/// Shown after the user opens the password-reset link from their email.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.onSavePassword,
    required this.onDone,
    super.key,
  });

  /// Saves the new password. Throw to show an error message.
  final Future<void> Function(String password) onSavePassword;

  /// Called after the password was saved successfully.
  final VoidCallback onDone;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  static const Color primaryGreen = Color(0xFF10B982);
  static const Color secondaryGreen = Color(0xFF075B49);
  static const Color background = Color(0xFFF4F8F7);
  static const Color primaryText = Color(0xFF172B27);
  static const Color secondaryText = Color(0xFF667873);
  static const Color borderColor = Color(0xFFDCE8E3);

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSavePassword(_passwordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your password has been updated.')),
      );
      widget.onDone();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
    }
  }

  InputDecoration _decoration(String hint, IconData icon) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: secondaryText.withValues(alpha: 0.75),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: secondaryGreen, size: 21),
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: secondaryText,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(primaryGreen, 1.5),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: CustomPaint(
        painter: const AuthBackgroundPainter(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFD0FAE4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: secondaryGreen,
                          size: 34,
                        ),
                      ),
                      Text(
                        'Set a new password',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose a strong password you haven’t used before.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: secondaryText,
                        ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscure,
                        decoration: _decoration(
                          'New password',
                          Icons.lock_outline_rounded,
                        ),
                        validator: (value) {
                          final password = value ?? '';
                          // Same rules as sign up.
                          if (password.length < 8) {
                            return 'Use at least 8 characters';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(password)) {
                            return 'Add at least one uppercase letter';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(password)) {
                            return 'Add at least one lowercase letter';
                          }
                          if (!RegExp(r'\d').hasMatch(password)) {
                            return 'Add at least one number';
                          }
                          if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
                            return 'Add at least one special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscure,
                        decoration: _decoration(
                          'Confirm new password',
                          Icons.lock_outline_rounded,
                        ),
                        validator: (value) => value != _passwordController.text
                            ? 'Passwords do not match.'
                            : null,
                        onFieldSubmitted: (_) => _save(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Save password',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
