import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class DashboardProgressRing extends StatelessWidget {
  const DashboardProgressRing({
    super.key,
    required this.fraction,
    required this.label,
  });

  final double fraction;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: BehtarColors.primary,
              backgroundColor: BehtarColors.mint,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: BehtarColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('habits', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(BehtarRadii.control),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: BehtarSpacing.md),
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: BehtarSpacing.xs),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: BehtarSpacing.xs),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ),
            const SizedBox(height: BehtarSpacing.base),
            child,
          ],
        ),
      ),
    );
  }
}

class DashboardMiniStat extends StatelessWidget {
  const DashboardMiniStat({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BehtarColors.mint,
          borderRadius: BorderRadius.circular(BehtarRadii.control),
        ),
        child: Padding(
          padding: const EdgeInsets.all(BehtarSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: BehtarColors.primary, size: 18),
              const SizedBox(width: BehtarSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: BehtarColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardQuickActionTile extends StatelessWidget {
  const DashboardQuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BehtarRadii.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BehtarSpacing.sm),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: BehtarColors.mint,
                child: Icon(icon, color: BehtarColors.primary, size: 24),
              ),
              const SizedBox(height: BehtarSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: BehtarColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStateCard extends StatelessWidget {
  const DashboardStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onButton,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: BehtarColors.mint,
              child: Icon(icon, color: BehtarColors.primary, size: 28),
            ),
            const SizedBox(height: BehtarSpacing.base),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BehtarSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: BehtarSpacing.base),
            FilledButton(onPressed: onButton, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}

class DashboardLoadingCard extends StatelessWidget {
  const DashboardLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(BehtarSpacing.xl),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: BehtarSpacing.base),
              Text('Loading your dashboard...'),
            ],
          ),
        ),
      ),
    );
  }
}
