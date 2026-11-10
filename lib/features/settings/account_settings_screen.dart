import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import 'settings_controller.dart';
import 'settings_widgets.dart';
import '../../core/backend/backend.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Account settings',
      children: [
        Text(
          'Manage your Behtar account.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: BehtarColors.secondaryText),
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(BehtarSpacing.base),
                leading: const CircleAvatar(
                  backgroundColor: BehtarColors.mint,
                  foregroundColor: BehtarColors.primary,
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
                  backgroundColor: BehtarColors.mint,
                  foregroundColor: BehtarColors.primary,
                  child: Icon(Icons.privacy_tip_outlined),
                ),
                title: Text(
                  'Privacy & data',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Text('Your data is stored securely in your account'),
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
                  foregroundColor: BehtarColors.primary,
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
                  foregroundColor: BehtarColors.primaryText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: BehtarSpacing.md),
        Center(
          child: Text(
            'Deleting your account permanently removes all your Behtar data.',
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
          'You will need to log in again to use Behtar on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        // The app listens for sign-out and returns to the login screen.
        await Backend.client?.auth.signOut();
      } catch (error) {
        if (context.mounted) {
          showSettingsMessage(context, friendlyErrorMessage(error));
        }
      }
    }
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: BehtarColors.primary,
        ),
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, habits, challenges, '
          'groups you created and points. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep account'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BehtarColors.primary,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final client = Backend.client;
      if (client == null) return;
      try {
        await client.rpc('delete_my_account');
        // The account no longer exists on the server, so only clear the
        // local session; the app then returns to the login screen.
        try {
          await client.auth.signOut(scope: SignOutScope.local);
        } catch (_) {}
      } catch (error) {
        if (context.mounted) {
          showSettingsMessage(context, friendlyErrorMessage(error));
        }
      }
    }
  }
}
