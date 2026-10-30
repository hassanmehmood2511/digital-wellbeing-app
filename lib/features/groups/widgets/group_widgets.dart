import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/settings_widgets.dart';
import '../group.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, this.onTap});

  final BehtarGroup group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BehtarSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: BehtarColors.mint,
                    foregroundColor: BehtarColors.primary,
                    child: Icon(Icons.groups_rounded),
                  ),
                  const SizedBox(width: BehtarSpacing.md),
                  Expanded(
                    child: Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: BehtarColors.secondaryText,
                  ),
                ],
              ),
              const SizedBox(height: BehtarSpacing.md),
              Text(group.description),
              const SizedBox(height: BehtarSpacing.md),
              Wrap(
                spacing: BehtarSpacing.sm,
                runSpacing: BehtarSpacing.xs,
                children: [
                  GroupStatusTag(
                    icon: group.isPrivate
                        ? Icons.lock_outline_rounded
                        : Icons.public_rounded,
                    label: group.isPrivate ? 'Private' : 'Public',
                  ),
                  GroupStatusTag(
                    icon: Icons.people_outline_rounded,
                    label: '${group.members.length} members',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupStatusTag extends StatelessWidget {
  const GroupStatusTag({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BehtarColors.mint,
        border: Border.all(color: BehtarColors.border),
        borderRadius: BorderRadius.circular(BehtarRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BehtarSpacing.sm,
          vertical: BehtarSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: BehtarColors.primary),
            const SizedBox(width: BehtarSpacing.xs),
            Flexible(
              child: Text(
                label,
                softWrap: true,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: BehtarColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupStateCard extends StatelessWidget {
  const GroupStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: BehtarColors.mint,
            foregroundColor: BehtarColors.primary,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BehtarColors.primary,
                    ),
                  )
                : Icon(icon, size: 26),
          ),
          const SizedBox(height: BehtarSpacing.base),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: BehtarSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

class GroupInlineMessage extends StatelessWidget {
  const GroupInlineMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: BehtarColors.primary),
          const SizedBox(width: BehtarSpacing.sm),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class InviteError extends StatelessWidget {
  const InviteError({super.key, required this.result});

  final GroupInviteResult result;

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (result) {
      GroupInviteResult.invalidCode => (
        Icons.search_off_rounded,
        'That invite code was not found. Check it and try again.',
      ),
      GroupInviteResult.expiredCode => (
        Icons.event_busy_outlined,
        'This invite code has expired. Ask a group member for a new one.',
      ),
      GroupInviteResult.accessDenied => (
        Icons.lock_outline_rounded,
        'You don’t have access to this group with that invite.',
      ),
      _ => (Icons.info_outline_rounded, 'Unable to join this group.'),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BehtarColors.primary),
        const SizedBox(width: BehtarSpacing.sm),
        Expanded(child: Text(message)),
      ],
    );
  }
}
