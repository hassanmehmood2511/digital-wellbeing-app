import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/backend/backend.dart';

abstract final class RewardConfig {
  static const int habitCompletionPoints = 10;
  static const int challengeCompletionBonus = 50;
}

enum RewardType { habit, challenge }

class RewardTransaction {
  const RewardTransaction({
    required this.id,
    required this.activityName,
    required this.points,
    required this.type,
    required this.earnedAt,
  });

  final String id;
  final String activityName;
  final int points;
  final RewardType type;
  final DateTime earnedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'activityName': activityName,
    'points': points,
    'type': type.name,
    'earnedAt': earnedAt.toIso8601String(),
  };

  factory RewardTransaction.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'];
    final type = RewardType.values.where((value) => value.name == typeName);
    if (type.isEmpty) {
      throw const FormatException('Unknown reward transaction type.');
    }
    return RewardTransaction(
      id: json['id'] as String,
      activityName: json['activityName'] as String,
      points: json['points'] as int,
      type: type.first,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }
}

class PointsStore extends ChangeNotifier {
  PointsStore._();

  static final PointsStore instance = PointsStore._();

  final List<RewardTransaction> _transactions = [];

  bool isLoading = false;
  String? loadError;

  int get balance =>
      _transactions.fold(0, (total, transaction) => total + transaction.points);

  int get lifetimeEarned => balance;

  /// Points earned since midnight (shown as "+N today" on Home).
  int get earnedToday {
    final today = dateOnly(DateTime.now());
    return _transactions
        .where((t) => !dateOnly(t.earnedAt).isBefore(today))
        .fold(0, (total, t) => total + t.points);
  }

  List<RewardTransaction> get transactions {
    final sorted = List<RewardTransaction>.of(_transactions)
      ..sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
    return List.unmodifiable(sorted);
  }

  /// Kept for compatibility with app start-up; data now loads per user via
  /// [load] after sign in.
  Future<void> initialize() async {}

  /// Loads the signed-in user's points history from Supabase.
  Future<void> load() async {
    final client = Backend.client;
    final userId = Backend.userId;
    if (client == null || userId == null) return;

    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final rows = await client
          .from('reward_transactions')
          .select()
          .eq('user_id', userId)
          .order('earned_at', ascending: false);
      _transactions
        ..clear()
        ..addAll(rows.map(_fromRow));
    } catch (error) {
      loadError = friendlyErrorMessage(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clears everything (used on sign out).
  void reset() {
    _transactions.clear();
    loadError = null;
    notifyListeners();
  }

  /// Awards points once per [id]. Returns the points actually awarded
  /// (0 when this reward was already given).
  Future<int> award({
    required String id,
    required String activityName,
    required int points,
    required RewardType type,
  }) async {
    if (id.trim().isEmpty || activityName.trim().isEmpty || points <= 0) {
      throw ArgumentError('A reward requires an id, activity name and points.');
    }
    if (_transactions.any((transaction) => transaction.id == id)) {
      return 0;
    }

    final transaction = RewardTransaction(
      id: id,
      activityName: activityName,
      points: points,
      type: type,
      earnedAt: DateTime.now(),
    );

    final client = Backend.client;
    final userId = Backend.userId;
    if (client != null && userId != null) {
      try {
        await client.from('reward_transactions').insert({
          'user_id': userId,
          'reward_key': id,
          'activity_name': activityName,
          'points': points,
          'type': type.name,
        });
      } on PostgrestException catch (error) {
        // 23505 = unique violation: this reward was already saved.
        if (error.code == '23505') return 0;
        rethrow;
      }
    }

    _transactions.add(transaction);
    notifyListeners();
    return points;
  }

  static RewardTransaction _fromRow(Map<String, dynamic> row) {
    final typeName = row['type'] as String?;
    return RewardTransaction(
      id: row['reward_key'] as String,
      activityName: row['activity_name'] as String,
      points: (row['points'] as num).toInt(),
      type: typeName == RewardType.challenge.name
          ? RewardType.challenge
          : RewardType.habit,
      earnedAt: DateTime.parse(row['earned_at'] as String).toLocal(),
    );
  }
}
