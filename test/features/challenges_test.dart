import 'package:digital_wellbeing_app/features/challenges/challenges_controller.dart';
import 'package:digital_wellbeing_app/features/challenges/challenge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ChallengesController controller;

  setUp(() {
    controller = ChallengesController();
  });

  tearDown(() {
    controller.dispose();
  });

  test('joining, daily progress and leaving update local challenge state', () {
    final challenge = controller.challenges.firstWhere(
      (item) => item.id == 'daily-hydration',
    );
    expect(challenge.isJoined, isFalse);

    controller.join(challenge.id);
    expect(controller.challengeById(challenge.id)!.isJoined, isTrue);

    controller.addDailyProgress(challenge.id, 0);
    expect(controller.challengeById(challenge.id)!.dailyProgress[0], 0.5);
    controller.addDailyProgress(challenge.id, 0);
    expect(controller.challengeById(challenge.id)!.dailyProgress[0], 1);

    controller.leave(challenge.id);
    final updated = controller.challengeById(challenge.id)!;
    expect(updated.isJoined, isFalse);
    expect(updated.dailyProgress[0], 1);
  });

  test('seven completed days produce a complete challenge', () {
    var today = DateTime(2026, 10, 8);
    final completionController = ChallengesController(clock: () => today);
    final challenge = completionController.challenges.first;
    for (var day = 0; day < 7; day++) {
      today = challenge.startsOn.add(Duration(days: day));
      completionController.addDailyProgress(challenge.id, day);
      completionController.addDailyProgress(challenge.id, day);
    }

    final updated = completionController.challengeById(challenge.id)!;
    expect(updated.completedDays, 7);
    expect(updated.progress, 1);
    expect(updated.isComplete, isTrue);
    expect(updated.endsOn.difference(updated.startsOn).inDays, 6);
    completionController.dispose();
  });

  test('new challenges are validated and inserted locally', () {
    expect(
      () => controller.createChallenge(
        title: ' ',
        description: 'A useful description',
        goal: 'Read for 15 minutes',
      ),
      throwsArgumentError,
    );

    final challenge = controller.createChallenge(
      title: 'A calmer evening',
      description: 'Make room for a restful end to each day.',
      goal: 'Take a screen-free evening',
    );

    expect(controller.challenges.first.id, challenge.id);
    expect(challenge.isJoined, isFalse);
    expect(challenge.dailyProgress, List<double>.filled(7, 0));
    expect(challenge.endsOn.difference(challenge.startsOn).inDays, 6);
  });

  test('custom goals, future dates and private visibility stay local', () {
    final startDate = DateTime.now().add(const Duration(days: 12));
    final challenge = controller.createChallenge(
      title: 'A flexible routine',
      description: 'Choose a habit that fits your everyday life.',
      goal: 'Stretch for 10 minutes',
      startsOn: startDate,
      visibility: ChallengeVisibility.private,
    );

    expect(challenge.goal, 'Stretch for 10 minutes');
    expect(
      challenge.startsOn,
      DateTime(startDate.year, startDate.month, startDate.day),
    );
    expect(challenge.endsOn.difference(challenge.startsOn).inDays, 6);
    expect(
      challenge.statusAt(DateTime.now()),
      ChallengeScheduleStatus.upcoming,
    );
    expect(challenge.isPrivate, isTrue);
    expect(challenge.isCreator, isTrue);
    expect(challenge.canAccess, isTrue);
    expect(controller.challenges.first.id, challenge.id);

    final privateChallenge = Challenge(
      id: 'other-private',
      title: 'Invite only',
      description: 'A private challenge',
      goal: 'Take a walk',
      startsOn: DateTime.now(),
      isJoined: false,
      participantCount: 1,
      dailyProgress: List<double>.filled(7, 0),
      visibility: ChallengeVisibility.private,
    );
    expect(privateChallenge.canAccess, isFalse);
  });

  test('past start dates are rejected', () {
    expect(
      () => controller.createChallenge(
        title: 'Past challenge',
        description: 'This date should not be accepted.',
        goal: 'Read for 15 minutes',
        startsOn: DateTime.now().subtract(const Duration(days: 1)),
      ),
      throwsArgumentError,
    );
  });
}
