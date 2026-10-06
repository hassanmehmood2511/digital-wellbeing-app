import 'package:flutter/foundation.dart';

import '../models/habit_model.dart';
import 'mock_habits.dart';

class HabitStore extends ChangeNotifier {
  HabitStore._();

  static final HabitStore instance = HabitStore._();

  final List<HabitModel> _habits = List<HabitModel>.from(MockHabits.habits);

  List<HabitModel> get habits => List.unmodifiable(_habits);

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
