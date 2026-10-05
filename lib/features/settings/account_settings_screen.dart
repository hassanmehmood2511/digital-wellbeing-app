import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Account settings',
      children: [
        Text(
          'Manage how you use Behtar on this device.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: BehtarColors.secondaryText,
              ),
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(BehtarSpacing.base),
                leading: const CircleAvatar(
                  backgroundColor: BehtarColors.primarySoft,
                  foregroundColor: BehtarColors.primaryDark,
                  child: Icon(Icons.alternate_email_rounded),
                ),
                title: Text(
                  'Email address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(controller.email),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: BehtarSpacing.base),
                child: Divider(height: 1),
              ),
              ListTile(
                contentPadding: const EdgeInsets.all(BehtarSpacing.base),
                leading: const CircleAvatar(
                  backgroundColor: BehtarColors.primarySoft,
                  foregroundColor: BehtarColors.primaryDark,
                  child: Icon(Icons.privacy_tip_outlined),
                ),
                title: Text(
                  'Privacy & data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text('Your settings are stored locally'),
              ),
            ],
          ),
        ),
        const SizedBox(height: BehtarSpacing.xl),
        const SettingsSectionTitle('Account actions'),
        SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: BehtarColors.primaryDark,
                  side: const BorderSide(color: BehtarColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BehtarRadii.control),
                  ),
                ),
              ),
              const SizedBox(height: BehtarSpacing.md),
              TextButton.icon(
                onPressed: () => _confirmDeletion(context),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete account'),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: BehtarColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BehtarSpacing.md),
        Center(
          child: Text(
            'These actions are demonstrations only. No account data is changed.',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: BehtarColors.primary),
        title: const Text('Sign out?'),
        content: const Text(
          'This is a demo action. You will stay in the app and no account '
          'session will be changed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      showSettingsMessage(context, 'Demo sign-out complete. No session changed.');
    }
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: BehtarColors.error),
        title: const Text('Delete account?'),
        content: const Text(
          'Account deletion cannot be undone. This demo will not delete your '
          'account or remove any data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep account'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BehtarColors.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm demo action'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      showSettingsMessage(
        context,
        'Demo confirmation complete. No account or data was deleted.',
      );
    }
  }
}
