import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_navigation_shell.dart';
import 'features/rewards/rewards_store.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding_screen/screen_01.dart';
import 'features/settings/settings_controller.dart';
import 'features/splashscreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://rubhqtlgalqkaiuojrtc.supabase.co',
    publishableKey: 'sb_publishable_f5ziYES32nYpRrJ6_ORT8g_Crj0-Zow',
  );

  // Initialize local rewards storage
  await PointsStore.instance.initialize();

  runApp(const BehtarApp());
}

class BehtarApp extends StatefulWidget {
  const BehtarApp({this.home, super.key});

  final Widget? home;

  @override
  State<BehtarApp> createState() => _BehtarAppState();
}

class _BehtarAppState extends State<BehtarApp> {
  static const String _onboardingKey = 'onboarding_completed';

  static const bool _alwaysShowOnboarding = false;

  late final SettingsController _settingsController;

  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

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

  /// Called when the splash animation completes.
  /// First launch -> onboarding, otherwise straight to login.
  Future<void> _afterSplash() async {
    if (_isCheckingOnboarding) return;
    _isCheckingOnboarding = true;

    bool alreadySeen = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      alreadySeen = prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      alreadySeen = false;
    }

    _isCheckingOnboarding = false;

    if (alreadySeen && !_alwaysShowOnboarding) {
      _goToLogin();
    } else {
      _openOnboarding();
    }
  }

  void _goToLogin() {
    if (_hasStartedLogin) return;
    _hasStartedLogin = true;

    _navigatorKey.currentState?.pushAndRemoveUntil<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(
          onLogin: _afterAuthentication,
          onForgotPassword: _openForgotPassword,
          onSignUp: _openSignUp,
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (_) => false,
    );
  }

  void _openSignUp() {
    _openAuthRoute(
      SignUpScreen(
        onSignUp: _completeMockSignUp,
        onLogin: _backToLogin,
      ),
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
    _openAuthRoute(
      ForgotPasswordScreen(onBackToLogin: _backToLogin),
    );
  }

  void _openAuthRoute(Widget screen) {
    if (_isOpeningAuthRoute || _hasEnteredDashboard) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _isOpeningAuthRoute = true;

    navigator
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => screen,
          ),
        )
        .whenComplete(() => _isOpeningAuthRoute = false);
  }

  void _backToLogin() {
    final navigator = _navigatorKey.currentState;

    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    }
  }

  /// Called after a successful login or sign up.
  void _afterAuthentication() {
    _openDashboard();
  }

  void _openOnboarding() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushAndRemoveUntil<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            OnboardingScreenOne(
          onFinished: _finishOnboarding,
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (_) => false,
    );
  }

  Future<void> _finishOnboarding() async {
    if (_hasStartedLogin) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (_) {
      // Onboarding can show again if local storage fails.
    }

    _goToLogin();
  }

  void _openDashboard() {
    if (_hasEnteredDashboard) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _hasEnteredDashboard = true;

    navigator.pushAndRemoveUntil<void>(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AppNavigationShell(
          settingsController: _settingsController,
        ),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
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
      // App always starts on the splash screen:
      // Splash -> Onboarding (first launch only) -> Login / Sign up -> Home.
      home: widget.home ?? SplashScreen(onFinished: _afterSplash),
    );
  }
}