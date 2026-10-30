import 'package:flutter/material.dart';

import '../../settings/settings_widgets.dart';
import '../challenge.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/theme/app_theme.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
    this.onAction,
  });

  final Challenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = challenge.isComplete
        ? 'Completed'
        : challenge.isJoined
        ? 'Continue'
        : challenge.isCreator && challenge.isPrivate
        ? 'Start private challenge'
        : 'Join';
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: BehtarColors.mint,
                    foregroundColor: BehtarColors.primary,
                    child: Icon(Icons.emoji_events_outlined),
                  ),
                  const SizedBox(width: BehtarSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: BehtarSpacing.xs),
                        Text(
                          challenge.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BehtarSpacing.base),
              Wrap(
                spacing: BehtarSpacing.sm,
                runSpacing: BehtarSpacing.xs,
                children: [
                  ChallengeStatusTag(challenge: challenge),
                  ChallengeVisibilityTag(challenge: challenge),
                ],
              ),
              const SizedBox(height: BehtarSpacing.base),
              ChallengeMeta(icon: Icons.flag_outlined, label: challenge.goal),
              const SizedBox(height: BehtarSpacing.sm),
              ChallengeMeta(
                icon: Icons.calendar_month_outlined,
                label:
                    '${formatDate(challenge.startsOn)} – '
                    '${formatDate(challenge.endsOn)} · 7 days',
              ),
              const SizedBox(height: BehtarSpacing.md),
              Row(
                children: [
                  Expanded(child: ParticipationBadge(challenge: challenge)),
                  Text(
                    '${challenge.participantCount} people',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (challenge.isJoined) ...[
                const SizedBox(height: BehtarSpacing.md),
                OverallProgress(challenge: challenge),
                const SizedBox(height: BehtarSpacing.xs),
                Text(
                  '${(challenge.progress * 100).round()}% complete',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
              if (onAction != null) ...[
                const SizedBox(height: BehtarSpacing.md),
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ChallengeOverview extends StatelessWidget {
  const ChallengeOverview({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: const EdgeInsets.all(BehtarSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: BehtarSpacing.sm),
          Text(challenge.description),
          const SizedBox(height: BehtarSpacing.lg),
          ChallengeMeta(icon: Icons.flag_outlined, label: challenge.goal),
          const SizedBox(height: BehtarSpacing.sm),
          ChallengeMeta(
            icon: Icons.calendar_month_outlined,
            label:
                '${formatDate(challenge.startsOn)} – '
                '${formatDate(challenge.endsOn)} · 7 days',
          ),
          const SizedBox(height: BehtarSpacing.md),
          Wrap(
            spacing: BehtarSpacing.sm,
            runSpacing: BehtarSpacing.xs,
            children: [
              ChallengeStatusTag(challenge: challenge),
              ChallengeVisibilityTag(challenge: challenge),
            ],
          ),
        ],
      ),
    );
  }
}

class ChallengeStatusTag extends StatelessWidget {
  const ChallengeStatusTag({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final status = challenge.statusAt(DateTime.now());
    final label = switch (status) {
      ChallengeScheduleStatus.upcoming => 'Upcoming',
      ChallengeScheduleStatus.active => 'Active',
      ChallengeScheduleStatus.completed => 'Completed',
      ChallengeScheduleStatus.ended => 'Ended',
    };
    final icon = switch (status) {
      ChallengeScheduleStatus.upcoming => Icons.schedule_rounded,
      ChallengeScheduleStatus.active => Icons.play_circle_outline_rounded,
      ChallengeScheduleStatus.completed => Icons.check_circle_outline_rounded,
      ChallengeScheduleStatus.ended => Icons.event_busy_outlined,
    };
    return _ChallengeTag(icon: icon, label: label);
  }
}

class ChallengeVisibilityTag extends StatelessWidget {
  const ChallengeVisibilityTag({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return _ChallengeTag(
      icon: challenge.isPrivate
          ? Icons.lock_outline_rounded
          : Icons.public_rounded,
      label: challenge.isPrivate ? 'Private' : 'Public',
    );
  }
}

class _ChallengeTag extends StatelessWidget {
  const _ChallengeTag({required this.icon, required this.label});

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
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: BehtarColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChallengeMeta extends StatelessWidget {
  const ChallengeMeta({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: BehtarColors.primary),
        const SizedBox(width: BehtarSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class ParticipationBadge extends StatelessWidget {
  const ParticipationBadge({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final label = challenge.isComplete
        ? 'Completed'
        : challenge.isJoined
        ? 'You’re taking part'
        : challenge.isCreator
        ? 'Created by you'
        : 'Open to join';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          challenge.isComplete
              ? Icons.check_circle_outline_rounded
              : challenge.isJoined
              ? Icons.play_circle_outline_rounded
              : Icons.groups_outlined,
          size: 18,
          color: BehtarColors.primary,
        ),
        const SizedBox(width: BehtarSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: BehtarColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class OverallProgress extends StatelessWidget {
  const OverallProgress({super.key, required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BehtarRadii.pill),
      child: LinearProgressIndicator(
        value: challenge.progress,
        minHeight: 8,
        backgroundColor: BehtarColors.border,
        valueColor: const AlwaysStoppedAnimation<Color>(BehtarColors.secondary),
      ),
    );
  }
}

class DayProgressRow extends StatelessWidget {
  const DayProgressRow({
    super.key,
    required this.dayNumber,
    required this.date,
    required this.progress,
    required this.isEnabled,
    required this.onPressed,
  });

  final int dayNumber;
  final DateTime date;
  final double progress;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dayComplete = progress >= 1;
    final progressText = dayComplete
        ? 'Complete'
        : progress > 0
        ? 'Halfway'
        : 'Not started';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BehtarSpacing.base,
        vertical: BehtarSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: dayComplete
                ? BehtarColors.mint
                : BehtarColors.background,
            foregroundColor: BehtarColors.primary,
            child: dayComplete
                ? const Icon(Icons.check_rounded, size: 20)
                : Text('$dayNumber'),
          ),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayNumber',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${formatDate(date)} · $progressText',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isEnabled)
            TextButton(
              onPressed: onPressed,
              child: Text(progress > 0 ? 'Finish day' : 'Log progress'),
            )
          else if (progress == 0)
            const Icon(Icons.lock_outline_rounded, color: BehtarColors.sage)
          else
            Text(
              'Done',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: BehtarColors.primary),
            ),
        ],
      ),
    );
  }
}

class CompletionBanner extends StatelessWidget {
  const CompletionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: BehtarColors.mint,
            foregroundColor: BehtarColors.primary,
            child: Icon(Icons.celebration_rounded),
          ),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You did it!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: BehtarSpacing.xs),
                Text(
                  'Seven days of small steps add up to something meaningful.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeStateCard extends StatelessWidget {
  const ChallengeStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.showProgress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: BehtarColors.mint,
            foregroundColor: BehtarColors.primary,
            child: showProgress
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

class InlineError extends StatelessWidget {
  const InlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: BehtarColors.primary),
          const SizedBox(width: BehtarSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
