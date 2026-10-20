import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _storageKey = 'behtar.reward_transactions.v1';

  final List<RewardTransaction> _transactions = [];
  SharedPreferences? _preferences;
  Future<void> _writeTail = Future<void>.value();
  bool _isInitialized = false;

  int get balance =>
      _transactions.fold(0, (total, transaction) => total + transaction.points);

  int get lifetimeEarned => balance;

  List<RewardTransaction> get transactions {
    final sorted = List<RewardTransaction>.of(_transactions)
      ..sort((a, b) => b.earnedAt.compareTo(a.earnedAt));
    return List.unmodifiable(sorted);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_storageKey);
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      if (decoded is! List<dynamic>) {
        throw const FormatException('Saved reward history is not a list.');
      }
      _transactions
        ..clear()
        ..addAll(
          decoded.map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'Saved reward history contains an invalid transaction.',
              );
            }
            return RewardTransaction.fromJson(item);
          }),
        );
    }
    _preferences = preferences;
    _isInitialized = true;
  }

  Future<int> award({
    required String id,
    required String activityName,
    required int points,
    required RewardType type,
  }) async {
    if (!_isInitialized) {
      throw StateError('PointsStore must be initialized before awarding points.');
    }
    if (id.trim().isEmpty || activityName.trim().isEmpty || points <= 0) {
      throw ArgumentError('A reward requires an id, activity name and points.');
    }
    if (_transactions.any((transaction) => transaction.id == id)) {
      await _persist();
      return 0;
    }

    _transactions.add(
      RewardTransaction(
        id: id,
        activityName: activityName,
        points: points,
        type: type,
        earnedAt: DateTime.now(),
      ),
    );
    notifyListeners();
    await _persist();
    return points;
  }

  Future<void> _persist() {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('PointsStore has no initialized preferences.');
    }
    final snapshot = jsonEncode(
      _transactions.map((transaction) => transaction.toJson()).toList(),
    );
    final write = _writeTail.then((_) async {
      final saved = await preferences.setString(_storageKey, snapshot);
      if (!saved) {
        throw StateError('Reward history could not be saved on this device.');
      }
    });
    _writeTail = write.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return write;
  }
}
