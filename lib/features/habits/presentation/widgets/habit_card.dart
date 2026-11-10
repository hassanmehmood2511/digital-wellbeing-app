import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/habit_model.dart';
import '../../../../core/widgets/behtar_progress_bar.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(27, 67, 50, 0.08),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Habit icon
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Text(habit.icon, style: const TextStyle(fontSize: 26)),
              ),

              const SizedBox(width: AppSpacing.md),

              // Habit information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title, style: AppTypography.h3),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      habit.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.small,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${habit.completedCount}/${habit.targetCount} today',
                            style: AppTypography.small,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: BehtarProgressBar(value: habit.progress),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Completion button
              IconButton(
                onPressed: onComplete,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  habit.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: habit.isCompleted
                      ? AppColors.primary
                      : AppColors.secondary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
