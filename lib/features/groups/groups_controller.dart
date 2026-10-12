import 'package:flutter/foundation.dart';

import 'group.dart';

class GroupsController extends ChangeNotifier {
  GroupsController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _groups = _sampleGroups((clock ?? DateTime.now)());

  final DateTime Function() _clock;
  final List<BehtarGroup> _groups;
  int _nextId = 1;
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

  Future<void> load() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (_isDisposed) return;
      isLoading = false;
      notifyListeners();
    } on Exception {
      if (_isDisposed) return;
      isLoading = false;
      loadError = 'Groups could not be loaded. Please try again.';
      notifyListeners();
    }
  }

  BehtarGroup? groupById(String id) {
    for (final group in _groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  BehtarGroup createGroup({
    required String name,
    required String description,
    required GroupVisibility visibility,
    required String creatorName,
  }) {
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

    final id = 'local-group-${_nextId++}';
    final group = BehtarGroup(
      id: id,
      name: normalizedName,
      description: normalizedDescription,
      visibility: visibility,
      inviteCode: 'BETHTR${(1000 + _nextId).toString()}',
      inviteExpiresOn: _dateOnly(_clock()).add(const Duration(days: 30)),
      members: [
        GroupMember(
          id: 'current-user',
          name: normalizedCreator.isEmpty ? 'You' : normalizedCreator,
          points: 0,
          isCurrentUser: true,
        ),
      ],
      isCreator: true,
      isJoined: true,
    );
    _groups.insert(0, group);
    notifyListeners();
    return group;
  }

  GroupInviteResult joinWithInviteCode(String code, {String memberName = 'You'}) {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) return GroupInviteResult.invalidCode;

    final joined = _groups.where((group) => group.isJoined);
    final existing = joined.where(
      (group) => group.inviteCode.toUpperCase() == normalizedCode,
    );
    if (existing.isNotEmpty) return GroupInviteResult.alreadyJoined;

    final invite = _demoInvite(normalizedCode);
    if (invite == null) return GroupInviteResult.invalidCode;
    if (_dateOnly(_clock()).isAfter(invite.inviteExpiresOn)) {
      return GroupInviteResult.expiredCode;
    }
    if (!invite.canJoin) return GroupInviteResult.accessDenied;

    final member = GroupMember(
      id: 'current-user',
      name: memberName.trim().isEmpty ? 'You' : memberName.trim(),
      points: 0,
      isCurrentUser: true,
    );
    final joinedGroup = BehtarGroup(
      id: invite.id,
      name: invite.name,
      description: invite.description,
      visibility: invite.visibility,
      inviteCode: invite.inviteCode,
      inviteExpiresOn: invite.inviteExpiresOn,
      members: [...invite.members, member],
      isCreator: false,
      isJoined: true,
    );
    _groups.insert(0, joinedGroup);
    notifyListeners();
    return GroupInviteResult.joined;
  }

  static List<BehtarGroup> _sampleGroups(DateTime now) {
    final expiry = _dateOnly(now).add(const Duration(days: 30));
    return [
      BehtarGroup(
        id: 'mindful-circle',
        name: 'Mindful Circle',
        description: 'A friendly space for daily reflection and mindful habits.',
        visibility: GroupVisibility.public,
        inviteCode: 'BEHTAR7',
        inviteExpiresOn: expiry,
        members: const [
          GroupMember(
            id: 'current-user',
            name: 'Hassan',
            points: 480,
            isCurrentUser: true,
          ),
          GroupMember(id: 'sara', name: 'Sara Ahmed', points: 440),
          GroupMember(id: 'ali', name: 'Ali Raza', points: 440),
          GroupMember(id: 'amina', name: 'Amina Khan', points: 310),
        ],
        isCreator: true,
        isJoined: true,
      ),
      BehtarGroup(
        id: 'weekend-walkers',
        name: 'Weekend Walkers',
        description: 'Encouraging each other to get outside and move more.',
        visibility: GroupVisibility.private,
        inviteCode: 'WALKERS8',
        inviteExpiresOn: expiry,
        members: const [
          GroupMember(
            id: 'current-user',
            name: 'Hassan',
            points: 260,
            isCurrentUser: true,
          ),
          GroupMember(id: 'noor', name: 'Noor Fatima', points: 390),
          GroupMember(id: 'omar', name: 'Omar Shah', points: 260),
        ],
        isCreator: false,
        isJoined: true,
      ),
    ];
  }

  _InviteRecord? _demoInvite(String code) {
    final today = _dateOnly(_clock());
    switch (code) {
      case 'OPEN42':
        return _InviteRecord(
          id: 'open-community',
          name: 'Behtar Community',
          description: 'A welcoming group to support your wellbeing journey.',
          visibility: GroupVisibility.public,
          inviteCode: code,
          inviteExpiresOn: today.add(const Duration(days: 30)),
          members: const [
            GroupMember(id: 'layla', name: 'Layla Noor', points: 540),
            GroupMember(id: 'zain', name: 'Zain Ali', points: 420),
          ],
          canJoin: true,
        );
      case 'INVITE7':
        return _InviteRecord(
          id: 'private-invitation',
          name: 'Quiet Morning Club',
          description: 'A private group for building a calmer morning routine.',
          visibility: GroupVisibility.private,
          inviteCode: code,
          inviteExpiresOn: today.add(const Duration(days: 14)),
          members: const [
            GroupMember(id: 'maya', name: 'Maya Iqbal', points: 360),
          ],
          canJoin: true,
        );
      case 'EXPIRED7':
        return _InviteRecord(
          id: 'expired-invitation',
          name: 'Expired invitation',
          description: 'This invite is no longer active.',
          visibility: GroupVisibility.private,
          inviteCode: code,
          inviteExpiresOn: today.subtract(const Duration(days: 1)),
          members: const [],
          canJoin: true,
        );
      case 'DENIED7':
        return _InviteRecord(
          id: 'restricted-invitation',
          name: 'Restricted group',
          description: 'This invitation is not available to this account.',
          visibility: GroupVisibility.private,
          inviteCode: code,
          inviteExpiresOn: today.add(const Duration(days: 14)),
          members: const [],
          canJoin: false,
        );
    }
    return null;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _InviteRecord {
  const _InviteRecord({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
    required this.inviteCode,
    required this.inviteExpiresOn,
    required this.members,
    required this.canJoin,
  });

  final String id;
  final String name;
  final String description;
  final GroupVisibility visibility;
  final String inviteCode;
  final DateTime inviteExpiresOn;
  final List<GroupMember> members;
  final bool canJoin;
}
