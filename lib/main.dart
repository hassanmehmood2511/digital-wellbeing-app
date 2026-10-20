import 'package:flutter/material.dart';

import 'core/routing/app_navigation_shell.dart';
import 'features/rewards/rewards_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/signup-screen/signup_screen.dart';
import 'features/forgot_password_screen/forgot_password_screen.dart';
import 'features/login_screen/login_screen.dart';
import 'features/settings/settings_controller.dart';
import 'features/splashscreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PointsStore.instance.initialize();
  runApp(const BehtarApp());
}

class BehtarApp extends StatefulWidget {
  const BehtarApp({super.key});

  @override
  State<BehtarApp> createState() => _BehtarAppState();
}

class _BehtarAppState extends State<BehtarApp> {
  late final SettingsController _settingsController;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _hasStartedLogin = false;
  bool _isOpeningAuthRoute = false;
  bool _hasEnteredDashboard = false;

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
    if (_hasStartedLogin) return;
    _hasStartedLogin = true;

    _navigatorKey.currentState?.pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(
          onLogin: _openDashboard,
          onForgotPassword: _openForgotPassword,
          onSignUp: _openSignUp,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _openSignUp() {
    _openAuthRoute(
      SignUpScreen(onSignUp: _completeMockSignUp, onLogin: _backToLogin),
    );
  }

  void _completeMockSignUp(
    String name,
    String email,
    String phone,
    String password,
  ) {
    _openDashboard();
  }

  void _openForgotPassword() {
    _openAuthRoute(ForgotPasswordScreen(onBackToLogin: _backToLogin));
  }

  void _openAuthRoute(Widget screen) {
    if (_isOpeningAuthRoute || _hasEnteredDashboard) return;
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _isOpeningAuthRoute = true;
    navigator
        .push<void>(MaterialPageRoute<void>(builder: (_) => screen))
        .whenComplete(() => _isOpeningAuthRoute = false);
  }

  void _backToLogin() {
    final navigator = _navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    }
  }

  void _openDashboard() {
    if (_hasEnteredDashboard) return;
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _hasEnteredDashboard = true;
    // Temporary mock auth: replace this callback with backend authentication.
    navigator.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            AppNavigationShell(settingsController: _settingsController),
      ),
      (_) => false,
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
    );
  }
}
