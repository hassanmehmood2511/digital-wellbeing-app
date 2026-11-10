import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, TimeOfDay;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notification_inbox.dart';

/// What the user wants to be reminded about (from Notification settings).
class ReminderPlan {
  const ReminderPlan({
    required this.enabled,
    required this.habitReminders,
    required this.dailyCheckIn,
    required this.wellbeingTips,
    required this.habitReminderTime,
    required this.checkInTime,
    required this.totalHabits,
    required this.habitsLeftToday,
  });

  final bool enabled;
  final bool habitReminders;
  final bool dailyCheckIn;
  final bool wellbeingTips;
  final TimeOfDay habitReminderTime;
  final TimeOfDay checkInTime;
  final int totalHabits;
  final int habitsLeftToday;
}

/// Local notifications for Behtar (Android). Everything is scheduled on the
/// phone, so reminders arrive even when the app is closed or offline.
abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _deviceChannel = MethodChannel(
    'behtar/usage_stats',
  );

  static bool _initialized = false;

  /// Set by the scheduler: whether 80% / 100% screen-time alerts are wanted.
  static bool screenTimeAlertsEnabled = false;

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // Notification ids (ranges so each group can be replaced cleanly).
  static const int _checkInBaseId = 1000; // 1000–1006: next 7 days
  static const int _habitBaseId = 1100; // 1100–1106: next 7 days
  static const int _tipBaseId = 1200; // 1200–1206: next 7 days
  static const int _testId = 1900;
  static const int _screenTimeBaseId = 2000;

  static const TimeOfDay _tipTime = TimeOfDay(hour: 14, minute: 0);
  static const Color _brandColor = Color(0xFF10B982);

  static const AndroidNotificationDetails _checkInChannel =
      AndroidNotificationDetails(
        'daily_check_in',
        'Daily check-in',
        channelDescription: 'A morning moment to plan your day',
        importance: Importance.defaultImportance,
        color: _brandColor,
      );
  static const AndroidNotificationDetails _habitChannel =
      AndroidNotificationDetails(
        'habit_reminders',
        'Habit reminders',
        channelDescription: 'Nudges for habits you haven’t finished today',
        importance: Importance.high,
        priority: Priority.high,
        color: _brandColor,
      );
  static const AndroidNotificationDetails _screenTimeChannel =
      AndroidNotificationDetails(
        'screen_time',
        'Screen time alerts',
        channelDescription: 'When an app reaches its daily limit',
        importance: Importance.high,
        priority: Priority.high,
        color: _brandColor,
      );

  static const List<String> _tips = [
    'Try a 20-20-20 break: every 20 minutes, look 20 feet away for 20 seconds.',
    'Put your phone in another room for the first 30 minutes after waking.',
    'A short walk after lunch helps your focus for the rest of the day.',
    'Turn off notifications for one app you don’t really need today.',
    'Drink a glass of water before you reach for your phone.',
    'Keep your phone off the dinner table tonight and enjoy the conversation.',
    'Swap 10 minutes of scrolling for 10 minutes of reading.',
  ];

  static Future<void> initialize() async {
    if (!isSupported || _initialized) return;
    try {
      tzdata.initializeTimeZones();
      await _setLocalTimeZone();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_stat_behtar'),
        ),
      );
      _initialized = true;
    } catch (error) {
      debugPrint('Notifications could not start: $error');
    }
  }

  static Future<void> _setLocalTimeZone() async {
    try {
      final name = await _deviceChannel.invokeMethod<String>('getTimeZone');
      if (name != null) {
        tz.setLocalLocation(tz.getLocation(name));
        return;
      }
    } catch (_) {
      // Fall through to offset matching.
    }
    // Fallback: any zone with the phone's current UTC offset.
    final offset = DateTime.now().timeZoneOffset.inMilliseconds;
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (location.currentTimeZone.offset == offset) {
        tz.setLocalLocation(location);
        return;
      }
    }
  }

  /// Whether Android allows Behtar to show notifications.
  static Future<bool> areEnabled() async {
    if (!isSupported) return false;
    await initialize();
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Shows Android's "Allow notifications?" popup (Android 13+).
  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await initialize();
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? await areEnabled();
    } catch (_) {
      return false;
    }
  }

  /// Replaces every scheduled reminder according to [plan].
  static Future<void> reschedule(ReminderPlan plan) async {
    if (!isSupported) return;
    await initialize();
    if (!_initialized) return;

    final planned = <InboxItem>[];
    try {
      for (var i = 0; i < 7; i++) {
        await _plugin.cancel(_checkInBaseId + i);
        await _plugin.cancel(_habitBaseId + i);
        await _plugin.cancel(_tipBaseId + i);
      }
      if (!plan.enabled) {
        await NotificationInbox.instance.setPending(const []);
        return;
      }

      final now = tz.TZDateTime.now(tz.local);

      Future<void> schedule({
        required int id,
        required InboxType type,
        required String title,
        required String body,
        required tz.TZDateTime when,
        required NotificationDetails details,
      }) async {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        planned.add(
          InboxItem(
            id: '${type.name}@${when.millisecondsSinceEpoch}',
            type: type,
            title: title,
            body: body,
            time: when,
          ),
        );
      }

      for (var day = 0; day < 7; day++) {
        if (plan.dailyCheckIn) {
          final when = _onDay(now, day, plan.checkInTime);
          if (when.isAfter(now)) {
            await schedule(
              id: _checkInBaseId + day,
              type: InboxType.checkIn,
              title: 'Good morning 🌱',
              body:
                  'Take a moment to plan your day. Which habit matters most today?',
              when: when,
              details: const NotificationDetails(android: _checkInChannel),
            );
          }
        }

        if (plan.habitReminders && plan.totalHabits > 0) {
          final when = _onDay(now, day, plan.habitReminderTime);
          // Today: only remind if something is still left to do.
          final skipToday = day == 0 && plan.habitsLeftToday == 0;
          if (when.isAfter(now) && !skipToday) {
            final left = day == 0 ? plan.habitsLeftToday : plan.totalHabits;
            await schedule(
              id: _habitBaseId + day,
              type: InboxType.habit,
              title: 'Your habits are waiting',
              body: left == 1
                  ? 'You have 1 habit left today. Small steps, big changes!'
                  : 'You have $left habits left today. Small steps, big changes!',
              when: when,
              details: const NotificationDetails(android: _habitChannel),
            );
          }
        }

        if (plan.wellbeingTips) {
          final when = _onDay(now, day, _tipTime);
          if (when.isAfter(now)) {
            final tip =
                _tips[when.difference(DateTime(2026)).inDays % _tips.length];
            await schedule(
              id: _tipBaseId + day,
              type: InboxType.tip,
              title: 'Wellbeing tip',
              body: tip,
              when: when,
              details: NotificationDetails(
                android: AndroidNotificationDetails(
                  'wellbeing_tips',
                  'Wellbeing tips',
                  channelDescription:
                      'Occasional ideas for a healthier balance',
                  importance: Importance.low,
                  priority: Priority.low,
                  color: _brandColor,
                  styleInformation: BigTextStyleInformation(tip),
                ),
              ),
            );
          }
        }
      }
    } catch (error) {
      debugPrint('Scheduling notifications failed: $error');
    }

    // Reminders only reach the inbox if Android is allowed to show them.
    final allowed = await areEnabled();
    await NotificationInbox.instance.setPending(allowed ? planned : const []);
  }

  /// Alerts once per app per day at 80% and 100% of its daily limit.
  static Future<void> checkScreenTimeLimits(
    List<({String appName, int usageMinutes, int limitMinutes})> apps,
  ) async {
    if (!isSupported || !screenTimeAlertsEnabled) return;
    await initialize();
    if (!_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final dayKey = '${today.year}-${today.month}-${today.day}';
      for (var i = 0; i < apps.length; i++) {
        final app = apps[i];
        if (app.limitMinutes <= 0) continue;
        final ratio = app.usageMinutes / app.limitMinutes;
        final level = ratio >= 1 ? 100 : (ratio >= 0.8 ? 80 : 0);
        if (level == 0) continue;
        final key = 'screen_alert_${dayKey}_${app.appName}_$level';
        if (prefs.getBool(key) == true) continue;
        await prefs.setBool(key, true);
        final left = app.limitMinutes - app.usageMinutes;
        final title = level == 100
            ? '${app.appName}: daily limit reached'
            : '${app.appName}: almost at your limit';
        final body = level == 100
            ? 'You’ve used ${app.appName} for ${app.usageMinutes} min today. '
                  'Maybe time for a break?'
            : 'About $left min left of your ${app.limitMinutes} min limit.';
        await _plugin.show(
          _screenTimeBaseId + i,
          title,
          body,
          const NotificationDetails(android: _screenTimeChannel),
        );
        await NotificationInbox.instance.add(
          type: InboxType.screenTime,
          title: title,
          body: body,
        );
      }
    } catch (error) {
      debugPrint('Screen-time alert failed: $error');
    }
  }

  /// Sends a notification right now (for the "Send test" button).
  static Future<void> showTest() async {
    if (!isSupported) return;
    await initialize();
    if (!_initialized) return;
    const title = 'Behtar notifications are on ✅';
    const body = 'This is how your reminders will look.';
    await _plugin.show(
      _testId,
      title,
      body,
      const NotificationDetails(android: _habitChannel),
    );
    await NotificationInbox.instance.add(
      type: InboxType.system,
      title: title,
      body: body,
    );
  }

  static Future<void> cancelAll() async {
    if (!isSupported || !_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  static tz.TZDateTime _onDay(tz.TZDateTime now, int dayOffset, TimeOfDay t) {
    return tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + dayOffset,
      t.hour,
      t.minute,
    );
  }
}
