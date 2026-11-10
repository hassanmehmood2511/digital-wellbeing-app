import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/backend/backend.dart';
import 'core/notifications/notification_inbox.dart';
import 'core/notifications/notification_service.dart';
import 'core/routing/app_navigation_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/digital_wellbeing/data/app_data.dart';
import 'features/habits/data/habit_store.dart';
import 'features/onboarding_screen/screen_01.dart';
import 'features/rewards/rewards_store.dart';
import 'features/settings/notification_scheduler.dart';
import 'features/settings/settings_controller.dart';
import 'features/splashscreen/splash_screen.dart';

const String _rememberMeKey = 'remember_me';

/// Start-up work (Supabase, notifications). Runs while the animated splash
/// is on screen, so the app appears instantly instead of waiting on a blank
/// launch screen.
Future<void> appStartup = Future<void>.value();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  appStartup = _startServices();
  runApp(const BehtarApp());
}

Future<void> _startServices() async {
  await Backend.initialize();
  await NotificationService.initialize();

  // If the user unticked "Remember me" last time, start signed out.
  try {
    final prefs = await SharedPreferences.getInstance();
    if (Backend.isSignedIn && prefs.getBool(_rememberMeKey) == false) {
      await Backend.client!.auth
          .signOut(scope: SignOutScope.local)
          .timeout(const Duration(seconds: 5));
    }
  } catch (_) {
    // Not critical: the user simply stays signed in.
  }
}

class BehtarApp extends StatefulWidget {
  const BehtarApp({this.home, this.skipStartupFlow = false, super.key});

  final Widget? home;

  /// Opens the dashboard directly, skipping splash, onboarding and auth.
  /// Intended for widget tests only.
  final bool skipStartupFlow;

  @override
  State<BehtarApp> createState() => _BehtarAppState();
}

class _BehtarAppState extends State<BehtarApp> {
  static const String _onboardingKey = 'onboarding_completed';

  static const bool _alwaysShowOnboarding = false;

  late final SettingsController _settingsController;
  late final NotificationScheduler _notificationScheduler;

  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  StreamSubscription<AuthState>? _authSubscription;

  bool _splashFinished = false;
  bool _hasStartedLogin = false;
  bool _isOpeningAuthRoute = false;
  bool _isCheckingOnboarding = false;
  bool _hasEnteredDashboard = false;
  bool _inPasswordRecovery = false;
  bool _pendingPasswordRecovery = false;

  @override
  void initState() {
    super.initState();
    _settingsController = SettingsController(
      email: Backend.currentUser?.email ?? '',
    );
    SettingsController.active = _settingsController;
    _notificationScheduler = NotificationScheduler(_settingsController);
    _listenToAuth();
    // If Supabase finished connecting after start-up, listen once it's ready.
    Backend.ready.then((_) {
      if (!mounted) return;
      _listenToAuth();
      _settingsController.email = Backend.currentUser?.email ?? '';
    });
  }

  void _listenToAuth() {
    if (_authSubscription != null) return;
    _authSubscription = Backend.client?.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: (Object error) => debugPrint('Auth stream error: $error'),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _notificationScheduler.stop();
    _settingsController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auth events (email links, Google sign-in, sign out, password recovery)
  // ---------------------------------------------------------------------------

  void _onAuthStateChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.passwordRecovery:
        if (_splashFinished) {
          _openResetPassword();
        } else {
          _pendingPasswordRecovery = true;
        }
      case AuthChangeEvent.signedIn:
        // Covers Google sign-in and email confirmation links, which return to
        // the app through a deep link rather than the login button.
        if (_splashFinished && !_inPasswordRecovery) _openDashboard();
      case AuthChangeEvent.signedOut:
        _onSignedOut();
      default:
        break;
    }
  }

  void _onSignedOut() {
    _notificationScheduler.stop();
    NotificationInbox.instance.reset();
    HabitStore.instance.reset();
    PointsStore.instance.reset();
    AppData().reset();
    _settingsController.reset();

    _hasEnteredDashboard = false;
    _hasStartedLogin = false;
    _inPasswordRecovery = false;
    if (_splashFinished) _goToLogin();
  }

  // ---------------------------------------------------------------------------
  // Start-up: Splash -> (signed in? Home) / Onboarding (first launch) -> Login
  // ---------------------------------------------------------------------------

  Future<void> _afterSplash() async {
    if (_isCheckingOnboarding || _splashFinished) return;
    // Make sure start-up (Supabase, saved session) has finished.
    await appStartup;
    _splashFinished = true;

    if (_pendingPasswordRecovery) {
      _pendingPasswordRecovery = false;
      _openResetPassword();
      return;
    }

    if (Backend.isSignedIn) {
      _openDashboard();
      return;
    }

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
        pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(
          onLogin: _login,
          onForgotPassword: _openForgotPassword,
          onSignUp: _openSignUp,
          onGoogleSignIn: _signInWithGoogle,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (_) => false,
    );
  }

  // ---------------------------------------------------------------------------
  // Auth actions
  // ---------------------------------------------------------------------------

  Future<void> _login(String email, String password, bool rememberMe) async {
    final client = Backend.client;
    if (client == null) throw StateError('Backend not available');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);

    await client.auth.signInWithPassword(email: email, password: password);
    _openDashboard();
  }

  Future<void> _signUp(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    final client = Backend.client;
    if (client == null) throw StateError('Backend not available');

    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone': phone},
      emailRedirectTo: Backend.authRedirectUrl,
    );

    // Supabase hides "already registered" for confirmed emails by returning
    // a user with no identities instead of an error.
    final identities = response.user?.identities;
    if (response.session == null &&
        identities != null &&
        identities.isEmpty) {
      throw AuthException('User already registered');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, true);

    if (response.session != null) {
      // Email confirmation is off in Supabase: the user is signed in.
      _openDashboard();
      return;
    }

    // Email confirmation is on: go back to login and explain what to do next.
    _backToLogin();
    appMessengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text(
          'Almost done! We sent a confirmation link to $email. '
          'Open it on this phone, then log in.',
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset(String email) async {
    final client = Backend.client;
    if (client == null) throw StateError('Backend not available');
    await client.auth.resetPasswordForEmail(
      email,
      redirectTo: Backend.authRedirectUrl,
    );
  }

  Future<void> _signInWithGoogle() async {
    final client = Backend.client;
    if (client == null) throw StateError('Backend not available');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, true);
    // Opens Google in the browser; the app continues in _onAuthStateChange
    // when the browser returns through the deep link.
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Backend.authRedirectUrl,
    );
  }

  Future<void> _saveNewPassword(String password) async {
    final client = Backend.client;
    if (client == null) throw StateError('Backend not available');
    await client.auth.updateUser(UserAttributes(password: password));
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _openSignUp() {
    _openAuthRoute(
      SignUpScreen(
        onSignUp: _signUp,
        onLogin: _backToLogin,
      ),
    );
  }

  void _openForgotPassword() {
    _openAuthRoute(
      ForgotPasswordScreen(
        onSendLink: _sendPasswordReset,
        onBackToLogin: _backToLogin,
      ),
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

  void _openResetPassword() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    _inPasswordRecovery = true;
    _hasEnteredDashboard = false;
    _hasStartedLogin = false;

    navigator.pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => ResetPasswordScreen(
          onSavePassword: _saveNewPassword,
          onDone: () {
            _inPasswordRecovery = false;
            _openDashboard();
          },
        ),
      ),
      (_) => false,
    );
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
    _hasStartedLogin = false;
    _settingsController.email = Backend.currentUser?.email ?? '';
    _notificationScheduler.start();

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
      scaffoldMessengerKey: appMessengerKey,
      title: 'Behtar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Respect the phone's font size, but cap very large settings so
      // layouts stay readable instead of overflowing.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      // App always starts on the splash screen:
      // Splash -> Home (already signed in)
      //        -> Onboarding (first launch only) -> Login / Sign up -> Home.
      home: widget.home ??
          (widget.skipStartupFlow
              ? AppNavigationShell(settingsController: _settingsController)
              : SplashScreen(onFinished: _afterSplash)),
    );
  }
}
