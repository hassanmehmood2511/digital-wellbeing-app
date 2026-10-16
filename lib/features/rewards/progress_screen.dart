import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import 'rewards_store.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: PointsStore.instance,
          builder: (context, _) {
            final store = PointsStore.instance;
            final recent = store.transactions.take(4).toList();
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                BehtarSpacing.base,
                BehtarSpacing.sm,
                BehtarSpacing.base,
                BehtarSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Every good choice adds up.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: BehtarSpacing.lg),
                  _PointsHero(
                    balance: store.balance,
                    lifetimeEarned: store.lifetimeEarned,
                  ),
                  const SizedBox(height: BehtarSpacing.xl),
                  const _SectionHeading(
                    title: 'Milestones',
                    subtitle: 'Little reminders of how far you’ve come.',
                  ),
                  const SizedBox(height: BehtarSpacing.md),
                  _MilestoneGrid(points: store.lifetimeEarned),
                  const SizedBox(height: BehtarSpacing.xl),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionHeading(
                          title: 'Recent activity',
                          subtitle: 'Your latest moments of progress.',
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => const RewardHistoryScreen(),
                          ),
                        ),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: BehtarSpacing.md),
                  if (recent.isEmpty)
                    const _EmptyHistoryCard()
                  else
                    _HistoryCard(transactions: recent),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class RewardHistoryScreen extends StatelessWidget {
  const RewardHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Points history')),
      body: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: PointsStore.instance,
          builder: (context, _) {
            final transactions = PointsStore.instance.transactions;
            if (transactions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(BehtarSpacing.base),
                child: _EmptyHistoryCard(),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                BehtarSpacing.base,
                BehtarSpacing.md,
                BehtarSpacing.base,
                BehtarSpacing.xl,
              ),
              itemCount: transactions.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: BehtarSpacing.sm),
              itemBuilder: (context, index) => _TransactionTile(
                transaction: transactions[index],
                showDate: true,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PointsHero extends StatelessWidget {
  const _PointsHero({required this.balance, required this.lifetimeEarned});

  final int balance;
  final int lifetimeEarned;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BehtarSpacing.lg),
      decoration: BoxDecoration(
        color: BehtarColors.primaryText,
        borderRadius: BorderRadius.circular(BehtarRadii.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.spa_rounded,
                color: BehtarColors.sage,
                size: 21,
              ),
              const SizedBox(width: BehtarSpacing.sm),
              Text(
                'YOUR REWARDS',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: BehtarColors.sage,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: BehtarSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$balance',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: BehtarColors.surface,
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'points to celebrate',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BehtarColors.surface.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: BehtarColors.surface.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: BehtarColors.sage,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: BehtarSpacing.lg),
          Divider(color: BehtarColors.surface.withValues(alpha: 0.18)),
          const SizedBox(height: BehtarSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lifetime points earned',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BehtarColors.surface.withValues(alpha: 0.82),
                ),
              ),
              Text(
                '$lifetimeEarned',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: BehtarColors.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: BehtarSpacing.xs),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MilestoneGrid extends StatelessWidget {
  const _MilestoneGrid({required this.points});

  final int points;

  static const _milestones = [
    (title: 'First steps', points: 50, icon: Icons.spa_outlined),
    (title: 'Finding rhythm', points: 150, icon: Icons.self_improvement),
    (title: 'Growing strong', points: 300, icon: Icons.local_florist_outlined),
    (title: 'In full bloom', points: 500, icon: Icons.park_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - BehtarSpacing.sm) / 2;
        return Wrap(
          spacing: BehtarSpacing.sm,
          runSpacing: BehtarSpacing.sm,
          children: [
            for (final milestone in _milestones)
              SizedBox(
                width: itemWidth,
                child: _MilestoneCard(
                  title: milestone.title,
                  points: milestone.points,
                  currentPoints: points,
                  icon: milestone.icon,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard({
    required this.title,
    required this.points,
    required this.currentPoints,
    required this.icon,
  });

  final String title;
  final int points;
  final int currentPoints;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final unlocked = currentPoints >= points;
    return Container(
      padding: const EdgeInsets.all(BehtarSpacing.md),
      decoration: BoxDecoration(
        color: unlocked ? BehtarColors.surface : BehtarColors.background,
        borderRadius: BorderRadius.circular(BehtarRadii.control),
        border: Border.all(color: BehtarColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            unlocked ? icon : Icons.lock_outline_rounded,
            color: unlocked
                ? BehtarColors.primary
                : BehtarColors.secondaryText,
            size: 22,
          ),
          const SizedBox(height: BehtarSpacing.md),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(
            unlocked ? 'Unlocked' : '$points points',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.transactions});

  final List<RewardTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BehtarColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BehtarRadii.card),
        side: const BorderSide(color: BehtarColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            _TransactionTile(transaction: transactions[index]),
            if (index < transactions.length - 1)
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    this.showDate = false,
  });

  final RewardTransaction transaction;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final isChallenge = transaction.type == RewardType.challenge;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: BehtarSpacing.base,
        vertical: BehtarSpacing.xs,
      ),
      leading: CircleAvatar(
        backgroundColor: BehtarColors.mint,
        foregroundColor: BehtarColors.primary,
        child: Icon(
          isChallenge ? Icons.emoji_events_outlined : Icons.check_rounded,
          size: 21,
        ),
      ),
      title: Text(
        transaction.activityName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        showDate
            ? DateFormat('MMM d, yyyy · h:mm a').format(transaction.earnedAt)
            : isChallenge
            ? 'Challenge completed'
            : 'Habit completed',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: Text(
        '+${transaction.points}',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: BehtarColors.primary,
        ),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  const _EmptyHistoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BehtarSpacing.lg),
      decoration: BoxDecoration(
        color: BehtarColors.surface,
        borderRadius: BorderRadius.circular(BehtarRadii.card),
        border: Border.all(color: BehtarColors.border),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: BehtarColors.mint,
            foregroundColor: BehtarColors.primary,
            child: Icon(Icons.spa_outlined),
          ),
          const SizedBox(height: BehtarSpacing.md),
          Text(
            'Your story starts here',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(
            'Complete a habit or challenge to earn your first points.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
