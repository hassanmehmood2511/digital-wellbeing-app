class HabitModel {
  final String habitId;
  final String ownerUid;
  final String title;
  final String description;
  final String category;
  final String frequency;
  final int targetCount;
  final int completedCount;
  final int currentStreak;
  final String icon;

  const HabitModel({
    required this.habitId,
    required this.ownerUid,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    required this.targetCount,
    required this.completedCount,
    required this.currentStreak,
    required this.icon,
  });

  double get progress {
    if (targetCount <= 0) return 0;

    return (completedCount / targetCount).clamp(0.0, 1.0);
  }

  bool get isCompleted {
    return completedCount >= targetCount;
  }

  HabitModel copyWith({
    String? habitId,
    String? ownerUid,
    String? title,
    String? description,
    String? category,
    String? frequency,
    int? targetCount,
    int? completedCount,
    int? currentStreak,
    String? icon,
  }) {
    return HabitModel(
      habitId: habitId ?? this.habitId,
      ownerUid: ownerUid ?? this.ownerUid,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      completedCount: completedCount ?? this.completedCount,
      currentStreak: currentStreak ?? this.currentStreak,
      icon: icon ?? this.icon,
    );
  }
}
