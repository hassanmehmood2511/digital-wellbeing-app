import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';
import 'package:digital_wellbeing_app/data/mock/mock_usage_data.dart';

class UsageLimitsScreen extends StatefulWidget {
  const UsageLimitsScreen({super.key});

  @override
  State<UsageLimitsScreen> createState() => _UsageLimitsScreenState();
}

class _UsageLimitsScreenState extends State<UsageLimitsScreen> {
  // This variable keeps track of the switch state
  bool _warningEnabled = true;

  @override
  Widget build(BuildContext context) {
    final apps = MockUsageData.getTrackedApps();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Usage Limits'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Warning Settings Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              title: const Text(
                'Gentle Reminders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Text(
                'Warn me when I reach 80% of my daily limit',
                style: AppTypography.body,
              ),
              value: _warningEnabled,
              activeColor: AppColors.warning, // Amber color for warnings
              onChanged: (bool value) {
                // This updates the UI when the switch is toggled
                setState(() {
                  _warningEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // 2. App Limits Header
          const Text(
            'App Time Limits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: 12),

          // 3. List of App Limits
          ...apps.map((app) => _buildAppLimitCard(app)),
        ],
      ),
    );
  }

  // Widget for each app limit row
  Widget _buildAppLimitCard(app) {
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
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.apps, color: AppColors.primary, size: 24),
          ),

          const SizedBox(width: 12),

          // App Name and Limit Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  'Limit: ${_formatMinutes(app.dailyLimitMinutes)} / day',
                  style: AppTypography.label,
                ),
              ],
            ),
          ),

          // Change Button
          TextButton(
            onPressed: () {
              // Mock action for changing the limit
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Edit limit for ${app.appName}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Change',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to format minutes
  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}