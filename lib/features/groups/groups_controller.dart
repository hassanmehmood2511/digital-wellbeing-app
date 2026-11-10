import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../core/backend/backend.dart';
import 'group.dart';

/// Groups and their leaderboards, backed by Supabase tables `groups` and
/// `group_members` plus the `join_group_with_code` and
/// `get_my_group_members` database functions.
class GroupsController extends ChangeNotifier {
  GroupsController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final List<BehtarGroup> _groups = [];

  /// Groups created on this device that a reload might not include yet.
  final Set<String> _recentlyCreatedIds = {};
  bool _isDisposed = false;
  bool isLoading = false;
  String? loadError;

  List<BehtarGroup> get joinedGroups => List<BehtarGroup>.unmodifiable(
    _groups.where((group) => group.isJoined),
  );

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
    if (client == null || userId == null) return;

    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final groupRows = await client
          .from('groups')
          .select()
          .order('created_at', ascending: false);
      final memberRows = await client.rpc('get_my_group_members') as List<dynamic>;

      final membersByGroup = <String, List<GroupMember>>{};
      for (final raw in memberRows) {
        final row = raw as Map<String, dynamic>;
        final memberId = row['user_id'] as String;
        membersByGroup.putIfAbsent(row['group_id'] as String, () => []).add(
          GroupMember(
            id: memberId,
            name: (row['full_name'] as String?) ?? 'Behtar member',
            points: (row['points'] as num?)?.toInt() ?? 0,
            isCurrentUser: memberId == userId,
          ),
        );
      }

      if (_isDisposed) return;
      final serverIds = groupRows.map((row) => row['id'] as String).toSet();
      final keepLocal = _groups
          .where(
            (g) =>
                _recentlyCreatedIds.contains(g.id) && !serverIds.contains(g.id),
          )
          .toList();
      _recentlyCreatedIds.removeAll(serverIds);
      _groups
        ..clear()
        ..addAll(keepLocal)
        ..addAll(
          groupRows.map((row) {
            final id = row['id'] as String;
            final members = membersByGroup[id] ?? const <GroupMember>[];
            return BehtarGroup(
              id: id,
              name: row['name'] as String,
              description: row['description'] as String,
              visibility: row['visibility'] == 'private'
                  ? GroupVisibility.private
                  : GroupVisibility.public,
              inviteCode: row['invite_code'] as String,
              inviteExpiresOn: DateTime.parse(row['invite_expires_on'] as String),
              members: members,
              isCreator: row['creator_id'] == userId,
              isJoined: members.any((m) => m.isCurrentUser),
            );
          }),
        );
      isLoading = false;
      notifyListeners();
    } catch (error) {
      if (_isDisposed) return;
      isLoading = false;
      loadError = 'Groups could not be loaded. Please try again.';
      debugPrint('Groups load failed: $error');
      notifyListeners();
    }
  }

  BehtarGroup? groupById(String id) {
    for (final group in _groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  /// Creates a group on the server (group + creator membership in one
  /// step), then adds it to the list. Throws if the server rejects it.
  Future<BehtarGroup> createGroup({
    required String name,
    required String description,
    required GroupVisibility visibility,
    required String creatorName,
  }) async {
    final normalizedName = name.trim();
    final normalizedDescription = description.trim();
    final normalizedCreator = creatorName.trim();
    if (normalizedName.length < 3 || normalizedName.length > 40) {
      throw ArgumentError('Group name must be 3–40 characters.');
    }
    if (normalizedDescription.length < 8 ||
        normalizedDescription.length > 240) {
      throw ArgumentError('Description must be 8–240 characters.');
    }

    final group = BehtarGroup(
      id: newUuid(),
      name: normalizedName,
      description: normalizedDescription,
      visibility: visibility,
      inviteCode: _generateInviteCode(),
      inviteExpiresOn: dateOnly(_clock()).add(const Duration(days: 30)),
      members: [
        GroupMember(
          id: Backend.userId ?? 'current-user',
          name: normalizedCreator.isEmpty ? 'You' : normalizedCreator,
          points: _myPoints(),
          isCurrentUser: true,
        ),
      ],
      isCreator: true,
      isJoined: true,
    );

    final client = Backend.client;
    if (client != null && Backend.userId != null) {
      await client.rpc(
        'create_group',
        params: {
          'p_id': group.id,
          'p_name': group.name,
          'p_description': group.description,
          'p_visibility': group.visibility.name,
          'p_invite_code': group.inviteCode,
        },
      );
    }

    _recentlyCreatedIds.add(group.id);
    _groups.removeWhere((g) => g.id == group.id);
    _groups.insert(0, group);
    notifyListeners();
    return group;
  }

  /// Joins a group by invite code through the `join_group_with_code`
  /// database function, then reloads the group list.
  Future<GroupInviteResult> joinWithInviteCode(
    String code, {
    String memberName = 'You',
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) return GroupInviteResult.invalidCode;

    final alreadyJoined = joinedGroups.any(
      (group) => group.inviteCode.toUpperCase() == normalizedCode,
    );
    if (alreadyJoined) return GroupInviteResult.alreadyJoined;

    final client = Backend.client;
    if (client == null || Backend.userId == null) {
      return GroupInviteResult.invalidCode;
    }

    final result = await client.rpc(
      'join_group_with_code',
      params: {'p_code': normalizedCode},
    );
    final outcome = switch (result as String?) {
      'joined' => GroupInviteResult.joined,
      'already_joined' => GroupInviteResult.alreadyJoined,
      'expired_code' => GroupInviteResult.expiredCode,
      'access_denied' => GroupInviteResult.accessDenied,
      _ => GroupInviteResult.invalidCode,
    };
    if (outcome == GroupInviteResult.joined ||
        outcome == GroupInviteResult.alreadyJoined) {
      await load();
    }
    return outcome;
  }

  /// Clears everything (used on sign out).
  void reset() {
    _groups.clear();
    loadError = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------

  int _myPoints() {
    for (final group in _groups) {
      for (final member in group.members) {
        if (member.isCurrentUser) return member.points;
      }
    }
    return 0;
  }

  static String _generateInviteCode() {
    // No 0/O/1/I so codes are easy to read out loud.
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final suffix = List.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    return 'BHT$suffix';
  }
}
