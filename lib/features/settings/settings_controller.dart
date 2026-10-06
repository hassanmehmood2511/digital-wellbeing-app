import 'package:flutter/foundation.dart';

class SettingsController extends ChangeNotifier {
  String fullName = 'Hassan Mehmood';
  String email = 'hassanmehmood@example.com';
  String phone = '+92 300 1234567';
  String selectedLanguage = 'English';

  bool notificationsEnabled = true;
  bool habitRemindersEnabled = true;
  bool dailyCheckInEnabled = true;
  bool wellbeingTipsEnabled = false;

  void updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) {
    this.fullName = fullName;
    this.email = email;
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

  Future<void> saveMockChanges() {
    return Future<void>.delayed(const Duration(milliseconds: 450));
  }
}
