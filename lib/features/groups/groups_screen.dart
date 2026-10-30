import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatters.dart';
import '../../features/settings/settings_widgets.dart';
import 'group.dart';
import 'groups_controller.dart';
import 'leaderboard.dart';
import 'widgets/group_widgets.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({
    required this.controller,
    this.currentUserName = 'Hassan',
    super.key,
  });

  final GroupsController controller;
  final String currentUserName;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        return SettingsPage(
          title: 'Groups',
          actions: [
            IconButton(
              tooltip: 'Join a group',
              onPressed: _joinWithCode,
              icon: const Icon(Icons.group_add_outlined),
            ),
            IconButton(
              tooltip: 'Create group',
              onPressed: _createGroup,
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(width: BehtarSpacing.xs),
          ],
          children: [
            Text(
              'Build better habits together.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: BehtarSpacing.lg),
            Wrap(
              spacing: BehtarSpacing.sm,
              runSpacing: BehtarSpacing.sm,
              children: [
                FilledButton.icon(
                  onPressed: _createGroup,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create group'),
                ),
                OutlinedButton.icon(
                  onPressed: _joinWithCode,
                  icon: const Icon(Icons.key_rounded),
                  label: const Text('Join with code'),
                ),
              ],
            ),
            const SizedBox(height: BehtarSpacing.xl),
            if (controller.isLoading)
              const GroupStateCard(
                icon: Icons.hourglass_top_rounded,
                title: 'Loading your groups',
                message: 'A moment while we get your community ready.',
                isLoading: true,
              )
            else if (controller.loadError != null)
              GroupStateCard(
                icon: Icons.refresh_rounded,
                title: 'Groups aren’t available',
                message: controller.loadError!,
                action: TextButton.icon(
                  onPressed: controller.load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              )
            else if (controller.joinedGroups.isEmpty)
              GroupStateCard(
                icon: Icons.groups_outlined,
                title: 'Find your people',
                message:
                    'Create a group or join with an invite code to encourage '
                    'each other along the way.',
                action: Wrap(
                  spacing: BehtarSpacing.sm,
                  children: [
                    FilledButton(
                      onPressed: _createGroup,
                      child: const Text('Create group'),
                    ),
                    TextButton(
                      onPressed: _joinWithCode,
                      child: const Text('Join a group'),
                    ),
                  ],
                ),
              )
            else ...[
              SettingsSectionTitle(
                'Your groups (${controller.joinedGroups.length})',
              ),
              for (final group in controller.joinedGroups) ...[
                GroupCard(group: group, onTap: () => _openGroup(group)),
                const SizedBox(height: BehtarSpacing.md),
              ],
            ],
            const SizedBox(height: BehtarSpacing.sm),
            Text(
              'Group activity and points are sample data stored on this device.',
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  Future<void> _createGroup() async {
    final group = await Navigator.of(context).push<BehtarGroup>(
      MaterialPageRoute<BehtarGroup>(
        builder: (_) => CreateGroupScreen(
          controller: widget.controller,
          creatorName: widget.currentUserName,
        ),
      ),
    );
    if (group != null && mounted) {
      showSettingsMessage(context, '“${group.name}” is ready for your group.');
      _openGroup(group);
    }
  }

  Future<void> _joinWithCode() async {
    final result = await Navigator.of(context).push<GroupInviteResult>(
      MaterialPageRoute<GroupInviteResult>(
        builder: (_) => JoinGroupScreen(
          controller: widget.controller,
          memberName: widget.currentUserName,
        ),
      ),
    );
    if (!mounted || result == null) return;
    switch (result) {
      case GroupInviteResult.joined:
        showSettingsMessage(context, 'You joined the group.');
      case GroupInviteResult.alreadyJoined:
        showSettingsMessage(context, 'You’re already in this group.');
      case GroupInviteResult.invalidCode:
        break;
      case GroupInviteResult.expiredCode:
        break;
      case GroupInviteResult.accessDenied:
        break;
    }
  }

  void _openGroup(BehtarGroup group) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GroupDetailsScreen(
          controller: widget.controller,
          groupId: group.id,
        ),
      ),
    );
  }
}

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({
    required this.controller,
    required this.memberName,
    super.key,
  });

  final GroupsController controller;
  final String memberName;

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  GroupInviteResult? _error;
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Join a group',
      children: [
        Text(
          'Enter the invite code shared by a group member.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 12,
                  decoration: const InputDecoration(
                    labelText: 'Invite code',
                    hintText: 'e.g. OPEN42',
                  ),
                  validator: (value) => value == null || value.trim().length < 4
                      ? 'Enter a valid invite code.'
                      : null,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                const SizedBox(height: BehtarSpacing.sm),
                Text(
                  'Demo codes: OPEN42 (public), INVITE7 (private), '
                  'EXPIRED7, DENIED7.',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (_error != null) ...[
                  const SizedBox(height: BehtarSpacing.md),
                  InviteError(result: _error!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: BehtarSpacing.lg),
        FilledButton(
          onPressed: _isJoining ? null : _join,
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: BehtarColors.surface,
                  ),
                )
              : const Text('Join group'),
        ),
      ],
    );
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isJoining = true);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    final result = widget.controller.joinWithInviteCode(
      _codeController.text,
      memberName: widget.memberName,
    );
    if (result == GroupInviteResult.joined ||
        result == GroupInviteResult.alreadyJoined) {
      Navigator.pop(context, result);
      return;
    }
    setState(() {
      _error = result;
      _isJoining = false;
    });
  }
}

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    required this.controller,
    required this.creatorName,
    super.key,
  });

  final GroupsController controller;
  final String creatorName;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  GroupVisibility _visibility = GroupVisibility.public;
  bool _showPreview = false;
  String? _saveError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: 'Create group',
      children: [
        Text(
          'Create a supportive space for shared progress.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: BehtarSpacing.lg),
        SettingsCard(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    hintText: 'e.g. Mindful Mornings',
                  ),
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.length < 3) {
                      return 'Enter a name with at least 3 characters.';
                    }
                    if (name.length > 40) {
                      return 'Name must be 40 characters or fewer.';
                    }
                    return null;
                  },
                  onChanged: (_) => _invalidatePreview(),
                ),
                const SizedBox(height: BehtarSpacing.base),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 240,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'About this group',
                    hintText: 'What brings your members together?',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    final description = value?.trim() ?? '';
                    if (description.length < 8) {
                      return 'Add at least 8 characters about this group.';
                    }
                    if (description.length > 240) {
                      return 'Description must be 240 characters or fewer.';
                    }
                    return null;
                  },
                  onChanged: (_) => _invalidatePreview(),
                ),
                const SizedBox(height: BehtarSpacing.lg),
                const SettingsSectionTitle('Who can access this group?'),
                RadioGroup<GroupVisibility>(
                  groupValue: _visibility,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _visibility = value;
                      _showPreview = false;
                    });
                  },
                  child: Column(
                    children: [
                      RadioListTile<GroupVisibility>(
                        value: GroupVisibility.public,
                        title: const Text('Public group'),
                        subtitle: const Text(
                          'Members can join using an invite code.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<GroupVisibility>(
                        value: GroupVisibility.private,
                        title: const Text('Private group'),
                        subtitle: const Text(
                          'Share the invite code with people you choose.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_saveError != null) ...[
          const SizedBox(height: BehtarSpacing.md),
          GroupInlineMessage(message: _saveError!),
        ],
        const SizedBox(height: BehtarSpacing.lg),
        if (_showPreview) ...[
          const SettingsSectionTitle('Group preview'),
          GroupCard(
            group: BehtarGroup(
              id: 'preview',
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              visibility: _visibility,
              inviteCode: 'PREVIEW',
              inviteExpiresOn: DateTime.now().add(const Duration(days: 30)),
              members: [
                GroupMember(
                  id: 'current-user',
                  name: widget.creatorName,
                  points: 0,
                  isCurrentUser: true,
                ),
              ],
              isCreator: true,
              isJoined: true,
            ),
          ),
          const SizedBox(height: BehtarSpacing.lg),
          FilledButton(
            onPressed: _saveGroup,
            child: const Text('Create group'),
          ),
          const SizedBox(height: BehtarSpacing.sm),
          TextButton(
            onPressed: () => setState(() => _showPreview = false),
            child: const Text('Edit details'),
          ),
        ] else
          FilledButton(
            onPressed: _previewGroup,
            child: const Text('Preview group'),
          ),
      ],
    );
  }

  void _invalidatePreview() {
    if (_showPreview || _saveError != null) {
      setState(() {
        _showPreview = false;
        _saveError = null;
      });
    }
  }

  void _previewGroup() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _showPreview = true;
      _saveError = null;
    });
  }

  void _saveGroup() {
    try {
      final group = widget.controller.createGroup(
        name: _nameController.text,
        description: _descriptionController.text,
        visibility: _visibility,
        creatorName: widget.creatorName,
      );
      Navigator.of(context).pop(group);
    } on ArgumentError catch (error) {
      setState(() => _saveError = error.message.toString());
    }
  }
}

class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({
    required this.controller,
    required this.groupId,
    super.key,
  });

  final GroupsController controller;
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final group = controller.groupById(groupId);
        if (group == null || !group.isJoined) {
          return const SettingsPage(
            title: 'Group details',
            children: [
              GroupStateCard(
                icon: Icons.lock_outline_rounded,
                title: 'Access unavailable',
                message: 'This group is no longer available to your account.',
              ),
            ],
          );
        }
        return SettingsPage(
          title: 'Group details',
          children: [
            SettingsCard(
              padding: const EdgeInsets.all(BehtarSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: BehtarSpacing.sm),
                  Text(group.description),
                  const SizedBox(height: BehtarSpacing.lg),
                  Wrap(
                    spacing: BehtarSpacing.sm,
                    runSpacing: BehtarSpacing.sm,
                    children: [
                      GroupStatusTag(
                        icon: group.isPrivate
                            ? Icons.lock_outline_rounded
                            : Icons.public_rounded,
                        label: group.isPrivate
                            ? 'Private group'
                            : 'Public group',
                      ),
                      GroupStatusTag(
                        icon: group.isCreator
                            ? Icons.admin_panel_settings_outlined
                            : Icons.verified_user_outlined,
                        label: group.isCreator
                            ? 'You’re an admin'
                            : 'Member access',
                      ),
                    ],
                  ),
                  const SizedBox(height: BehtarSpacing.md),
                  Text(
                    '${group.members.length} members · Joined group',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Invite members',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: BehtarSpacing.xs),
                  Text(
                    group.isPrivate
                        ? 'Share this code only with people you invite.'
                        : 'Share this code so others can find your group.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: BehtarSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          group.inviteCode,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: BehtarColors.primary),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy invite code',
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: group.inviteCode),
                          );
                          if (context.mounted) {
                            showSettingsMessage(context, 'Invite code copied.');
                          }
                        },
                        icon: const Icon(
                          Icons.content_copy_rounded,
                          color: BehtarColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Invite code expires ${formatDate(group.inviteExpiresOn)}.',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.xl),
            SettingsCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      BehtarSpacing.base,
                      BehtarSpacing.base,
                      BehtarSpacing.base,
                      BehtarSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.leaderboard_outlined,
                          color: BehtarColors.primary,
                        ),
                        const SizedBox(width: BehtarSpacing.sm),
                        Expanded(
                          child: Text(
                            'Leaderboard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          'Progress points',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  GroupLeaderboard(members: group.members),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
