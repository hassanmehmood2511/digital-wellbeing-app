import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.title,
    required this.children,
    super.key,
    this.actions,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            BehtarSpacing.base,
            BehtarSpacing.md,
            BehtarSpacing.base,
            BehtarSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: BehtarSpacing.xs,
        bottom: BehtarSpacing.md,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BehtarColors.surface,
      elevation: 1,
      shadowColor: BehtarColors.primaryText.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BehtarRadii.card),
        side: const BorderSide(color: BehtarColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(BehtarSpacing.base),
        child: child,
      ),
    );
  }
}

class SettingsActionTile extends StatelessWidget {
  const SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BehtarSpacing.base,
        vertical: BehtarSpacing.xs,
      ),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: BehtarColors.mint,
        foregroundColor: BehtarColors.primary,
        child: Icon(icon, size: 21),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: BehtarSpacing.xs),
        child: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: BehtarColors.secondaryText,
      ),
      onTap: onTap,
    );
  }
}

class SettingsSaveButton extends StatelessWidget {
  const SettingsSaveButton({
    required this.isSaving,
    required this.onPressed,
    super.key,
  });

  final bool isSaving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSaving ? null : onPressed,
      child: isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: BehtarColors.surface,
              ),
            )
          : const Text('Save changes'),
    );
  }
}

void showSettingsMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
