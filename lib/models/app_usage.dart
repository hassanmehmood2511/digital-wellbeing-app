class AppUsage {
  final String appName;
  int usageMinutes;
  int dailyLimitMinutes;
  bool isTracked; // Naya field: Track kar rahe hain ya nahi

  AppUsage({
    required this.appName,
    required this.usageMinutes,
    required this.dailyLimitMinutes,
    this.isTracked = true, // By default sab apps tracked honge
  });
}