import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';
import 'tracked_apps_screen.dart';
import 'usage_limits_screen.dart';

// StatefulWidget mein badla taake toggle button kaam kar sake
class SettingsMenuScreen extends StatefulWidget {
  const SettingsMenuScreen({super.key});

  @override
  State<SettingsMenuScreen> createState() => _SettingsMenuScreenState();
}

class _SettingsMenuScreenState extends State<SettingsMenuScreen> {
  // Toggle button ki state ko save karne ke liye variable
  bool _isGentleReminderOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Preferences', style: AppTypography.h3),
            const SizedBox(height: 16),

            _buildSettingsCard(
              context: context,
              icon: Icons.apps_outlined,
              title: 'Manage Tracked Apps',
              subtitle: 'Select which apps you want to monitor',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrackedAppsScreen()),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildSettingsCard(
              context: context,
              icon: Icons.timer_outlined,
              title: 'Set App Time Limits',
              subtitle: 'Increase or decrease daily usage limits',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UsageLimitsScreen()),
                );
              },
            ),

            const SizedBox(height: 32),

            Text('Notifications', style: AppTypography.h3),
            const SizedBox(height: 16),

            // Gentle Reminders Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gentle Reminders',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Get notified when you reach 80% of your limit',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // ✅ FIX: Toggle Button ab functional hai
                  Switch(
                    value: _isGentleReminderOn,
                    activeColor: AppColors.primary,      // Thumb color (ON)
                    activeTrackColor: AppColors.sage,    // Track color (ON)
                    inactiveThumbColor: AppColors.sage,  // Thumb color (OFF)
                    inactiveTrackColor: AppColors.border,// Track color (OFF)
                    onChanged: (bool value) {
                      setState(() {
                        _isGentleReminderOn = value; // State update karega
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Settings Card Widget
  Widget _buildSettingsCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.sage, size: 20),
          ],
        ),
      ),
    );
  }
}