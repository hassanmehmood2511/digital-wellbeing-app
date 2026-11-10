import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/notifications/notification_inbox.dart';
import '../../core/notifications/notification_service.dart';
import '../habits/data/habit_store.dart';
import 'settings_controller.dart';

/// Keeps the phone's scheduled reminders in step with the user's notification
/// settings and today's habits. Started after sign in, stopped on sign out.
class NotificationScheduler {
  NotificationScheduler(this.settings);

  final SettingsController settings;
  Timer? _debounce;
  bool _running = false;

  static const String _askedKey = 'notify_permission_asked';

  void start() {
    if (_running || !NotificationService.isSupported) return;
    _running = true;
    settings.addListener(_scheduleSoon);
    HabitStore.instance.addListener(_scheduleSoon);
    _askForPermissionOnce();
    _scheduleSoon();
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _debounce?.cancel();
    settings.removeListener(_scheduleSoon);
    HabitStore.instance.removeListener(_scheduleSoon);
    NotificationService.screenTimeAlertsEnabled = false;
    await NotificationService.cancelAll();
    // Cancelled reminders were never delivered: don't log them later.
    await NotificationInbox.instance.discardPending();
    NotificationInbox.instance.reset();
  }

  /// Shows Android's "Allow notifications?" popup the first time, if the user
  /// has notifications switched on in Behtar.
  Future<void> _askForPermissionOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_askedKey) == true) return;
      // Give the profile a moment to load so we respect the saved setting.
      await Future<void>.delayed(const Duration(seconds: 3));
      if (!_running || !settings.notificationsEnabled) return;
      await prefs.setBool(_askedKey, true);
      await NotificationService.requestPermission();
    } catch (_) {}
  }

  void _scheduleSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _apply);
  }

  Future<void> _apply() async {
    if (!_running) return;
    NotificationService.screenTimeAlertsEnabled =
        settings.notificationsEnabled && settings.gentleRemindersEnabled;

    final habits = HabitStore.instance.habits;
    await NotificationService.reschedule(
      ReminderPlan(
        enabled: settings.notificationsEnabled,
        habitReminders: settings.habitRemindersEnabled,
        dailyCheckIn: settings.dailyCheckInEnabled,
        wellbeingTips: settings.wellbeingTipsEnabled,
        habitReminderTime: settings.habitReminderTime,
        checkInTime: settings.checkInTime,
        totalHabits: habits.length,
        habitsLeftToday: habits.where((h) => !h.isCompleted).length,
      ),
    );
  }
}
