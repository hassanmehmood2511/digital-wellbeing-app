import 'package:flutter/foundation.dart';

import '../../../core/backend/backend.dart';
import '../models/habit_model.dart';

/// Habits for the signed-in user, backed by Supabase tables `habits` and
/// `habit_logs`. Changes are applied on the device immediately and saved to
/// the server in the background.
class HabitStore extends ChangeNotifier {
  HabitStore._();

  static final HabitStore instance = HabitStore._();

  final List<HabitModel> _habits = [];

  bool isLoading = false;
  bool hasLoaded = false;
  String? loadError;

  /// The day the current `completedCount` values belong to. When the date
  /// changes, counts reset for the new day on the next read or reload.
  DateTime _loadedDay = dateOnly(DateTime.now());

  List<HabitModel> get habits {
    _rollOverIfNewDay();

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

  /// Highest active streak across all habits (shown on Home).
  int get bestStreak => _habits.fold<int>(
    0,
    (best, habit) => habit.currentStreak > best ? habit.currentStreak : best,
  );

  Future<void> load() async {
    final client = Backend.client;
    final userId = Backend.userId;
    if (client == null || userId == null) {
      hasLoaded = true;
      notifyListeners();
      return;
    }

    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final today = dateOnly(DateTime.now());
      final rows = await client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('created_at');
      final logs = await client
          .from('habit_logs')
          .select('habit_id, completed_count')
          .eq('user_id', userId)
          .eq('log_date', dateKey(today));

      final todayCounts = <String, int>{
        for (final log in logs)
          log['habit_id'] as String: (log['completed_count'] as num).toInt(),
      };

      _habits
        ..clear()
        ..addAll(
          rows.map(
            (row) => _fromRow(row, todayCounts[row['id'] as String] ?? 0, today),
          ),
        );
      _loadedDay = today;
      hasLoaded = true;
    } catch (error) {
      loadError = friendlyErrorMessage(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clears everything (used on sign out).
  void reset() {
    _habits.clear();
    hasLoaded = false;
    loadError = null;
    notifyListeners();
  }

  void addHabit(HabitModel habit) {
    _habits.add(habit);
    notifyListeners();

    _sync(() async {
      await Backend.client!.from('habits').insert(_toRow(habit));
    }, rollback: () => _habits.removeWhere((h) => h.habitId == habit.habitId));
  }
  /// Logs one completion for today. Returns the habit only when this tap
  /// completed the daily target (so the caller can award points).
  HabitModel? completeHabit(String habitId) {
    _rollOverIfNewDay();
    final index = _habits.indexWhere((habit) => habit.habitId == habitId);

    if (index == -1) return null;

    final habit = _habits[index];

    if (habit.isCompleted) return null;

    final today = dateOnly(DateTime.now());
    final newCount = habit.completedCount + 1;
    final reachedTarget = newCount >= habit.targetCount;

    var updatedHabit = habit.copyWith(completedCount: newCount);
    if (reachedTarget) {
      final last = habit.lastCompletedOn;
      final yesterday = today.subtract(const Duration(days: 1));
      final int streak;
      if (last != null && dateOnly(last) == today) {
        streak = habit.currentStreak;
      } else if (last != null && dateOnly(last) == yesterday) {
        streak = habit.currentStreak + 1;
      } else {
        streak = 1;
      }
      updatedHabit = updatedHabit.copyWith(
        currentStreak: streak,
        lastCompletedOn: today,
      );
    }
    _habits[index] = updatedHabit;
    notifyListeners();

    _sync(() async {
      final client = Backend.client!;
      await client.from('habit_logs').upsert({
        'habit_id': habitId,
        'user_id': Backend.userId,
        'log_date': dateKey(today),
        'completed_count': newCount,
      }, onConflict: 'habit_id,log_date');
      if (reachedTarget) {
        await client
            .from('habits')
            .update({
              'current_streak': updatedHabit.currentStreak,
              'last_completed_on': dateKey(today),
            })
            .eq('id', habitId);
      }
    });

    return reachedTarget ? updatedHabit : null;
  }

  void deleteHabit(String habitId) {
    final index = _habits.indexWhere((habit) => habit.habitId == habitId);
    if (index == -1) return;
    final removed = _habits.removeAt(index);

    notifyListeners();

    _sync(() async {
      await Backend.client!.from('habits').delete().eq('id', habitId);
    }, rollback: () => _habits.insert(index.clamp(0, _habits.length), removed));
  }

  // ---------------------------------------------------------------------------

  void _sync(Future<void> Function() action, {VoidCallback? rollback}) {
    if (Backend.client == null || Backend.userId == null) return;
    action().catchError((Object error) {
      rollback?.call();
      if (rollback != null) notifyListeners();
      reportSyncError(error, message: 'Couldn’t save your habit. Please try again.');
    });
  }

  void _rollOverIfNewDay() {
    final today = dateOnly(DateTime.now());
    if (today == _loadedDay) return;
    _loadedDay = today;
    for (var i = 0; i < _habits.length; i++) {
      final habit = _habits[i];
      _habits[i] = HabitModel(
        habitId: habit.habitId,
        ownerUid: habit.ownerUid,
        title: habit.title,
        description: habit.description,
        category: habit.category,
        frequency: habit.frequency,
        targetCount: habit.targetCount,
        completedCount: 0,
        currentStreak: _activeStreak(habit.currentStreak, habit.lastCompletedOn, today),
        icon: habit.icon,
        priority: habit.priority,
        lastCompletedOn: habit.lastCompletedOn,
      );
    }
  }

  /// A streak only counts if the habit was completed today or yesterday.
  static int _activeStreak(int streak, DateTime? last, DateTime today) {
    if (last == null) return 0;
    final daysAgo = today.difference(dateOnly(last)).inDays;
    return daysAgo <= 1 ? streak : 0;
  }

  static HabitModel _fromRow(
    Map<String, dynamic> row,
    int completedToday,
    DateTime today,
  ) {
    final lastRaw = row['last_completed_on'] as String?;
    final last = lastRaw == null ? null : DateTime.parse(lastRaw);
    return HabitModel(
      habitId: row['id'] as String,
      ownerUid: row['user_id'] as String,
      title: row['title'] as String,
      description: (row['description'] as String?) ?? '',
      category: (row['category'] as String?) ?? 'General',
      frequency: (row['frequency'] as String?) ?? 'Daily',
      targetCount: (row['target_count'] as num).toInt(),
      completedCount: completedToday,
      currentStreak: _activeStreak(
        (row['current_streak'] as num?)?.toInt() ?? 0,
        last,
        today,
      ),
      icon: (row['icon'] as String?) ?? '✅',
      priority: (row['priority'] as String?) ?? 'Medium',
      lastCompletedOn: last,
    );
  }

  static Map<String, dynamic> _toRow(HabitModel habit) => {
    'id': habit.habitId,
    'user_id': Backend.userId,
    'title': habit.title,
    'description': habit.description,
    'category': habit.category,
    'frequency': habit.frequency,
    'target_count': habit.targetCount,
    'icon': habit.icon,
    'priority': habit.priority,
    'current_streak': habit.currentStreak,
    'last_completed_on': habit.lastCompletedOn == null
        ? null
        : dateKey(habit.lastCompletedOn!),
  };
}
