import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../digital_wellbeing/data/app_data.dart';
import '../groups/groups_controller.dart';
import '../groups/groups_screen.dart';
import '../habits/data/habit_store.dart';
import '../settings/settings_controller.dart';
import 'models/dashboard_data.dart';
import 'widgets/dashboard_widgets.dart';
import '../../core/widgets/behtar_progress_bar.dart';
import '../challenges/challenges_controller.dart';
import '../rewards/rewards_store.dart';
import '../../core/notifications/notification_inbox.dart';
import '../notifications/notifications_screen.dart';
import '../../core/utils/date_formatters.dart';

/// What the dashboard is currently showing.
enum _HomeStatus { loading, error, ready }

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({
    this.controller,
    this.onOpenTab,
    this.challengesController,
    super.key,
  });

  /// Shared challenges data (from the navigation shell) for the 7-day card.
  final ChallengesController? challengesController;

  /// Existing profile/settings source used for the greeting and avatar.
  final SettingsController? controller;

  /// Switches the existing bottom-navigation destination (index based).
  final ValueChanged<int>? onOpenTab;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // Indices of the existing bottom navigation destinations.
  static const int _tabHabits = 1;
  static const int _tabChallenges = 2;
  static const int _tabApps = 4;
  static const int _tabProfile = 5;

  _HomeStatus _status = _HomeStatus.ready;
  SettingsController? _listenedController;

  // Owns the Groups data for the "View Group" action so the existing
  // GroupsScreen can be opened directly from Home. Created once and kept
  // stable for this screen's lifetime.
  final GroupsController _groupsController = GroupsController();

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
    HabitStore.instance.addListener(_onHabitsChanged);
    PointsStore.instance.addListener(_onHabitsChanged);
    AppData().addListener(_onHabitsChanged);
    NotificationInbox.instance.addListener(_onHabitsChanged);
    widget.challengesController?.addListener(_onHabitsChanged);
    _refresh();
  }

  @override
  void didUpdateWidget(covariant HomeDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      _detachController();
      _attachController(widget.controller);
    }
  }

  @override
  void dispose() {
    HabitStore.instance.removeListener(_onHabitsChanged);
    PointsStore.instance.removeListener(_onHabitsChanged);
    AppData().removeListener(_onHabitsChanged);
    NotificationInbox.instance.removeListener(_onHabitsChanged);
    widget.challengesController?.removeListener(_onHabitsChanged);
    _detachController();
    _groupsController.dispose();
    super.dispose();
  }

  void _attachController(SettingsController? controller) {
    _listenedController = controller;
    controller?.addListener(_onSettingsChanged);
  }

  void _detachController() {
    _listenedController?.removeListener(_onSettingsChanged);
    _listenedController = null;
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  void _onHabitsChanged() {
    if (mounted) setState(() {});
  }

  /// Loads (or reloads) everything Home shows from Supabase.
  Future<void> _refresh() async {
    final firstLoad = !HabitStore.instance.hasLoaded;
    if (firstLoad) setState(() => _status = _HomeStatus.loading);
    await Future.wait<void>([
      if (widget.controller != null) widget.controller!.load(),
      HabitStore.instance.load(),
      PointsStore.instance.load(),
      NotificationInbox.instance.refresh(),
      AppData().load(),
      if (widget.challengesController != null)
        widget.challengesController!.load(),
    ]);
    if (!mounted) return;
    final failed =
        HabitStore.instance.loadError != null && !HabitStore.instance.hasLoaded;
    setState(() => _status = failed ? _HomeStatus.error : _HomeStatus.ready);
  }

  /// Live dashboard numbers built from the signed-in user's data.
  DashboardData get _liveData {
    final challenge = widget.challengesController?.featuredChallenge;
    final points = PointsStore.instance;
    return DashboardData(
      points: points.balance,
      pointsDelta: points.earnedToday,
      streak: HabitStore.instance.bestStreak,
      focusLabel: '${_totalHabits - _completedCount}',
      screenTimeLabel: '0m',
      screenTimeSubtitle: _trackedLimitMinutes > 0
          ? 'Limit: ${formatMinutes(_trackedLimitMinutes)}'
          : 'No limit set yet',
      challengeName: challenge?.title ?? 'No active challenge',
      challengeProgress: challenge?.completedDays ?? 0,
      challengeTotal: 7,
      challengeReward: challenge == null
          ? 'Join a challenge to earn ${RewardConfig.challengeCompletionBonus} points'
          : '${RewardConfig.challengeCompletionBonus} points',
      completedHabits: _completedCount,
      totalHabits: _totalHabits,
    );
  }

  int get _completedCount =>
      HabitStore.instance.habits.where((habit) => habit.isCompleted).length;

  int get _totalHabits => HabitStore.instance.habits.length;

  double get _progressFraction =>
      _totalHabits == 0 ? 0 : _completedCount / _totalHabits;

  bool get _dayCompleted => _totalHabits > 0 && _completedCount == _totalHabits;

  // Daily Wellness is a habit-progress indicator (not an emotional mood),
  // derived from the same completion counts as Today's Progress.
  String get _wellnessStatus {
    if (_totalHabits == 0) return 'Take It Easy';
    if (_completedCount >= _totalHabits) return 'Great Progress';
    if (_completedCount > 0) return 'Making Progress';
    return 'Take It Easy';
  }

  // Screen Time summary from the shared AppData singleton (the same source the
  // Screen Time screen uses). AppData has no change notifier, so this reflects
  // current values whenever the dashboard rebuilds.
  int get _trackedUsageMinutes => AppData().apps
      .where((app) => app.isTracked)
      .fold(0, (sum, app) => sum + app.usageMinutes);

  int get _trackedLimitMinutes => AppData().apps
      .where((app) => app.isTracked)
      .fold(0, (sum, app) => sum + app.dailyLimitMinutes);


  void _openTab(int index) {
    final callback = widget.onOpenTab;
    if (callback != null) {
      callback(index);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This section is not available here.')),
    );
  }

  // Opens the existing GroupsScreen (the "Groups" list with Create group,
  // Join with code, and Your groups) directly, reusing the existing widget
  // and controller classes without modifying them.
  void _openGroups() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GroupsScreen(
          controller: _groupsController,
          currentUserName: widget.controller?.displayName ?? 'You',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [BehtarColors.mint, BehtarColors.background],
                stops: [0, 0.45],
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                BehtarSpacing.base,
                BehtarSpacing.xs,
                BehtarSpacing.base,
                BehtarSpacing.xl,
              ),
              children: [
                // Slightly narrower, centered header/greeting band; the cards
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BehtarSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: BehtarSpacing.base),
                    ],
                  ),
                ),
                if (_status == _HomeStatus.loading)
                  _buildLoadingState()
                else if (_status == _HomeStatus.error)
                  _buildErrorState()
                else
                  _buildDashboardContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = widget.controller?.fullName.trim() ?? '';
    final displayName = fullName.isNotEmpty
        ? fullName
        : (widget.controller?.displayName ?? 'Friend');
    final initials = _initials(displayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _greetingForTime(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: BehtarColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BehtarColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BehtarSpacing.sm),
            _NotificationBell(
              unread: NotificationInbox.instance.unreadCount,
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      NotificationsScreen(onOpenTab: widget.onOpenTab),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _openTab(_tabProfile),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: BehtarColors.primary,
                child: initials.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: BehtarColors.surface,
                        size: 24,
                      )
                    : Text(
                        initials,
                        style: const TextStyle(
                          color: BehtarColors.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: BehtarSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BehtarSpacing.md,
            vertical: BehtarSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: BehtarColors.mint,
            borderRadius: BorderRadius.circular(BehtarRadii.pill),
          ),
          child: Text(
            'Small Steps, Big Changes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: BehtarColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final data = _liveData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProgressCard(context, data),
        const SizedBox(height: BehtarSpacing.base),
        Row(
          children: [
            _buildStreakCard(context, data),
            const SizedBox(width: BehtarSpacing.base),
            _buildScreenTimeCard(context, data),
          ],
        ),
        const SizedBox(height: BehtarSpacing.base),
        _buildPointsCard(context, data),
        const SizedBox(height: BehtarSpacing.base),
        _buildChallengeCard(context, data),
        const SizedBox(height: BehtarSpacing.lg),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);

    if (_totalHabits == 0) {
      return DashboardSectionCard(
        title: 'Today’s Progress',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.checklist_rounded,
                  color: BehtarColors.sage,
                  size: 28,
                ),
                const SizedBox(width: BehtarSpacing.sm),
                Expanded(
                  child: Text(
                    'No habits yet. Add your first habit to start tracking your day.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: BehtarSpacing.base),
            FilledButton.tonal(
              onPressed: () => _openTab(_tabHabits),
              child: const Text('Add a habit'),
            ),
          ],
        ),
      );
    }

    return DashboardSectionCard(
      title: 'Today’s Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DashboardProgressRing(
                fraction: _progressFraction,
                label: '$_completedCount/$_totalHabits',
              ),
              const SizedBox(width: BehtarSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dayCompleted ? 'All Done Today!' : 'Today’s Habits',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: BehtarSpacing.xs),
                    Text(
                      _dayCompleted
                          ? 'You completed everything. Amazing work!'
                          : 'Keep going!',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BehtarSpacing.base),
          // Two equal-height cards side by side; stacked on very narrow
          // screens so nothing gets squeezed.
          LayoutBuilder(
            builder: (context, constraints) {
              final habitsLeft = DashboardMiniStat(
                label: 'Habits left',
                value: data.focusLabel,
                icon: Icons.pending_actions_rounded,
              );
              final wellness = DashboardMiniStat(
                label: 'Daily Wellness',
                value: _wellnessStatus,
                icon: Icons.mood_rounded,
              );
              if (constraints.maxWidth < 300) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    habitsLeft,
                    const SizedBox(height: BehtarSpacing.sm),
                    wellness,
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: habitsLeft),
                    const SizedBox(width: BehtarSpacing.md),
                    Expanded(child: wellness),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, DashboardData data) {
    return Expanded(
      child: DashboardStatCard(
        icon: Icons.local_fire_department_rounded,
        iconBackground: const Color(0xFFFFF3CD),
        iconColor: Colors.orange.shade700,
        label: 'Streak',
        value: '${data.streak} Days',
        subtitle: _streakSubtitle(data.streak),
      ),
    );
  }

  Widget _buildScreenTimeCard(BuildContext context, DashboardData data) {
    final usage = _trackedUsageMinutes;
    final hasUsage = usage > 0;
    return Expanded(
      child: DashboardStatCard(
        icon: Icons.phone_android_rounded,
        iconBackground: BehtarColors.mint,
        iconColor: BehtarColors.primary,
        label: 'Screen Time',
        value: hasUsage ? formatMinutes(usage) : data.screenTimeLabel,
        subtitle: hasUsage
            ? 'Limit: ${formatMinutes(_trackedLimitMinutes)}'
            : data.screenTimeSubtitle,
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.base),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: BehtarColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: BehtarColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: BehtarSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Points', style: theme.textTheme.bodyMedium),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${data.points}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(width: BehtarSpacing.sm),
                      Flexible(
                        child: Text(
                          '+${data.pointsDelta} today',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: BehtarColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, DashboardData data) {
    final theme = Theme.of(context);
    final challengeFraction = data.challengeTotal == 0
        ? 0.0
        : data.challengeProgress / data.challengeTotal;

    return DashboardSectionCard(
      title: '7-Day Challenge',
      actionLabel: 'Open',
      onAction: () => _openTab(_tabChallenges),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: BehtarColors.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: BehtarColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: BehtarSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.challengeName,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${data.challengeProgress}/${data.challengeTotal} days complete',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BehtarSpacing.base),
          BehtarProgressBar(
            value: challengeFraction,
            semanticsLabel: '7-day challenge progress',
          ),
          const SizedBox(height: BehtarSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: BehtarColors.primary,
                size: 16,
              ),
              const SizedBox(width: BehtarSpacing.xs),
              Expanded(
                child: Text(
                  'Reward: ${data.challengeReward}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: BehtarSpacing.base),
        Row(
          children: [
            DashboardQuickActionTile(
              icon: Icons.add_rounded,
              label: 'Add Habit',
              onTap: () => _openTab(_tabHabits),
            ),
            DashboardQuickActionTile(
              icon: Icons.phone_android_rounded,
              label: 'App Usage',
              onTap: () => _openTab(_tabApps),
            ),
            DashboardQuickActionTile(
              icon: Icons.emoji_events_rounded,
              label: 'Join Challenge',
              onTap: () => _openTab(_tabChallenges),
            ),
            DashboardQuickActionTile(
              icon: Icons.group_rounded,
              label: 'View Group',
              // Opens the existing Groups list screen directly.
              onTap: _openGroups,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const DashboardLoadingCard();
  }

  Widget _buildErrorState() {
    return DashboardStateCard(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong',
      description: 'We could not load your dashboard. Try again in a moment.',
      buttonLabel: 'Retry',
      onButton: _refresh,
    );
  }

  String _initials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final initials = StringBuffer(parts.first[0]);
    if (parts.length > 1) {
      initials.write(parts.last[0]);
    }
    return initials.toString().toUpperCase();
  }

  String _streakSubtitle(int streak) {
    if (streak <= 0) return 'Start your first day';
    if (streak >= 7) return 'You’re on fire!';
    return 'Keep it up!';
  }

  String _greetingForTime() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  }
}


/// Bell with an unread count badge.
class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.unread, required this.onPressed});

  final int unread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: unread > 0 ? 'Notifications ($unread unread)' : 'Notifications',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: unread > 0,
        backgroundColor: BehtarColors.primary,
        label: Text(unread > 9 ? '9+' : '$unread'),
        child: Icon(
          unread > 0
              ? Icons.notifications_rounded
              : Icons.notifications_none_rounded,
        ),
      ),
    );
  }
}
