import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/settings/settings_widgets.dart';
import 'challenge.dart';
import 'challenges_controller.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({required this.controller, super.key});

  final ChallengesController controller;

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
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
          title: 'Challenges',
          actions: [
            IconButton(
              tooltip: 'Create challenge',
              onPressed: _openCreate,
              icon: const Icon(Icons.add_rounded),
            ),
            const SizedBox(width: BehtarSpacing.xs),
          ],
          children: [
            Text(
              'Small steps are easier together.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: BehtarSpacing.lg),
            FilledButton.icon(
              onPressed: _openCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create a challenge'),
            ),
            const SizedBox(height: BehtarSpacing.xl),
            if (controller.isLoading)
              const _ChallengeStateCard(
                icon: Icons.hourglass_top_rounded,
                title: 'Loading challenges',
                message: 'A moment while we get your week ready.',
                showProgress: true,
              )
            else if (controller.loadError != null)
              _ChallengeStateCard(
                icon: Icons.refresh_rounded,
                title: 'Challenges aren’t available',
                message: controller.loadError!,
                action: TextButton.icon(
                  onPressed: controller.load,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again'),
                ),
              )
            else if (controller.challenges.isEmpty)
              _ChallengeStateCard(
                icon: Icons.emoji_events_outlined,
                title: 'Your next small win starts here',
                message:
                    'Create a 7-day challenge or join one to build a habit '
                    'at your own pace.',
                action: FilledButton(
                  onPressed: _openCreate,
                  child: const Text('Create a challenge'),
                ),
              )
            else ...[
              const SettingsSectionTitle('7-day challenges'),
              for (final challenge in controller.challenges) ...[
                _ChallengeCard(
                  challenge: challenge,
                  onTap: () => _openDetails(challenge),
                  onAction: () => _openDetails(challenge),
                ),
                const SizedBox(height: BehtarSpacing.md),
              ],
            ],
          ],
        );
      },
    );
  }

  Future<void> _openCreate() async {
    final challenge = await Navigator.of(context).push<Challenge>(
      MaterialPageRoute<Challenge>(
        builder: (_) => CreateChallengeScreen(controller: widget.controller),
      ),
    );
    if (challenge != null && mounted) {
      showSettingsMessage(
        context,
        challenge.isPrivate
            ? 'Your private 7-day challenge is ready.'
            : 'Your public 7-day challenge is ready to join.',
      );
    }
  }

  void _openDetails(Challenge challenge) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChallengeDetailsScreen(
          controller: widget.controller,
          challengeId: challenge.id,
        ),
      ),
    );
  }
}

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({required this.controller, super.key});

  final ChallengesController controller;

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  static const _goals = [
    '10 minutes of mindfulness',
    'Drink 8 glasses of water',
    'Take a 20-minute walk',
    'Read for 15 minutes',
    'Take a screen-free evening',
  ];
  static const _customGoal = 'Custom / Add your own';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customGoalController = TextEditingController();
  late DateTime _startsOn;
  late final TextEditingController _startDateController;
  String? _selectedGoal;
  ChallengeVisibility _visibility = ChallengeVisibility.public;
  bool _showPreview = false;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _startsOn = _dateOnly(DateTime.now());
    _startDateController = TextEditingController(text: _formatDate(_startsOn));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customGoalController.dispose();
    _startDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _showPreview
        ? Challenge(
            id: 'preview',
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            goal: _goalValue,
            startsOn: _startsOn,
            isJoined: false,
            participantCount: 0,
            dailyProgress: List<double>.filled(7, 0),
            visibility: _visibility,
            isCreator: true,
          )
        : null;

    return SettingsPage(
      title: 'Create challenge',
      children: [
        Text(
          'Choose one small habit to practice for a week.',
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
                  controller: _titleController,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Challenge title',
                    hintText: 'e.g. Mindful mornings',
                  ),
                  validator: (value) {
                    final title = value?.trim() ?? '';
                    if (title.isEmpty) return 'Enter a challenge title.';
                    if (title.length < 3) {
                      return 'Use at least 3 characters.';
                    }
                    return null;
                  },
                  onChanged: (_) => _invalidatePreview(),
                ),
                const SizedBox(height: BehtarSpacing.base),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 280,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What will make this week meaningful?',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    final description = value?.trim() ?? '';
                    if (description.isEmpty) {
                      return 'Add a short description.';
                    }
                    if (description.length < 8) {
                      return 'Use at least 8 characters.';
                    }
                    return null;
                  },
                  onChanged: (_) => _invalidatePreview(),
                ),
                const SizedBox(height: BehtarSpacing.base),
                const SettingsSectionTitle('Habit or goal'),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedGoal,
                  decoration: const InputDecoration(
                    labelText: 'Choose a habit or goal',
                  ),
                  items: [
                    ..._goals.map(
                      (goal) => DropdownMenuItem(
                        value: goal,
                        child: Text(goal, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: _customGoal,
                      child: Text(_customGoal),
                    ),
                  ],
                  validator: (value) =>
                      value == null ? 'Choose a habit or goal.' : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedGoal = value;
                      _showPreview = false;
                      _saveError = null;
                    });
                  },
                ),
                if (_selectedGoal == _customGoal) ...[
                  const SizedBox(height: BehtarSpacing.md),
                  TextFormField(
                    controller: _customGoalController,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Your custom habit or goal',
                      hintText: 'e.g. Stretch for 10 minutes',
                    ),
                    validator: (value) {
                      if (_selectedGoal != _customGoal) return null;
                      final customGoal = value?.trim() ?? '';
                      if (customGoal.isEmpty) {
                        return 'Enter your custom habit or goal.';
                      }
                      if (customGoal.length < 3) {
                        return 'Use at least 3 characters.';
                      }
                      return null;
                    },
                    onChanged: (_) => _invalidatePreview(),
                  ),
                ],
                const SizedBox(height: BehtarSpacing.lg),
                const SettingsSectionTitle('Start date'),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Challenge starts',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  validator: (_) {
                    if (_startsOn.isBefore(_dateOnly(DateTime.now()))) {
                      return 'Choose today or a future date.';
                    }
                    return null;
                  },
                  onTap: _selectStartDate,
                ),
                const SizedBox(height: BehtarSpacing.xs),
                Text(
                  'Ends ${_formatDate(_startsOn.add(const Duration(days: 6)))} '
                  '· 7 days',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: BehtarSpacing.lg),
                const SettingsSectionTitle('Visibility'),
                RadioGroup<ChallengeVisibility>(
                  groupValue: _visibility,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _visibility = value;
                      _showPreview = false;
                      _saveError = null;
                    });
                  },
                  child: Column(
                    children: [
                      RadioListTile<ChallengeVisibility>(
                        value: ChallengeVisibility.public,
                        title: const Text('Public'),
                        subtitle: const Text(
                          'Visible and open for others to join.',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<ChallengeVisibility>(
                        value: ChallengeVisibility.private,
                        title: const Text('Private'),
                        subtitle: const Text(
                          'Only you and invited participants can access it.',
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
        const SizedBox(height: BehtarSpacing.lg),
        if (_saveError != null) ...[
          _InlineError(message: _saveError!),
          const SizedBox(height: BehtarSpacing.md),
        ],
        if (preview != null) ...[
          const SettingsSectionTitle('Your challenge preview'),
          _ChallengeCard(challenge: preview),
          const SizedBox(height: BehtarSpacing.lg),
          FilledButton(
            onPressed: _isSaving ? null : _saveChallenge,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BehtarColors.surface,
                    ),
                  )
                : const Text('Save challenge'),
          ),
          const SizedBox(height: BehtarSpacing.sm),
          TextButton(
            onPressed: _isSaving
                ? null
                : () => setState(() => _showPreview = false),
            child: const Text('Edit details'),
          ),
        ] else
          FilledButton(
            onPressed: _isSaving ? null : _previewChallenge,
            child: const Text('Preview challenge'),
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

  void _previewChallenge() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _showPreview = true;
      _saveError = null;
    });
  }

  Future<void> _saveChallenge() async {
    setState(() => _isSaving = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final challenge = widget.controller.createChallenge(
        title: _titleController.text,
        description: _descriptionController.text,
        goal: _goalValue,
        startsOn: _startsOn,
        visibility: _visibility,
      );
      if (mounted) Navigator.of(context).pop(challenge);
    } on ArgumentError catch (error) {
      setState(() => _saveError = error.message.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _goalValue => _selectedGoal == _customGoal
      ? _customGoalController.text.trim()
      : _selectedGoal!;

  Future<void> _selectStartDate() async {
    final today = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsOn.isBefore(today) ? today : _startsOn,
      firstDate: today,
      lastDate: DateTime(today.year + 10, today.month, today.day),
      helpText: 'Choose a challenge start date',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _startsOn = _dateOnly(picked);
      _startDateController.text = _formatDate(_startsOn);
      _showPreview = false;
      _saveError = null;
    });
  }
}

class ChallengeDetailsScreen extends StatelessWidget {
  const ChallengeDetailsScreen({
    required this.controller,
    required this.challengeId,
    super.key,
  });

  final ChallengesController controller;
  final String challengeId;

  @override
  Widget build(BuildContext context) {
    final weekKey = GlobalKey();
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final challenge = controller.challengeById(challengeId);
        if (challenge == null || !challenge.canAccess) {
          return SettingsPage(
            title: 'Challenge details',
            children: const [
              _ChallengeStateCard(
                icon: Icons.search_off_rounded,
                title: 'Challenge not found',
                message: 'Return to the list to choose another challenge.',
              ),
            ],
          );
        }

        return SettingsPage(
          title: 'Challenge details',
          children: [
            _ChallengeOverview(challenge: challenge),
            const SizedBox(height: BehtarSpacing.lg),
            if (challenge.isComplete) ...[
              const _CompletionBanner(),
              const SizedBox(height: BehtarSpacing.lg),
            ],
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        color: BehtarColors.primary,
                      ),
                      const SizedBox(width: BehtarSpacing.sm),
                      Expanded(
                        child: Text(
                          '${challenge.participantCount} people taking part',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _ParticipationBadge(challenge: challenge),
                    ],
                  ),
                  const SizedBox(height: BehtarSpacing.lg),
                  _OverallProgress(challenge: challenge),
                  const SizedBox(height: BehtarSpacing.sm),
                  Text(
                    '${challenge.completedDays} of 7 days complete',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.xl),
            SettingsSectionTitle('Your week', key: weekKey),
            SettingsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var day = 0; day < 7; day++) ...[
                    _DayProgressRow(
                      dayNumber: day + 1,
                      date: challenge.startsOn.add(Duration(days: day)),
                      progress: challenge.dailyProgress[day],
                      isEnabled:
                          challenge.isJoined &&
                          challenge.dailyProgress[day] < 1 &&
                          !challenge.startsOn
                              .add(Duration(days: day))
                              .isAfter(_dateOnly(DateTime.now())),
                      onPressed: () => _logProgress(context, challenge, day),
                    ),
                    if (day < 6)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: BehtarSpacing.base,
                        ),
                        child: Divider(height: 1),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: BehtarSpacing.lg),
            if (!challenge.isJoined)
              FilledButton(
                onPressed:
                    challenge.statusAt(DateTime.now()) ==
                        ChallengeScheduleStatus.ended
                    ? null
                    : () => _confirmJoin(context, challenge),
                child: Text(
                  challenge.statusAt(DateTime.now()) ==
                          ChallengeScheduleStatus.ended
                      ? 'Challenge ended'
                      : challenge.isCreator && challenge.isPrivate
                      ? 'Start private challenge'
                      : 'Join challenge',
                ),
              )
            else if (challenge.isComplete)
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Challenge complete'),
              )
            else ...[
              FilledButton(
                onPressed: () => _continueToProgress(context, weekKey),
                child: const Text('Continue challenge'),
              ),
              const SizedBox(height: BehtarSpacing.sm),
              TextButton(
                onPressed: () => _confirmLeave(context, challenge),
                child: const Text('Leave challenge'),
              ),
            ],
          ],
        );
      },
    );
  }

  void _continueToProgress(BuildContext context, GlobalKey weekKey) {
    final weekContext = weekKey.currentContext;
    if (weekContext == null) return;
    Scrollable.ensureVisible(
      weekContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _confirmJoin(BuildContext context, Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.emoji_events_outlined,
          color: BehtarColors.primary,
        ),
        title: Text(
          challenge.isCreator && challenge.isPrivate
              ? 'Start your private challenge?'
              : 'Join this challenge?',
        ),
        content: Text(
          'You’ll spend 7 days working on “${challenge.goal}”. You can leave '
          'whenever you need to.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              challenge.isCreator && challenge.isPrivate
                  ? 'Start challenge'
                  : 'Join challenge',
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      controller.join(challenge.id);
      showSettingsMessage(context, 'You joined the 7-day challenge.');
    }
  }

  Future<void> _confirmLeave(BuildContext context, Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.exit_to_app_rounded,
          color: BehtarColors.primary,
        ),
        title: const Text('Leave this challenge?'),
        content: const Text(
          'Your progress will be saved on this device if you decide to join '
          'again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave challenge'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      controller.leave(challenge.id);
      showSettingsMessage(context, 'You left the challenge.');
    }
  }

  Future<void> _logProgress(
    BuildContext context,
    Challenge before,
    int day,
  ) async {
    if (!before.isJoined ||
        before.dailyProgress[day] >= 1 ||
        before.startsOn.add(Duration(days: day)).isAfter(
          _dateOnly(DateTime.now()),
        )) {
      return;
    }
    controller.addDailyProgress(before.id, day);
    final updated = controller.challengeById(before.id);
    if (updated?.isComplete == true && !before.isComplete && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.celebration_rounded,
            color: BehtarColors.primary,
            size: 36,
          ),
          title: const Text('A week well spent'),
          content: const Text(
            'You completed all 7 days. Celebrate this small step and keep '
            'building on it.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } else if (context.mounted) {
      showSettingsMessage(context, 'Day ${day + 1} progress updated.');
    }
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, this.onTap, this.onAction});

  final Challenge challenge;
  final VoidCallback? onTap;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = challenge.isComplete
        ? 'Completed'
        : challenge.isJoined
        ? 'Continue'
        : challenge.isCreator && challenge.isPrivate
        ? 'Start private challenge'
        : 'Join';
    return SettingsCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BehtarSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: BehtarColors.mint,
                    foregroundColor: BehtarColors.primary,
                    child: Icon(Icons.emoji_events_outlined),
                  ),
                  const SizedBox(width: BehtarSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: BehtarSpacing.xs),
                        Text(
                          challenge.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BehtarSpacing.base),
              Wrap(
                spacing: BehtarSpacing.sm,
                runSpacing: BehtarSpacing.xs,
                children: [
                  _ChallengeStatusTag(challenge: challenge),
                  _ChallengeVisibilityTag(challenge: challenge),
                ],
              ),
              const SizedBox(height: BehtarSpacing.base),
              _ChallengeMeta(icon: Icons.flag_outlined, label: challenge.goal),
              const SizedBox(height: BehtarSpacing.sm),
              _ChallengeMeta(
                icon: Icons.calendar_month_outlined,
                label:
                    '${_formatDate(challenge.startsOn)} – '
                    '${_formatDate(challenge.endsOn)} · 7 days',
              ),
              const SizedBox(height: BehtarSpacing.md),
              Row(
                children: [
                  Expanded(child: _ParticipationBadge(challenge: challenge)),
                  Text(
                    '${challenge.participantCount} people',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (challenge.isJoined) ...[
                const SizedBox(height: BehtarSpacing.md),
                _OverallProgress(challenge: challenge),
                const SizedBox(height: BehtarSpacing.xs),
                Text(
                  '${(challenge.progress * 100).round()}% complete',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
              if (onAction != null) ...[
                const SizedBox(height: BehtarSpacing.md),
                FilledButton(onPressed: onAction, child: Text(actionLabel)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeOverview extends StatelessWidget {
  const _ChallengeOverview({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      padding: const EdgeInsets.all(BehtarSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: BehtarSpacing.sm),
          Text(challenge.description),
          const SizedBox(height: BehtarSpacing.lg),
          _ChallengeMeta(icon: Icons.flag_outlined, label: challenge.goal),
          const SizedBox(height: BehtarSpacing.sm),
          _ChallengeMeta(
            icon: Icons.calendar_month_outlined,
            label:
                '${_formatDate(challenge.startsOn)} – '
                '${_formatDate(challenge.endsOn)} · 7 days',
          ),
          const SizedBox(height: BehtarSpacing.md),
          Wrap(
            spacing: BehtarSpacing.sm,
            runSpacing: BehtarSpacing.xs,
            children: [
              _ChallengeStatusTag(challenge: challenge),
              _ChallengeVisibilityTag(challenge: challenge),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChallengeStatusTag extends StatelessWidget {
  const _ChallengeStatusTag({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final status = challenge.statusAt(DateTime.now());
    final label = switch (status) {
      ChallengeScheduleStatus.upcoming => 'Upcoming',
      ChallengeScheduleStatus.active => 'Active',
      ChallengeScheduleStatus.completed => 'Completed',
      ChallengeScheduleStatus.ended => 'Ended',
    };
    final icon = switch (status) {
      ChallengeScheduleStatus.upcoming => Icons.schedule_rounded,
      ChallengeScheduleStatus.active => Icons.play_circle_outline_rounded,
      ChallengeScheduleStatus.completed => Icons.check_circle_outline_rounded,
      ChallengeScheduleStatus.ended => Icons.event_busy_outlined,
    };
    return _ChallengeTag(icon: icon, label: label);
  }
}

class _ChallengeVisibilityTag extends StatelessWidget {
  const _ChallengeVisibilityTag({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return _ChallengeTag(
      icon: challenge.isPrivate ? Icons.lock_outline_rounded : Icons.public_rounded,
      label: challenge.isPrivate ? 'Private' : 'Public',
    );
  }
}

class _ChallengeTag extends StatelessWidget {
  const _ChallengeTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BehtarColors.mint,
        border: Border.all(color: BehtarColors.border),
        borderRadius: BorderRadius.circular(BehtarRadii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BehtarSpacing.sm,
          vertical: BehtarSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: BehtarColors.primary),
            const SizedBox(width: BehtarSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: BehtarColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeMeta extends StatelessWidget {
  const _ChallengeMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: BehtarColors.primary),
        const SizedBox(width: BehtarSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ParticipationBadge extends StatelessWidget {
  const _ParticipationBadge({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final label = challenge.isComplete
        ? 'Completed'
        : challenge.isJoined
        ? 'You’re taking part'
        : challenge.isCreator
        ? 'Created by you'
        : 'Open to join';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          challenge.isComplete
              ? Icons.check_circle_outline_rounded
              : challenge.isJoined
              ? Icons.play_circle_outline_rounded
              : Icons.groups_outlined,
          size: 18,
          color: BehtarColors.primary,
        ),
        const SizedBox(width: BehtarSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: BehtarColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverallProgress extends StatelessWidget {
  const _OverallProgress({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BehtarRadii.pill),
      child: LinearProgressIndicator(
        value: challenge.progress,
        minHeight: 8,
        backgroundColor: BehtarColors.border,
        valueColor: const AlwaysStoppedAnimation<Color>(BehtarColors.secondary),
      ),
    );
  }
}

class _DayProgressRow extends StatelessWidget {
  const _DayProgressRow({
    required this.dayNumber,
    required this.date,
    required this.progress,
    required this.isEnabled,
    required this.onPressed,
  });

  final int dayNumber;
  final DateTime date;
  final double progress;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dayComplete = progress >= 1;
    final progressText = dayComplete
        ? 'Complete'
        : progress > 0
        ? 'Halfway'
        : 'Not started';
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: BehtarSpacing.base,
        vertical: BehtarSpacing.sm,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: dayComplete
                ? BehtarColors.mint
                : BehtarColors.background,
            foregroundColor: BehtarColors.primary,
            child: dayComplete
                ? const Icon(Icons.check_rounded, size: 20)
                : Text('$dayNumber'),
          ),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayNumber',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_formatDate(date)} · $progressText',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (isEnabled)
            TextButton(
              onPressed: onPressed,
              child: Text(progress > 0 ? 'Finish day' : 'Log progress'),
            )
          else if (progress == 0)
            const Icon(Icons.lock_outline_rounded, color: BehtarColors.sage)
          else
            Text(
              'Done',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: BehtarColors.primary),
            ),
        ],
      ),
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner();

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: BehtarColors.mint,
            foregroundColor: BehtarColors.primary,
            child: Icon(Icons.celebration_rounded),
          ),
          const SizedBox(width: BehtarSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You did it!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: BehtarSpacing.xs),
                Text(
                  'Seven days of small steps add up to something meaningful.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeStateCard extends StatelessWidget {
  const _ChallengeStateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.showProgress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: BehtarColors.mint,
            foregroundColor: BehtarColors.primary,
            child: showProgress
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BehtarColors.primary,
                    ),
                  )
                : Icon(icon, size: 26),
          ),
          const SizedBox(height: BehtarSpacing.base),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: BehtarSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: BehtarColors.primary),
          const SizedBox(width: BehtarSpacing.sm),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
