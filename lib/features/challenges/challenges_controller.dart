import 'package:flutter/foundation.dart';

import '../../core/backend/backend.dart';
import 'challenge.dart';

/// 7-day challenges backed by Supabase tables `challenges` and
/// `challenge_participants`.
///
/// Public challenges from every user are listed; private ones only for their
/// creator. Actions update the screen immediately and save in the background.
class ChallengesController extends ChangeNotifier {
  ChallengesController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<Challenge> _challenges = [];
  bool _isDisposed = false;
  bool isLoading = false;
  bool hasLoaded = false;
  String? loadError;

  List<Challenge> get challenges => List<Challenge>.unmodifiable(
    _challenges.where((challenge) => challenge.canAccess),
  );

  /// The challenge to feature on Home: an active joined one first, then any
  /// joined one that hasn't ended.
  Challenge? get featuredChallenge {
    final now = _clock();
    final joined = _challenges.where((c) => c.isJoined).toList();
    for (final challenge in joined) {
      if (challenge.statusAt(now) == ChallengeScheduleStatus.active) {
        return challenge;
      }
    }
    for (final challenge in joined) {
      if (challenge.statusAt(now) != ChallengeScheduleStatus.ended) {
        return challenge;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

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
      final rows = await client
          .from('challenges')
          .select()
          .order('starts_on', ascending: false)
          .order('created_at', ascending: false)
          .limit(100);
      final mine = await client
          .from('challenge_participants')
          .select('challenge_id, daily_progress, is_active')
          .eq('user_id', userId);

      final participation = <String, Map<String, dynamic>>{
        for (final row in mine) row['challenge_id'] as String: row,
      };

      if (_isDisposed) return;
      _challenges
        ..clear()
        ..addAll(
          rows.map(
            (row) => _fromRow(row, participation[row['id'] as String], userId),
          ),
        );
      hasLoaded = true;
      isLoading = false;
      notifyListeners();
    } catch (error) {
      if (_isDisposed) return;
      isLoading = false;
      loadError = 'Challenges could not be loaded. Please try again.';
      debugPrint('Challenges load failed: $error');
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
    final startDate = dateOnly(startsOn ?? _clock());
    if (startDate.isBefore(dateOnly(_clock()))) {
      throw ArgumentError.value(startsOn, 'startsOn', 'Start date cannot be in the past.');
    }

    final challenge = Challenge(
      id: newUuid(),
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

    _sync(
      () => Backend.client!.from('challenges').insert({
        'id': challenge.id,
        'creator_id': Backend.userId,
        'title': challenge.title,
        'description': challenge.description,
        'goal': challenge.goal,
        'starts_on': dateKey(challenge.startsOn),
        'visibility': challenge.visibility.name,
      }),
      rollback: () => _challenges.removeWhere((c) => c.id == challenge.id),
      message: 'Couldn’t create the challenge. Please try again.',
    );
    return challenge;
  }

  void join(String id) {
    final before = challengeById(id);
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
    if (before == null || before.isJoined) return;

    // Upsert keeps earlier progress if the user left and is re-joining.
    _sync(
      () => Backend.client!.from('challenge_participants').upsert({
        'challenge_id': id,
        'user_id': Backend.userId,
        'is_active': true,
      }, onConflict: 'challenge_id,user_id'),
      rollback: () => _replace(before),
      message: 'Couldn’t join the challenge. Please try again.',
    );
  }

  void leave(String id) {
    final before = challengeById(id);
    _update(id, (challenge) {
      if (!challenge.isJoined) return challenge;
      return challenge.copyWith(
        isJoined: false,
        participantCount: (challenge.participantCount - 1).clamp(0, 1 << 31),
      );
    });
    if (before == null || !before.isJoined) return;

    _sync(
      () => Backend.client!
          .from('challenge_participants')
          .update({'is_active': false})
          .eq('challenge_id', id)
          .eq('user_id', Backend.userId!),
      rollback: () => _replace(before),
      message: 'Couldn’t leave the challenge. Please try again.',
    );
  }

  void addDailyProgress(String id, int dayIndex) {
    if (dayIndex < 0 || dayIndex >= 7) {
      throw RangeError.index(dayIndex, List<double>.filled(7, 0));
    }
    final before = challengeById(id);
    _update(id, (challenge) {
      if (!challenge.isJoined) {
        throw StateError('Join the challenge before logging progress.');
      }
      final progressDate = challenge.startsOn.add(Duration(days: dayIndex));
      if (progressDate.isAfter(dateOnly(_clock()))) {
        throw StateError('Progress can only be logged on or before today.');
      }
      final progress = List<double>.of(challenge.dailyProgress);
      progress[dayIndex] = (progress[dayIndex] + 0.5).clamp(0.0, 1.0);
      return challenge.copyWith(dailyProgress: progress);
    });
    final updated = challengeById(id)!;

    _sync(
      () => Backend.client!
          .from('challenge_participants')
          .update({'daily_progress': updated.dailyProgress})
          .eq('challenge_id', id)
          .eq('user_id', Backend.userId!),
      rollback: before == null ? null : () => _replace(before),
      message: 'Couldn’t save your progress. Please try again.',
    );
  }

  /// Clears everything (used on sign out).
  void reset() {
    _challenges.clear();
    hasLoaded = false;
    loadError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------

  void _update(String id, Challenge Function(Challenge) update) {
    final index = _challenges.indexWhere((challenge) => challenge.id == id);
    if (index == -1) throw ArgumentError.value(id, 'id', 'Unknown challenge');
    _challenges[index] = update(_challenges[index]);
    notifyListeners();
  }

  void _replace(Challenge challenge) {
    final index = _challenges.indexWhere((c) => c.id == challenge.id);
    if (index != -1) _challenges[index] = challenge;
  }

  void _sync(
    Future<void> Function() action, {
    VoidCallback? rollback,
    required String message,
  }) {
    if (Backend.client == null || Backend.userId == null) return;
    action().catchError((Object error) {
      if (rollback != null) {
        rollback();
        notifyListeners();
      }
      reportSyncError(error, message: message);
    });
  }

  static Challenge _fromRow(
    Map<String, dynamic> row,
    Map<String, dynamic>? participation,
    String userId,
  ) {
    final rawProgress = participation?['daily_progress'] as List<dynamic>?;
    final progress = rawProgress == null || rawProgress.length != 7
        ? List<double>.filled(7, 0)
        : rawProgress.map((v) => (v as num).toDouble()).toList();
    final isCreator = row['creator_id'] == userId;
    return Challenge(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String,
      goal: row['goal'] as String,
      startsOn: DateTime.parse(row['starts_on'] as String),
      isJoined: participation?['is_active'] == true,
      participantCount: (row['participant_count'] as num?)?.toInt() ?? 0,
      dailyProgress: progress,
      visibility: row['visibility'] == 'private'
          ? ChallengeVisibility.private
          : ChallengeVisibility.public,
      isCreator: isCreator,
      // If the database returned a private challenge, this user may see it.
      isInvited: !isCreator && row['visibility'] == 'private',
    );
  }
}
