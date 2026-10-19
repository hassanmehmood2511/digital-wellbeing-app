import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';
// Digital Wellbeing screens ko import kar rahe hain
import 'package:digital_wellbeing_app/features/digital_wellbeing/screens/tracked_apps_screen.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/screens/usage_limits_screen.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SettingsPage(
          title: 'App settings',
          children: [
            Text(
              'Make Behtar work the way you like.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: BehtarColors.secondaryText,
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),

            // --- NAYA SECTION: App Preferences ---
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: BehtarColors.primaryText,
              ),
            ),
            const SizedBox(height: BehtarSpacing.base),

            _SettingsGroup(
              tiles: [
                SettingsActionTile(
                  icon: Icons.apps_outlined,
                  title: 'Manage Tracked Apps',
                  subtitle: 'Select which apps you want to monitor',
                  onTap: () => _open(context, const TrackedAppsScreen()),
                ),
                SettingsActionTile(
                  icon: Icons.timer_outlined,
                  title: 'Set App Time Limits',
                  subtitle: 'Increase or decrease daily usage limits',
                  onTap: () => _open(context, const UsageLimitsScreen()),
                ),
              ],
            ),

            const SizedBox(height: BehtarSpacing.lg),
            // -------------------------------------

            // Purana Preferences Section
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: BehtarColors.primaryText,
              ),
            ),
            const SizedBox(height: BehtarSpacing.base),

            _SettingsGroup(
              tiles: [
                SettingsActionTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: controller.selectedLanguage,
                  onTap: () => _open(context, LanguageSettingsScreen(
                    controller: controller,
                  )),
                ),
                SettingsActionTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: controller.notificationsEnabled
                      ? 'Reminders are on'
                      : 'Quiet mode is on',
                  onTap: () => _open(context, NotificationSettingsScreen(
                    controller: controller,
                  )),
                ),
              ],
            ),
            const SizedBox(height: BehtarSpacing.lg),
            Center(
              child: Text(
                'Behtar · Small steps, better days',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        );
      },
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < tiles.length; index++) ...[
            tiles[index],
            if (index < tiles.length - 1)
              const Padding(
                padding:
                EdgeInsets.symmetric(horizontal: BehtarSpacing.base),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }
}