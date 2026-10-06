import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/habit_store.dart';
import '../../models/habit_model.dart';

class HabitDetailsScreen extends StatelessWidget {
  final HabitModel habit;

  const HabitDetailsScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        titleSpacing: AppSpacing.base,

        title: Text(
          'Habit Details',
          style: AppTextStyles.h1.copyWith(color: AppColors.text),
        ),
      ),

      body: ListenableBuilder(
        listenable: HabitStore.instance,

        builder: (context, child) {
          final habits = HabitStore.instance.habits;

          final index = habits.indexWhere(
            (item) => item.habitId == habit.habitId,
          );

          if (index == -1) {
            return Center(
              child: Text(
                'Habit not found.',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
            );
          }

          final currentHabit = habits[index];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.base),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HabitHeader(habit: currentHabit),

                const SizedBox(height: AppSpacing.lg),

                _ProgressSection(habit: currentHabit),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Habit Information',
                  style: AppTextStyles.h2.copyWith(color: AppColors.text),
                ),

                const SizedBox(height: AppSpacing.md),

                _InfoCard(
                  icon: Icons.category_outlined,
                  title: 'Category',
                  value: currentHabit.category,
                ),

                const SizedBox(height: AppSpacing.sm),

                _InfoCard(
                  icon: Icons.repeat,
                  title: 'Frequency',
                  value: currentHabit.frequency,
                ),

                const SizedBox(height: AppSpacing.sm),

                _InfoCard(
                  icon: Icons.flag_outlined,
                  title: 'Target',
                  value: '${currentHabit.targetCount} times',
                ),

                const SizedBox(height: AppSpacing.sm),

                _InfoCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Current Streak',
                  value: '${currentHabit.currentStreak} days',
                ),

                const SizedBox(height: AppSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: currentHabit.isCompleted
                        ? null
                        : () {
                            HabitStore.instance.completeHabit(
                              currentHabit.habitId,
                            );
                          },
                    icon: Icon(
                      currentHabit.isCompleted
                          ? Icons.check_circle_outline
                          : Icons.check,
                    ),
                    label: Text(
                      currentHabit.isCompleted
                          ? 'Completed'
                          : 'Mark as Complete',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.surface,
                      disabledBackgroundColor: AppColors.primarySoft,
                      disabledForegroundColor: AppColors.primaryDark,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteDialog(context, currentHabit);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Habit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, HabitModel habit) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,

          title: Text(
            'Delete Habit?',
            style: AppTextStyles.h2.copyWith(color: AppColors.text),
          ),

          content: Text(
            'Are you sure you want to delete "${habit.title}"?',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),

            TextButton(
              onPressed: () {
                HabitStore.instance.deleteHabit(habit.habitId);

                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}

class _HabitHeader extends StatelessWidget {
  final HabitModel habit;

  const _HabitHeader({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,

            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),

            child: Center(
              child: Text(habit.icon, style: const TextStyle(fontSize: 28)),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            habit.title,
            style: AppTextStyles.h1.copyWith(color: AppColors.text),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            habit.description,
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final HabitModel habit;

  const _ProgressSection({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),

      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTextStyles.h2.copyWith(color: AppColors.text),
              ),

              Text(
                '${habit.completedCount}/${habit.targetCount}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: habit.progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            '${(habit.progress * 100).round()}% completed',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: AppColors.primaryDark, size: 22),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.muted,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: AppTextStyles.body.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
