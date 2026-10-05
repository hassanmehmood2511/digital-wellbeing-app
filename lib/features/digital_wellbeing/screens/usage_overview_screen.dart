import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'tracked_apps_screen.dart';
import 'package:digital_wellbeing_app/data/mock/mock_usage_data.dart';
import 'usage_limits_screen.dart';

class UsageOverviewScreen extends StatelessWidget {
  const UsageOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Screen Time'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsageLimitsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Success Message Card
            _buildSuccessCard(),

            const SizedBox(height: 24),

            // 2. Selected Apps Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Selected Apps',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrackedAppsScreen()),
                    );
                  },
                  child: const Text(
                    'Manage',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 3. App Usage List (NOW USING MOCK DATA!)
            SizedBox(
              height: 320, // Fixed height so it doesn't conflict with SingleChildScrollView
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MockUsageData.getTrackedApps().length,
                itemBuilder: (context, index) {
                  final appData = MockUsageData.getTrackedApps()[index];

                  // Determine icon color based on app name
                  Color iconColor = AppColors.primary;
                  if (appData.appName == 'Instagram') iconColor = Colors.purple;
                  if (appData.appName == 'TikTok') iconColor = Colors.black;
                  if (appData.appName == 'YouTube') iconColor = Colors.red;
                  if (appData.appName == 'WhatsApp') iconColor = AppColors.success;

                  return _buildAppUsageItem(
                    appName: appData.appName,
                    usageMinutes: appData.usageMinutes,
                    limitMinutes: appData.dailyLimitMinutes,
                    iconColor: iconColor,
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // 4. Daily Usage Section
            const Text(
              'Daily Usage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),

            const SizedBox(height: 12),

            // 5. Simple Bar Chart (Last 7 Days)
            _buildDailyUsageChart(),

            const SizedBox(height: 24),

            // 6. Break Reminder
            _buildBreakReminder(),
          ],
        ),
      ),
    );
  }

  // Success Card Widget
  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're doing well!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your screen time is within your daily limit.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // App Usage Item Widget
  Widget _buildAppUsageItem({
    required String appName,
    required int usageMinutes,
    required int limitMinutes,
    required Color iconColor,
  }) {
    final percentage = usageMinutes / limitMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // App Icon Placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.apps,
              color: iconColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // App Name and Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),

                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage > 0.8 ? AppColors.warning : AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),

                const SizedBox(height: 4),

                // Usage Text
                Text(
                  '${_formatMinutes(usageMinutes)} / ${_formatMinutes(limitMinutes)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: AppColors.secondaryText),
        ],
      ),
    );
  }

  // Daily Usage Chart
  Widget _buildDailyUsageChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final usage = [3.5, 4.2, 2.8, 5.1, 3.9, 2.3, 2.5]; // hours

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              double hours = usage[index];

              return Column(
                children: [
                  SizedBox(
                    width: 30,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 24,
                          height: (hours / 6) * 60, // Scale height
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Break Reminder
  Widget _buildBreakReminder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.self_improvement,
            color: AppColors.primary,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Try a 10-minute break from social media.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Your future self will thank you!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Format minutes to hours and minutes
  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }
}