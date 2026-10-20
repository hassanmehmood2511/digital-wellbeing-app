import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/routing/app_navigation_shell.dart';
import 'features/rewards/rewards_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/signup-screen/signup_screen.dart';
import 'features/forgot_password_screen/forgot_password_screen.dart';
import 'features/login_screen/login_screen.dart';
import 'features/onboarding_screen/screen_01.dart';
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
  // Saved on the device once the user has finished (or skipped) onboarding.
  static const String _onboardingKey = 'onboarding_completed';

  // Set to true while testing, so onboarding shows after every login.
  // Set back to false before release.
  static const bool _alwaysShowOnboarding = false;

  late final SettingsController _settingsController;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _hasStartedLogin = false;
  bool _isOpeningAuthRoute = false;
  bool _isCheckingOnboarding = false;
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
          onLogin: _afterAuthentication,
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
    _afterAuthentication();
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

  // Called after a successful login or sign up.
  // First-time users see onboarding, everyone else goes to the dashboard.
  Future<void> _afterAuthentication() async {
    if (_hasEnteredDashboard || _isCheckingOnboarding) return;
    _isCheckingOnboarding = true;

    bool alreadySeen = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      alreadySeen = prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      // If storage fails, skip onboarding instead of blocking the user.
      alreadySeen = true;
    }

    _isCheckingOnboarding = false;

    if (alreadySeen && !_alwaysShowOnboarding) {
      _openDashboard();
    } else {
      _openOnboarding();
    }
  }

  void _openOnboarding() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    // Clears login / sign up from the back stack.
    navigator.pushAndRemoveUntil<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            OnboardingScreenOne(onFinished: _finishOnboarding),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (_) => false,
    );
  }

  // Called by Skip or Get Started on the onboarding screens.
  Future<void> _finishOnboarding() async {
    if (_hasEnteredDashboard) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {
      // Not critical: onboarding may simply show again next time.
    }

    _openDashboard();
  }

  void _openDashboard() {
    if (_hasEnteredDashboard) return;
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _hasEnteredDashboard = true;
    // Temporary mock auth: replace this callback with backend authentication.
    navigator.pushAndRemoveUntil<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppNavigationShell(settingsController: _settingsController),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
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