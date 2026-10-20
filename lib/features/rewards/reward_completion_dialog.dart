import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

Future<void> showRewardSuccess(
  BuildContext context, {
  required String activityName,
  required int pointsEarned,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: BehtarColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BehtarRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          BehtarSpacing.xl,
          BehtarSpacing.xl,
          BehtarSpacing.xl,
          BehtarSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: BehtarColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: BehtarColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            Text(
              'A small win, well earned',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: BehtarSpacing.xs),
            Text(
              activityName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: BehtarSpacing.lg),
            Text(
              '+$pointsEarned',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: BehtarColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'POINTS EARNED',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Lovely'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
