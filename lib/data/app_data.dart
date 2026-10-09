import '../models/app_usage.dart';

class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  List<AppUsage> apps = [
    AppUsage(appName: 'Instagram', usageMinutes: 132, dailyLimitMinutes: 180),
    AppUsage(appName: 'TikTok', usageMinutes: 65, dailyLimitMinutes: 120),
    AppUsage(appName: 'YouTube', usageMinutes: 48, dailyLimitMinutes: 90),
    AppUsage(appName: 'WhatsApp', usageMinutes: 32, dailyLimitMinutes: 60),
    AppUsage(appName: 'Facebook', usageMinutes: 15, dailyLimitMinutes: 30, isTracked: false),
    AppUsage(appName: 'Twitter / X', usageMinutes: 10, dailyLimitMinutes: 20, isTracked: false),
    AppUsage(appName: 'Snapchat', usageMinutes: 5, dailyLimitMinutes: 15, isTracked: false),
  ];

  // Limit update karne ka function
  void updateLimit(String appName, int newLimit) {
    int index = apps.indexWhere((a) => a.appName == appName);
    if (index != -1) {
      apps[index].dailyLimitMinutes = newLimit;
    }
  }

  // NAYA FUNCTION: Tracking ON/OFF karne ke liye
  void toggleTracking(String appName) {
    int index = apps.indexWhere((a) => a.appName == appName);
    if (index != -1) {
      apps[index].isTracked = !apps[index].isTracked;
    }
  }

  // NAYA FUNCTION: Naya App Add karne ke liye
  void addNewApp(String appName) {
    // Check karein ke app pehle se mojood toh nahi
    bool exists = apps.any((a) => a.appName.toLowerCase() == appName.toLowerCase());
    if (!exists && appName.trim().isNotEmpty) {
      apps.add(AppUsage(
        appName: appName.trim(),
        usageMinutes: 0,
        dailyLimitMinutes: 60, // Default 1 hour limit
        isTracked: true,
      ));
    }
  }

  List<int> getWeeklyUsage() {
    int todayTotal = apps.where((app) => app.isTracked).fold(0, (sum, app) => sum + app.usageMinutes);
    if (todayTotal == 0) return [0, 0, 0, 0, 0, 0, 0];
    return [
      (todayTotal * 0.9).round(), (todayTotal * 1.1).round(), (todayTotal * 0.8).round(),
      (todayTotal * 1.2).round(), (todayTotal * 1.0).round(), (todayTotal * 0.7).round(), todayTotal,
    ];
  }
}