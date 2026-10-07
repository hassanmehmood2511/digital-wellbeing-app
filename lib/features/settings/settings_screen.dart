import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

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
                padding: EdgeInsets.symmetric(horizontal: BehtarSpacing.base),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }
}
