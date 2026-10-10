enum ChallengeVisibility { public, private }

enum ChallengeScheduleStatus { upcoming, active, completed, ended }

class Challenge {
  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.goal,
    required this.startsOn,
    required this.isJoined,
    required this.participantCount,
    required List<double> dailyProgress,
    this.visibility = ChallengeVisibility.public,
    this.isCreator = false,
    this.isInvited = false,
  }) : dailyProgress = List<double>.unmodifiable(dailyProgress) {
    if (dailyProgress.length != 7) {
      throw ArgumentError.value(dailyProgress.length, 'dailyProgress');
    }
  }

  final String id;
  final String title;
  final String description;
  final String goal;
  final DateTime startsOn;
  final bool isJoined;
  final int participantCount;
  final List<double> dailyProgress;
  final ChallengeVisibility visibility;
  final bool isCreator;
  final bool isInvited;

  DateTime get endsOn => startsOn.add(const Duration(days: 6));
  int get completedDays => dailyProgress.where((progress) => progress >= 1).length;
  double get progress => dailyProgress.fold<double>(0, (sum, value) => sum + value) / 7;
  bool get isComplete => completedDays == 7;
  bool get isPrivate => visibility == ChallengeVisibility.private;
  bool get canAccess => !isPrivate || isCreator || isInvited;

  ChallengeScheduleStatus statusAt(DateTime date) {
    if (isComplete) return ChallengeScheduleStatus.completed;
    final today = DateTime(date.year, date.month, date.day);
    if (today.isBefore(startsOn)) return ChallengeScheduleStatus.upcoming;
    if (today.isAfter(endsOn)) return ChallengeScheduleStatus.ended;
    return ChallengeScheduleStatus.active;
  }

  Challenge copyWith({
    bool? isJoined,
    int? participantCount,
    List<double>? dailyProgress,
    ChallengeVisibility? visibility,
    bool? isCreator,
    bool? isInvited,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      goal: goal,
      startsOn: startsOn,
      isJoined: isJoined ?? this.isJoined,
      participantCount: participantCount ?? this.participantCount,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      visibility: visibility ?? this.visibility,
      isCreator: isCreator ?? this.isCreator,
      isInvited: isInvited ?? this.isInvited,
    );
  }
}
