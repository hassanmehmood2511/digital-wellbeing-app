import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/backend.dart';

/// The signed-in user's profile and preferences, stored in the Supabase
/// `profiles` table (one row per user, created automatically on sign up).
class SettingsController extends ChangeNotifier {
  SettingsController({this.email = ''});

  /// The signed-in user's settings, for screens that aren't handed the
  /// controller directly (e.g. Usage limits). Set by the app at start-up.
  static SettingsController? active;

  String fullName = '';
  String email;
  String phone = '';
  String selectedLanguage = 'English';

  bool notificationsEnabled = true;
  bool habitRemindersEnabled = true;
  bool dailyCheckInEnabled = true;
  bool wellbeingTipsEnabled = false;
  bool gentleRemindersEnabled = true;

  /// Reminder times are per device (stored locally, not in the profile).
  TimeOfDay habitReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay checkInTime = const TimeOfDay(hour: 9, minute: 0);

  static const String _habitTimeKey = 'notify_habit_time';
  static const String _checkInTimeKey = 'notify_checkin_time';

  /// Name to show in greetings and groups, never empty.
  String get displayName {
    final name = fullName.trim();
    if (name.isNotEmpty) return name;
    final mail = email.trim();
    if (mail.contains('@')) return mail.split('@').first;
    return 'Friend';
  }

  Future<void> load() async {
    final client = Backend.client;
    final user = Backend.currentUser;
    if (client == null || user == null) return;

    email = user.email ?? email;
    await _loadReminderTimes();
    try {
      final row = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row == null) {
        // Profile row is normally created by a database trigger; create it
        // here as a fallback (e.g. users created before the schema existed).
        final metadata = user.userMetadata ?? const <String, dynamic>{};
        fullName = (metadata['full_name'] ?? metadata['name'] ?? '') as String;
        phone = (metadata['phone'] ?? '') as String;
        await client.from('profiles').upsert(_toRow(user.id));
      } else {
        fullName = (row['full_name'] as String?) ?? '';
        phone = (row['phone'] as String?) ?? '';
        selectedLanguage = (row['language'] as String?) ?? 'English';
        notificationsEnabled = row['notifications_enabled'] as bool? ?? true;
        habitRemindersEnabled = row['habit_reminders_enabled'] as bool? ?? true;
        dailyCheckInEnabled = row['daily_check_in_enabled'] as bool? ?? true;
        wellbeingTipsEnabled = row['wellbeing_tips_enabled'] as bool? ?? false;
        gentleRemindersEnabled =
            row['gentle_reminders_enabled'] as bool? ?? true;
      }
    } catch (error) {
      debugPrint('Profile load failed: $error');
    }
    notifyListeners();
  }

  /// Clears everything (used on sign out).
  void reset() {
    fullName = '';
    email = '';
    phone = '';
    selectedLanguage = 'English';
    notificationsEnabled = true;
    habitRemindersEnabled = true;
    dailyCheckInEnabled = true;
    wellbeingTipsEnabled = false;
    gentleRemindersEnabled = true;
    habitReminderTime = const TimeOfDay(hour: 20, minute: 0);
    checkInTime = const TimeOfDay(hour: 9, minute: 0);
    notifyListeners();
  }

  void updateReminderTimes({TimeOfDay? habitReminder, TimeOfDay? checkIn}) {
    habitReminderTime = habitReminder ?? habitReminderTime;
    checkInTime = checkIn ?? checkInTime;
    notifyListeners();
  }

  Future<void> _loadReminderTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      habitReminderTime = _parseTime(prefs.getString(_habitTimeKey)) ??
          habitReminderTime;
      checkInTime = _parseTime(prefs.getString(_checkInTimeKey)) ?? checkInTime;
    } catch (_) {}
  }

  Future<void> _saveReminderTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_habitTimeKey, _formatTime(habitReminderTime));
      await prefs.setString(_checkInTimeKey, _formatTime(checkInTime));
    } catch (_) {}
  }

  static String _formatTime(TimeOfDay t) => '${t.hour}:${t.minute}';

  static TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }

  void updateGentleReminders(bool enabled) {
    gentleRemindersEnabled = enabled;
    notifyListeners();
    save().catchError((Object error) {
      reportSyncError(error, message: 'Couldn’t save this setting.');
    });
  }

  void updateProfile({required String fullName, required String phone}) {
    this.fullName = fullName;
    this.phone = phone;
    notifyListeners();
  }

  void updateLanguage(String language) {
    selectedLanguage = language;
    notifyListeners();
  }

  void updateNotifications({
    bool? enabled,
    bool? habitReminders,
    bool? dailyCheckIn,
    bool? wellbeingTips,
  }) {
    notificationsEnabled = enabled ?? notificationsEnabled;
    habitRemindersEnabled = habitReminders ?? habitRemindersEnabled;
    dailyCheckInEnabled = dailyCheckIn ?? dailyCheckInEnabled;
    wellbeingTipsEnabled = wellbeingTips ?? wellbeingTipsEnabled;
    notifyListeners();
  }

  /// Saves the current profile and preferences to Supabase.
  /// Throws if the save fails so screens can show an error.
  Future<void> save() async {
    await _saveReminderTimes();
    final client = Backend.client;
    final userId = Backend.userId;
    if (client == null || userId == null) return;
    await client.from('profiles').upsert(_toRow(userId));
    // Keep auth metadata in step so the name is right on other devices too.
    await client.auth.updateUser(
      UserAttributes(data: {'full_name': fullName, 'phone': phone}),
    );
  }

  Map<String, dynamic> _toRow(String userId) => {
    'id': userId,
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'language': selectedLanguage,
    'notifications_enabled': notificationsEnabled,
    'habit_reminders_enabled': habitRemindersEnabled,
    'daily_check_in_enabled': dailyCheckInEnabled,
    'wellbeing_tips_enabled': wellbeingTipsEnabled,
    'gentle_reminders_enabled': gentleRemindersEnabled,
  };
}
