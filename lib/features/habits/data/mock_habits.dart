import '../models/habit_model.dart';

class MockHabits {
  static const List<HabitModel> habits = [
    HabitModel(
      habitId: 'habit_001',
      ownerUid: 'user_001',
      title: 'Study',
      description: 'Focus on your studies every day.',
      category: 'Study',
      frequency: 'Daily',
      targetCount: 4,
      completedCount: 3,
      currentStreak: 5,
      icon: '📚',
    ),
    HabitModel(
      habitId: 'habit_002',
      ownerUid: 'user_001',
      title: 'Exercise',
      description: 'Move your body and stay active.',
      category: 'Health',
      frequency: 'Daily',
      targetCount: 1,
      completedCount: 1,
      currentStreak: 7,
      icon: '🏃',
    ),
    HabitModel(
      habitId: 'habit_003',
      ownerUid: 'user_001',
      title: 'Sleep on Time',
      description: 'Maintain a healthy sleep routine.',
      category: 'Health',
      frequency: 'Daily',
      targetCount: 1,
      completedCount: 0,
      currentStreak: 3,
      icon: '🌙',
    ),
    HabitModel(
      habitId: 'habit_004',
      ownerUid: 'user_001',
      title: 'Reading',
      description: 'Read something useful every day.',
      category: 'Learning',
      frequency: 'Daily',
      targetCount: 1,
      completedCount: 1,
      currentStreak: 4,
      icon: '📖',
    ),
  ];
}
