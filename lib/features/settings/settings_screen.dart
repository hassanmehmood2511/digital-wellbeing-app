import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'account_settings_screen.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SettingsPage(
          title: 'Settings',
          children: [
            Text(
              'Make Behtar feel like yours.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: BehtarColors.secondaryText,
                  ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            SettingsCard(
              padding: const EdgeInsets.all(BehtarSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: BehtarColors.primarySoft,
                    foregroundColor: BehtarColors.primaryDark,
                    child: Text(
                      _initials(controller.fullName),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: BehtarColors.primaryDark,
                          ),
                    ),
                  ),
                  const SizedBox(width: BehtarSpacing.base),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: BehtarSpacing.xs),
                        Text(
                          controller.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.xl),
            const SettingsSectionTitle('Your preferences'),
            _SettingsGroup(
              tiles: [
                SettingsActionTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Profile settings',
                  subtitle: 'Update your personal details',
                  onTap: () => _open(context, ProfileSettingsScreen(
                    controller: controller,
                  )),
                ),
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
            const SizedBox(height: BehtarSpacing.xl),
            const SettingsSectionTitle('Account'),
            _SettingsGroup(
              tiles: [
                SettingsActionTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Account settings',
                  subtitle: 'Sign out, privacy and account options',
                  onTap: () => _open(context, AccountSettingsScreen(
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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'B';
    return parts.length == 1
        ? parts.first.substring(0, 1).toUpperCase()
        : '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
            .toUpperCase();
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
