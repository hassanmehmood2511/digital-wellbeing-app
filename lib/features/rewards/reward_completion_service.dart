import 'package:flutter/material.dart';

import '../challenges/challenge.dart';
import 'reward_completion_dialog.dart';
import 'rewards_store.dart';

Future<void> awardHabitCompletion(
  BuildContext context, {
  required String habitId,
  required String habitName,
}) async {
  await _awardAndCelebrate(
    context,
    id: 'habit:$habitId',
    activityName: habitName,
    points: RewardConfig.habitCompletionPoints,
    type: RewardType.habit,
  );
}

Future<void> awardChallengeCompletion(
  BuildContext context, {
  required Challenge challenge,
}) async {
  await _awardAndCelebrate(
    context,
    id: 'challenge:${challenge.id}',
    activityName: challenge.title,
    points: RewardConfig.challengeCompletionBonus,
    type: RewardType.challenge,
  );
}

Future<void> _awardAndCelebrate(
  BuildContext context, {
  required String id,
  required String activityName,
  required int points,
  required RewardType type,
}) async {
  try {
    final awarded = await PointsStore.instance.award(
      id: id,
      activityName: activityName,
      points: points,
      type: type,
    );
    if (awarded > 0 && context.mounted) {
      await showRewardSuccess(
        context,
        activityName: activityName,
        pointsEarned: awarded,
      );
    }
  } on Exception {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Your activity is complete, but the reward could not be saved.',
            ),
          ),
        );
    }
  }
}
