import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'group.dart';

class GroupLeaderboard extends StatelessWidget {
  const GroupLeaderboard({required this.members, super.key});

  final List<GroupMember> members;

  @override
  Widget build(BuildContext context) {
    final ranked = [...members]
      ..sort((a, b) {
        final scoreOrder = b.points.compareTo(a.points);
        return scoreOrder != 0 ? scoreOrder : a.name.compareTo(b.name);
      });
    final pointsFrequency = <int, int>{};
    for (final member in ranked) {
      pointsFrequency.update(
        member.points,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    if (ranked.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(BehtarSpacing.lg),
        child: Column(
          children: [
            const Icon(
              Icons.leaderboard_outlined,
              color: BehtarColors.sage,
              size: 32,
            ),
            const SizedBox(height: BehtarSpacing.sm),
            Text(
              'No progress points yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: BehtarSpacing.xs),
            const Text(
              'Member progress will appear here as the group gets started.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < ranked.length; index++) ...[
          _LeaderboardMemberRow(
            member: ranked[index],
            rank: ranked.indexWhere(
                  (candidate) => candidate.points == ranked[index].points,
                ) +
                1,
            isTied: pointsFrequency[ranked[index].points]! > 1,
          ),
          if (index < ranked.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: BehtarSpacing.base),
              child: Divider(height: 1),
            ),
        ],
      ],
    );
  }
}

class _LeaderboardMemberRow extends StatelessWidget {
  const _LeaderboardMemberRow({
    required this.member,
    required this.rank,
    required this.isTied,
  });

  final GroupMember member;
  final int rank;
  final bool isTied;

  @override
  Widget build(BuildContext context) {
    final initials = member.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      color: member.isCurrentUser ? BehtarColors.mint : BehtarColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: BehtarSpacing.base,
        vertical: BehtarSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: BehtarColors.primary,
              ),
            ),
          ),
          const SizedBox(width: BehtarSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundColor: member.isCurrentUser
                ? BehtarColors.surface
                : BehtarColors.background,
            foregroundColor: BehtarColors.primary,
            child: Text(initials.isEmpty ? '?' : initials),
          ),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.isCurrentUser ? '${member.name} (You)' : member.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isTied)
                  Text(
                    'Tied rank',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          Text(
            '${member.points} pts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: BehtarColors.primary,
            ),
          ),
        ],
      ),
    );
  }

}
