import 'package:flutter/foundation.dart';

import '../../../core/backend/backend.dart';
import '../../../core/notifications/notification_service.dart';
import '../models/app_usage.dart';
import 'device_usage_service.dart';

/// Apps the user tracks, their daily limits and usage history.
///
/// Stored in Supabase tables `tracked_apps` (app list + limits) and
/// `app_usage_daily` (minutes used per app per day). Usage minutes are written
/// from the phone by [syncFromDevice] (Android "Usage access").
class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  /// Apps suggested to every new account.
  static const List<String> defaultApps = [
    'Instagram',
    'TikTok',
    'YouTube',
    'WhatsApp',
    'Facebook',
    'Twitter / X',
    'Snapchat',
  ];
  static const int _defaultLimitMinutes = 60;
  static const Set<String> _trackedByDefault = {
    'Instagram',
    'TikTok',
    'YouTube',
    'WhatsApp',
  };

  List<AppUsage> apps = [];

  /// Total tracked minutes per day for the last 7 days, oldest first.
  final Map<String, Map<String, int>> _usageByDay = {};

  bool isLoading = false;
  bool hasLoaded = false;
  String? loadError;

  /// Android package names for the default apps (labels can differ by
  /// region, e.g. "Twitter / X" is just "X" on the phone).
  static const Map<String, List<String>> knownPackages = {
    'Instagram': ['com.instagram.android', 'com.instagram.lite'],
    'TikTok': [
      'com.zhiliaoapp.musically',
      'com.ss.android.ugc.trill',
      'com.zhiliaoapp.musically.go',
      'com.ss.android.ugc.tiktok.lite',
    ],
    'YouTube': ['com.google.android.youtube'],
    'WhatsApp': ['com.whatsapp', 'com.whatsapp.w4b'],
    'Facebook': ['com.facebook.katana', 'com.facebook.lite'],
    'Twitter / X': ['com.twitter.android'],
    'Snapchat': ['com.snapchat.android'],
  };

  /// Whether this device can record screen time (Android only).
  bool get trackingSupported => DeviceUsageService.isSupported;

  /// null = not checked yet.
  bool? usageAccessGranted;
  bool isSyncing = false;
  DateTime? lastSyncedAt;

  /// Apps used on this phone today (for suggestions when adding apps).
  List<DeviceAppUsage> deviceAppsToday = const [];

  Future<void> load() async {
    final client = Backend.client;
    final userId = Backend.userId;
    if (client == null || userId == null) return;

    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      var rows = await client
          .from('tracked_apps')
          .select()
          .eq('user_id', userId)
          .order('sort_order');

      if (rows.isEmpty) {
        // First time: give the user the default list of apps to track.
        final defaults = <Map<String, dynamic>>[
          for (var i = 0; i < defaultApps.length; i++)
            {
              'user_id': userId,
              'app_name': defaultApps[i],
              'daily_limit_minutes': _defaultLimitMinutes,
              'is_tracked': _trackedByDefault.contains(defaultApps[i]),
              'sort_order': i,
            },
        ];
        await client
            .from('tracked_apps')
            .upsert(defaults, onConflict: 'user_id,app_name');
        rows = defaults;
      }

      final today = dateOnly(DateTime.now());
      final weekStart = today.subtract(const Duration(days: 6));
      final usageRows = await client
          .from('app_usage_daily')
          .select('app_name, usage_date, usage_minutes')
          .eq('user_id', userId)
          .gte('usage_date', dateKey(weekStart));

      _usageByDay.clear();
      for (final row in usageRows) {
        _usageByDay.putIfAbsent(row['usage_date'] as String, () => {})[row['app_name']
                as String] =
            (row['usage_minutes'] as num).toInt();
      }
      final todayUsage = _usageByDay[dateKey(today)] ?? const <String, int>{};

      apps = rows
          .map(
            (row) => AppUsage(
              appName: row['app_name'] as String,
              usageMinutes: todayUsage[row['app_name'] as String] ?? 0,
              dailyLimitMinutes: (row['daily_limit_minutes'] as num).toInt(),
              isTracked: row['is_tracked'] as bool? ?? true,
            ),
          )
          .toList();
      hasLoaded = true;
    } catch (error) {
      loadError = friendlyErrorMessage(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }

    if (hasLoaded) await syncFromDevice();
  }

  /// Reads the last 7 days of real usage from the phone, updates the apps and
  /// chart, and saves it to Supabase. Returns false when usage access isn't
  /// granted or the platform doesn't support it.
  Future<bool> syncFromDevice() async {
    if (!trackingSupported || isSyncing) return false;

    final granted = await DeviceUsageService.hasPermission();
    if (usageAccessGranted != granted) {
      usageAccessGranted = granted;
      notifyListeners();
    }
    if (!granted) return false;

    isSyncing = true;
    try {
      final days = await DeviceUsageService.getDailyUsage(days: 7);
      final today = dateKey(DateTime.now());
      final rows = <Map<String, dynamic>>[];
      final userId = Backend.userId;

      for (final day in days) {
        final perApp = _usageByDay.putIfAbsent(day.date, () => {});
        for (final app in apps) {
          final minutes = _minutesFor(app.appName, day.apps);
          perApp[app.appName] = minutes;
          if (day.date == today) app.usageMinutes = minutes;
          if (userId != null && (minutes > 0 || day.date == today)) {
            rows.add({
              'user_id': userId,
              'app_name': app.appName,
              'usage_date': day.date,
              'usage_minutes': minutes,
            });
          }
        }
        if (day.date == today) {
          deviceAppsToday = List.unmodifiable(
            List<DeviceAppUsage>.of(day.apps)
              ..sort((a, b) => b.minutes.compareTo(a.minutes)),
          );
        }
      }
      lastSyncedAt = DateTime.now();
      notifyListeners();

      // 80% / 100% of daily limit alerts (once per app per day).
      await NotificationService.checkScreenTimeLimits([
        for (final app in apps.where((a) => a.isTracked))
          (
            appName: app.appName,
            usageMinutes: app.usageMinutes,
            limitMinutes: app.dailyLimitMinutes,
          ),
      ]);

      final client = Backend.client;
      if (client != null && rows.isNotEmpty) {
        await client
            .from('app_usage_daily')
            .upsert(rows, onConflict: 'user_id,app_name,usage_date');
      }
      return true;
    } catch (error) {
      debugPrint('Usage sync failed: $error');
      return false;
    } finally {
      isSyncing = false;
    }
  }

  static int _minutesFor(String appName, List<DeviceAppUsage> usage) {
    final packages = knownPackages[appName] ?? const <String>[];
    final name = appName.trim().toLowerCase();
    var total = 0;
    for (final app in usage) {
      if (packages.contains(app.packageName) ||
          app.label.trim().toLowerCase() == name) {
        total += app.minutes;
      }
    }
    return total.clamp(0, 1440);
  }

  /// Clears everything (used on sign out).
  void reset() {
    apps = [];
    deviceAppsToday = const [];
    lastSyncedAt = null;
    _usageByDay.clear();
    hasLoaded = false;
    loadError = null;
    notifyListeners();
  }

  void updateLimit(String appName, int newLimit) {
    final index = apps.indexWhere((a) => a.appName == appName);
    if (index == -1) return;
    apps[index].dailyLimitMinutes = newLimit;
    notifyListeners();
    _sync(
      () => Backend.client!
          .from('tracked_apps')
          .update({'daily_limit_minutes': newLimit})
          .eq('user_id', Backend.userId!)
          .eq('app_name', appName),
    );
  }

  /// Replaces the whole app list (used by the "Tracked apps" screen).
  void saveApps(List<AppUsage> updated) {
    final removed = apps
        .map((a) => a.appName)
        .where((name) => !updated.any((u) => u.appName == name))
        .toList();
    apps = updated;
    notifyListeners();

    final userId = Backend.userId;
    _sync(() async {
      final client = Backend.client!;
      if (updated.isNotEmpty) {
        await client.from('tracked_apps').upsert([
          for (var i = 0; i < updated.length; i++)
            {
              'user_id': userId,
              'app_name': updated[i].appName,
              'daily_limit_minutes': updated[i].dailyLimitMinutes,
              'is_tracked': updated[i].isTracked,
              'sort_order': i,
            },
        ], onConflict: 'user_id,app_name');
      }
      if (removed.isNotEmpty) {
        await client
            .from('tracked_apps')
            .delete()
            .eq('user_id', userId!)
            .inFilter('app_name', removed);
      }
    });
    syncFromDevice();
  }

  /// Total minutes on tracked apps for each of the last 7 days (oldest first,
  /// today last).
  List<int> getWeeklyUsage() {
    final trackedNames = apps
        .where((app) => app.isTracked)
        .map((a) => a.appName)
        .toSet();
    final today = dateOnly(DateTime.now());
    return List<int>.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      if (i == 6) {
        return apps
            .where((app) => app.isTracked)
            .fold(0, (sum, app) => sum + app.usageMinutes);
      }
      final usage = _usageByDay[dateKey(day)] ?? const <String, int>{};
      return usage.entries
          .where((e) => trackedNames.contains(e.key))
          .fold(0, (sum, e) => sum + e.value);
    });
  }

  /// Short labels matching [getWeeklyUsage] (e.g. Mon, Tue … Today).
  List<String> weeklyLabels() {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = dateOnly(DateTime.now());
    return List<String>.generate(7, (i) {
      if (i == 6) return 'Today';
      final day = today.subtract(Duration(days: 6 - i));
      return names[day.weekday - 1];
    });
  }

  void _sync(Future<void> Function() action) {
    if (Backend.client == null || Backend.userId == null) return;
    action().catchError((Object error) {
      reportSyncError(error, message: 'Couldn’t save your app settings.');
    });
  }
}
