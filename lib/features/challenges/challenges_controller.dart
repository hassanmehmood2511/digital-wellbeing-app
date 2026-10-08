import 'package:flutter/foundation.dart';

import 'challenge.dart';

class ChallengesController extends ChangeNotifier {
  ChallengesController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _challenges = _sampleChallenges((clock ?? DateTime.now)());

  final DateTime Function() _clock;
  final List<Challenge> _challenges;
  int _nextId = 1;
  bool _isDisposed = false;
  bool isLoading = false;
  String? loadError;

  List<Challenge> get challenges => List<Challenge>.unmodifiable(
    _challenges.where((challenge) => challenge.canAccess),
  );

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (_isDisposed) return;
      isLoading = false;
      notifyListeners();
    } on Exception {
      if (_isDisposed) return;
      isLoading = false;
      loadError = 'Challenges could not be loaded. Please try again.';
      notifyListeners();
    }
  }

  Challenge? challengeById(String id) {
    for (final challenge in _challenges) {
      if (challenge.id == id) return challenge;
    }
    return null;
  }

  Challenge createChallenge({
    required String title,
    required String description,
    required String goal,
    DateTime? startsOn,
    ChallengeVisibility visibility = ChallengeVisibility.public,
  }) {
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();
    final normalizedGoal = goal.trim();
    if (normalizedTitle.isEmpty ||
        normalizedDescription.isEmpty ||
        normalizedGoal.isEmpty) {
      throw ArgumentError('Title, description and goal are required.');
    }
    if (normalizedTitle.length > 60 || normalizedDescription.length > 280) {
      throw ArgumentError('Challenge details exceed the allowed length.');
    }
    if (normalizedGoal.length > 80) {
      throw ArgumentError.value(goal, 'goal', 'Goal cannot exceed 80 characters.');
    }
    final startDate = _dateOnly(startsOn ?? _clock());
    if (startDate.isBefore(_dateOnly(_clock()))) {
      throw ArgumentError.value(startsOn, 'startsOn', 'Start date cannot be in the past.');
    }

    final challenge = Challenge(
      id: 'local-${_nextId++}',
      title: normalizedTitle,
      description: normalizedDescription,
      goal: normalizedGoal,
      startsOn: startDate,
      isJoined: false,
      participantCount: 0,
      dailyProgress: List<double>.filled(7, 0),
      visibility: visibility,
      isCreator: true,
    );
    _challenges.insert(0, challenge);
    notifyListeners();
    return challenge;
  }

  void join(String id) {
    _update(id, (challenge) {
      if (!challenge.canAccess) {
        throw StateError('This private challenge is not available to join.');
      }
      if (challenge.statusAt(_clock()) == ChallengeScheduleStatus.ended) {
        throw StateError('This challenge has ended and cannot be joined.');
      }
      if (challenge.isJoined) return challenge;
      return challenge.copyWith(
        isJoined: true,
        participantCount: challenge.participantCount + 1,
      );
    });
  }

  void leave(String id) {
    _update(id, (challenge) {
      if (!challenge.isJoined) return challenge;
      return challenge.copyWith(
        isJoined: false,
        participantCount: (challenge.participantCount - 1).clamp(0, 1 << 31),
      );
    });
  }

  void addDailyProgress(String id, int dayIndex) {
    if (dayIndex < 0 || dayIndex >= 7) {
      throw RangeError.index(dayIndex, List<double>.filled(7, 0));
    }
    _update(id, (challenge) {
      if (!challenge.isJoined) {
        throw StateError('Join the challenge before logging progress.');
      }
      final progressDate = challenge.startsOn.add(Duration(days: dayIndex));
      if (progressDate.isAfter(_dateOnly(_clock()))) {
        throw StateError('Progress can only be logged on or before today.');
      }
      final progress = List<double>.of(challenge.dailyProgress);
      progress[dayIndex] = (progress[dayIndex] + 0.5).clamp(0.0, 1.0);
      return challenge.copyWith(dailyProgress: progress);
    });
  }

  void _update(String id, Challenge Function(Challenge) update) {
    final index = _challenges.indexWhere((challenge) => challenge.id == id);
    if (index == -1) throw ArgumentError.value(id, 'id', 'Unknown challenge');
    _challenges[index] = update(_challenges[index]);
    notifyListeners();
  }

  static List<Challenge> _sampleChallenges(DateTime now) {
    final today = _dateOnly(now);
    return [
      Challenge(
        id: 'mindful-mornings',
        title: 'Mindful mornings',
        description: 'Start each day with a few quiet minutes for yourself.',
        goal: '10 minutes of mindfulness',
        startsOn: today.subtract(const Duration(days: 2)),
        isJoined: true,
        participantCount: 24,
        dailyProgress: [1, 0.5, 0, 0, 0, 0, 0],
      ),
      Challenge(
        id: 'daily-hydration',
        title: 'Daily hydration',
        description: 'Build a gentle hydration habit, one glass at a time.',
        goal: 'Drink 8 glasses of water',
        startsOn: today,
        isJoined: false,
        participantCount: 38,
        dailyProgress: List<double>.filled(7, 0),
      ),
    ];
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
