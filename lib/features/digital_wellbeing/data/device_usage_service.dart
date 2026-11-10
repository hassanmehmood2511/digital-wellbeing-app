import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Minutes one app was used on one day, as reported by Android.
class DeviceAppUsage {
  const DeviceAppUsage({
    required this.packageName,
    required this.label,
    required this.minutes,
  });

  final String packageName;
  final String label;
  final int minutes;
}

/// Usage for one calendar day (`date` is `yyyy-MM-dd`).
class DeviceDayUsage {
  const DeviceDayUsage({required this.date, required this.apps});

  final String date;
  final List<DeviceAppUsage> apps;
}

/// Reads real screen time from Android's UsageStatsManager through the
/// `behtar/usage_stats` channel implemented in `MainActivity.kt`.
///
/// Only Android supports this. On web and other platforms [isSupported] is
/// false and every call is a safe no-op.
abstract final class DeviceUsageService {
  static const MethodChannel _channel = MethodChannel('behtar/usage_stats');

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Whether the user has turned on "Usage access" for Behtar.
  static Future<bool> hasPermission() async {
    if (!isSupported) return false;
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Opens Android's "Usage access" settings page (on most phones, directly
  /// on Behtar's switch).
  static Future<void> openSettings() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException {
      // Nothing else we can do; the UI explains where to find the setting.
    } on MissingPluginException {
      // Running without the native side (e.g. tests).
    }
  }

  /// Per-app usage for the last [days] days, today first.
  static Future<List<DeviceDayUsage>> getDailyUsage({int days = 7}) async {
    if (!isSupported) return const [];
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'getDailyUsage',
      {'days': days},
    );
    if (raw == null) return const [];
    return raw.map((dayRaw) {
      final day = Map<String, dynamic>.from(dayRaw as Map);
      final apps = (day['apps'] as List<dynamic>? ?? const [])
          .map((appRaw) {
            final app = Map<String, dynamic>.from(appRaw as Map);
            return DeviceAppUsage(
              packageName: app['package'] as String,
              label: app['label'] as String,
              minutes: (app['minutes'] as num).toInt(),
            );
          })
          .toList();
      return DeviceDayUsage(date: day['date'] as String, apps: apps);
    }).toList();
  }
}
