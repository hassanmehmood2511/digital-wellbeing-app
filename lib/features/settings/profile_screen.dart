import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'account_settings_screen.dart';
import 'profile_settings_screen.dart';
import 'settings_controller.dart';
import 'settings_screen.dart';
import 'settings_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SettingsPage(
          title: 'Profile',
          actions: [
            IconButton(
              tooltip: 'App settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => _open(
                context,
                AppSettingsScreen(controller: controller),
              ),
            ),
            const SizedBox(width: BehtarSpacing.xs),
          ],
          children: [
            SettingsCard(
              padding: const EdgeInsets.all(BehtarSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: BehtarColors.mint,
                    foregroundColor: BehtarColors.primary,
                    child: Text(
                      _initials(controller.fullName),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: BehtarColors.primary,
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
                        const SizedBox(height: BehtarSpacing.xs),
                        Text(
                          controller.phone,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.xl),
            const SettingsSectionTitle('Your account'),
            SettingsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SettingsActionTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile details',
                    subtitle: 'Edit your name and phone',
                    onTap: () => _open(
                      context,
                      ProfileSettingsScreen(controller: controller),
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: BehtarSpacing.base),
                    child: Divider(height: 1),
                  ),
                  SettingsActionTile(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Account settings',
                    subtitle: 'Sign out, privacy and account options',
                    onTap: () => _open(
                      context,
                      AccountSettingsScreen(controller: controller),
                    ),
                  ),
                ],
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
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}
