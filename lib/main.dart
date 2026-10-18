import 'package:flutter/material.dart';

import 'package:digital_wellbeing_app/core/theme/app_theme.dart';
import 'package:digital_wellbeing_app/features/settings/settings_controller.dart';
import 'package:digital_wellbeing_app/features/auth/signup-screen/signup_screen.dart';

void main() {
  runApp(const BehtarApp());
}

class BehtarApp extends StatefulWidget {
  const BehtarApp({super.key});

  @override
  State<BehtarApp> createState() => _BehtarAppState();
}

class _BehtarAppState extends State<BehtarApp> {
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController();
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Behtar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Temporarily showing the Sign Up screen for testing.
      home: SignUpScreen(
        // Phone is in full international format, e.g. +923001234567.
        onSignUp: (name, email, phone, password) {
          debugPrint('Sign up: $name | $email | $phone');
        },
      ),
    );
  }
}