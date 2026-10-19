
import 'package:flutter/material.dart';

import 'package:digital_wellbeing_app/core/theme/app_theme.dart';
import 'package:digital_wellbeing_app/features/settings/settings_controller.dart';
import 'package:digital_wellbeing_app/features/forgot_password_screen/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_navigation_shell.dart';
import 'features/settings/settings_controller.dart';
import 'features/login_screen/login_screen.dart';
// Adjust this path to match where your splash screen file is.
import 'features/splash_screen/splash_screen.dart';
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

  // Needed so we can navigate from the splash screen callback,
  // because that callback runs above MaterialApp's Navigator context.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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

  void _goToLogin() {
    // pushReplacement removes the splash from the stack,
    // so the back button will not return to it.
    _navigatorKey.currentState?.pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Behtar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SplashScreen(onFinished: _goToLogin),

      // Temporarily showing the Forgot Password screen for testing.
      home: const ForgotPasswordScreen(),
      home: SplashScreen(
       onFinished: () {},
      ),
      home: AppNavigationShell(settingsController: _settingsController),
    );
  }
}