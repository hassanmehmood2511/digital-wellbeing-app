
import 'package:flutter/material.dart';

import 'package:digital_wellbeing_app/core/theme/app_theme.dart';
import 'package:digital_wellbeing_app/features/settings/settings_controller.dart';
import 'package:digital_wellbeing_app/features/forgot_password_screen/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_navigation_shell.dart';
import 'features/settings/settings_controller.dart';
import 'features/settings/settings_screen.dart';
import 'features/splashscreen/splash_screen.dart';

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

      // Temporarily showing the Forgot Password screen for testing.
      home: const ForgotPasswordScreen(),
      home: SplashScreen(
       onFinished: () {},
      ),
      home: AppNavigationShell(settingsController: _settingsController),
    );
  }
}
