enum GroupVisibility { public, private }

class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    required this.points,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final int points;
  final bool isCurrentUser;
}

class BehtarGroup {
  BehtarGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.visibility,
    required this.inviteCode,
    required this.inviteExpiresOn,
    required List<GroupMember> members,
    required this.isCreator,
    required this.isJoined,
  }) : members = List<GroupMember>.unmodifiable(members);

  final String id;
  final String name;
  final String description;
  final GroupVisibility visibility;
  final String inviteCode;
  final DateTime inviteExpiresOn;
  final List<GroupMember> members;
  final bool isCreator;
  final bool isJoined;

  bool get isPrivate => visibility == GroupVisibility.private;
}

enum GroupInviteResult {
  joined,
  alreadyJoined,
  invalidCode,
  expiredCode,
  accessDenied,
}
