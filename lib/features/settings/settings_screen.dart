import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';
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
                  onTap: () => _open(
                    context,
                    LanguageSettingsScreen(controller: controller),
                  ),
                ),
                SettingsActionTile(
                  icon: Icons.timer_outlined,
                  title: 'App Time / Usage Limit Settings',
                  subtitle: 'Set daily app limits and warning thresholds',
                  onTap: () => _open(context, const UsageLimitsScreen()),
                ),
                SettingsActionTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: controller.notificationsEnabled
                      ? 'Reminders are on'
                      : 'Quiet mode is on',
                  onTap: () => _open(
                    context,
                    NotificationSettingsScreen(controller: controller),
                  ),
                ),
                SettingsSwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Gentle Reminders',
                  subtitle: controller.gentleRemindersEnabled
                      ? 'Alert when reaching 80% of daily limit'
                      : 'Reminders disabled',
                  value: controller.gentleRemindersEnabled,
                  onChanged: (bool value) =>
                      controller.updateGentleReminders(value),
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
