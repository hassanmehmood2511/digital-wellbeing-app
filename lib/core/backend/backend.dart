import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export '../utils/date_formatters.dart' show dateKey, dateOnly;

/// Central access point for Supabase.
///
/// Every data store goes through [Backend.client]. When Supabase has not been
/// initialised (for example in widget tests) [client] is `null` and the stores
/// simply work in memory, so the UI never crashes because of a missing backend.
abstract final class Backend {
  static const String supabaseUrl = 'https://rubhqtlgalqkaiuojrtc.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_f5ziYES32nYpRrJ6_ORT8g_Crj0-Zow';

  /// Deep link used by Supabase emails (confirm sign up, reset password) and
  /// Google sign-in to return to the app. Must also be added in
  /// Supabase -> Authentication -> URL Configuration -> Redirect URLs.
  /// On web the browser returns to the current site instead (null lets
  /// Supabase use the Site URL).
  static String? get authRedirectUrl =>
      kIsWeb ? null : 'behtar://login-callback';

  static bool _initialized = false;

  static final Completer<void> _readyCompleter = Completer<void>();

  /// Completes when Supabase is connected (may be after start-up).
  static Future<void> get ready => _readyCompleter.future;

  /// Connects to Supabase. Never blocks start-up for more than [timeout]:
  /// if the network is slow the app opens anyway and the connection finishes
  /// in the background.
  static Future<void> initialize({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final connecting = Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    ).then((_) => _initialized = true);
    connecting.then(
      (_) {
        if (!_readyCompleter.isCompleted) _readyCompleter.complete();
      },
      onError: (Object error) {
        debugPrint('Supabase failed to start: $error');
      },
    );
    try {
      await connecting.timeout(timeout);
    } catch (error) {
      debugPrint('Supabase start-up is slow or failed: $error');
    }
  }

  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static User? get currentUser => client?.auth.currentUser;

  static String? get userId => currentUser?.id;

  static bool get isSignedIn => currentUser != null;
}

/// Shared messenger so background sync failures can be shown from anywhere.
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Shows a short, friendly message when a background save fails.
void reportSyncError(Object error, {String? message}) {
  debugPrint('Behtar sync error: $error');
  appMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message ??
              'Couldn’t sync with the server. Check your connection and try again.',
        ),
      ),
    );
}

/// Turns Supabase / network errors into a sentence a user can act on.
String friendlyErrorMessage(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email first. Check your inbox for the link.';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'An account with this email already exists. Try logging in.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a minute and try again.';
    }
    return error.message;
  }
  if (error is PostgrestException) {
    return 'Server error: ${error.message}';
  }
  final text = error.toString().toLowerCase();
  if (text.contains('socket') ||
      text.contains('network') ||
      text.contains('failed host lookup') ||
      text.contains('clientexception')) {
    return 'No internet connection. Please check your network and try again.';
  }
  return 'Something went wrong. Please try again.';
}

/// Random RFC 4122 v4 UUID, so new rows can be created optimistically on the
/// device with the same id they will have in the database.
String newUuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
