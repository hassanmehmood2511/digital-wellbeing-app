import '../../models/app_usage.dart';

class MockUsageData {
  // This function returns a list of fake app usage data
  static List<AppUsage> getTrackedApps() {
    return [
      AppUsage(appName: 'Instagram', usageMinutes: 132, dailyLimitMinutes: 180),
      AppUsage(appName: 'TikTok', usageMinutes: 65, dailyLimitMinutes: 120),
      AppUsage(appName: 'YouTube', usageMinutes: 48, dailyLimitMinutes: 90),
      AppUsage(appName: 'WhatsApp', usageMinutes: 32, dailyLimitMinutes: 60),
      AppUsage(appName: 'Facebook', usageMinutes: 15, dailyLimitMinutes: 30),
    ];
  }
}