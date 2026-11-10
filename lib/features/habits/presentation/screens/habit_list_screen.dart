import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/habit_store.dart';
import '../../../rewards/reward_completion_service.dart';
import '../widgets/habit_card.dart';
import 'add_habit_screen.dart';
import 'habit_details_screen.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: AppSpacing.elevationNone,
        titleSpacing: AppSpacing.base,

        title: Text('My Habits', style: AppTypography.h1),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: IconButton(
              tooltip: 'Add habit',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 24),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Build better days, one habit at a time.',
              style: AppTypography.small,
            ),

            const SizedBox(height: AppSpacing.lg),

            Expanded(
              child: ListenableBuilder(
                listenable: HabitStore.instance,

                builder: (context, child) {
                  final store = HabitStore.instance;
                  final habits = store.habits;

                  if (habits.isEmpty && store.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (habits.isEmpty && store.loadError != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            store.loadError!,
                            textAlign: TextAlign.center,
                            style: AppTypography.body,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: store.load,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (habits.isEmpty) {
                    return Center(
                      child: Text(
                        'No habits yet.\nCreate your first habit!',
                        textAlign: TextAlign.center,
                        style: AppTypography.body,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),

                    itemCount: habits.length,

                    separatorBuilder: (context, index) {
                      return const SizedBox(height: AppSpacing.md);
                    },

                    itemBuilder: (context, index) {
                      final habit = habits[index];

                      return HabitCard(
                        habit: habit,

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HabitDetailsScreen(habit: habit),
                            ),
                          );
                        },

                        onComplete: () async {
                          final completed = HabitStore.instance.completeHabit(
                            habit.habitId,
                          );
                          if (completed != null) {
                            await awardHabitCompletion(
                              context,
                              habitId: completed.habitId,
                              habitName: completed.title,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
