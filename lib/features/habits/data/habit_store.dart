import 'package:flutter/foundation.dart';

import '../models/habit_model.dart';
import 'mock_habits.dart';

class HabitStore extends ChangeNotifier {
  HabitStore._();

  static final HabitStore instance = HabitStore._();

  final List<HabitModel> _habits = List<HabitModel>.from(MockHabits.habits);

  List<HabitModel> get habits {
    final indexedHabits = List.generate(
      _habits.length,
      (index) => (index: index, habit: _habits[index]),
    );

    int priorityRank(String priority) {
      switch (priority.toLowerCase()) {
        case 'high':
          return 0;
        case 'medium':
          return 1;
        case 'low':
          return 2;
        default:
          return 1;
      }
    }

    indexedHabits.sort((a, b) {
      final priorityComparison = priorityRank(
        a.habit.priority,
      ).compareTo(priorityRank(b.habit.priority));

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      return a.index.compareTo(b.index);
    });

    return List.unmodifiable(indexedHabits.map((item) => item.habit));
  }

  void addHabit(HabitModel habit) {
    _habits.add(habit);
    notifyListeners();
  }

  void updateHabit(HabitModel updatedHabit) {
    final index = _habits.indexWhere(
      (habit) => habit.habitId == updatedHabit.habitId,
    );

    if (index == -1) return;

    _habits[index] = updatedHabit;
    notifyListeners();
  }

  void completeHabit(String habitId) {
    final index = _habits.indexWhere((habit) => habit.habitId == habitId);

    if (index == -1) return;

    final habit = _habits[index];

    if (habit.isCompleted) return;

    _habits[index] = habit.copyWith(
      completedCount: habit.completedCount + 1,
      currentStreak: habit.currentStreak + 1,
    );

    notifyListeners();
  }

  void deleteHabit(String habitId) {
    _habits.removeWhere((habit) => habit.habitId == habitId);

    notifyListeners();
  }
}
