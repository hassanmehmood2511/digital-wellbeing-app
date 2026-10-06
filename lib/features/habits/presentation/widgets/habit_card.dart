import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/habit_model.dart';

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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(43, 43, 43, 0.08),
                blurRadius: 4,
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
                  color: AppColors.primarySoft,
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
                    Text(
                      habit.title,
                      style: AppTextStyles.h3.copyWith(color: AppColors.text),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    Text(
                      habit.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.muted,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Row(
                      children: [
                        Text(
                          '${habit.completedCount}/${habit.targetCount} today',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.muted,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: habit.progress,
                              minHeight: 7,
                              backgroundColor: AppColors.primarySoft,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
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
                      ? AppColors.success
                      : AppColors.primary,
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
