import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../digital_wellbeing/data/app_data.dart';
import '../groups/groups_controller.dart';
import '../groups/groups_screen.dart';
import '../habits/data/habit_store.dart';
import '../settings/settings_controller.dart';
import 'models/dashboard_data.dart';
import 'widgets/dashboard_widgets.dart';

/// Compile-time switch for the developer-only scenario preview menu.
/// Enable with: --dart-define=dashboard_state_preview=true
const bool _kScenarioPreviewEnabled = bool.fromEnvironment(
  'dashboard_state_preview',
);

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({this.controller, this.onOpenTab, super.key});

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

  DashboardScenario _scenario = DashboardScenario.firstUse;
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
    _showLoadingPreview();
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

  Future<void> _showLoadingPreview() async {
    setState(() => _scenario = DashboardScenario.loading);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _applyScenario(DashboardScenario.firstUse);
  }

  void _applyScenario(DashboardScenario scenario) {
    setState(() => _scenario = scenario);
  }

  void _selectScenario(DashboardScenario scenario) {
    if (scenario == DashboardScenario.loading) {
      _showLoadingPreview();
      return;
    }

    _applyScenario(scenario);
  }

  // Prefer the shared HabitStore singleton so completing a habit on the Habits
  // screen updates this summary; fall back to scenario data when it is empty.
  int get _completedCount {
    final live = HabitStore.instance.habits;
    if (live.isNotEmpty) {
      return live.where((habit) => habit.isCompleted).length;
    }
    return DashboardData.forScenario(_scenario).completedHabits;
  }

  int get _totalHabits {
    final live = HabitStore.instance.habits;
    if (live.isNotEmpty) return live.length;
    return DashboardData.forScenario(_scenario).totalHabits;
  }

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

  String _formatMinutes(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

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
          currentUserName: widget.controller?.fullName.trim().isNotEmpty == true
              ? widget.controller!.fullName.trim()
              : 'Hassan',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _showLoadingPreview,
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
                // below keep the list's original full-width padding.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BehtarSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: BehtarSpacing.sm),
                      _buildGreeting(context),
                      // Equal space above and below centers the greeting
                      // group vertically within the header/greeting section.
                      const SizedBox(height: BehtarSpacing.sm),
                    ],
                  ),
                ),
                if (_scenario == DashboardScenario.loading)
                  _buildLoadingState()
                else if (_scenario == DashboardScenario.error)
                  _buildErrorState()
                else if (_scenario == DashboardScenario.empty)
                  _buildEmptyState()
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
    final fullName = widget.controller?.fullName.trim() ?? '';
    final initials = _initials(fullName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The logo PNG carries wide transparent padding; clip to its central
        // mark so the icon and wordmark read as one cohesive brand lockup.
        ClipRect(
          child: Align(
            alignment: Alignment.center,
            widthFactor: 0.30,
            heightFactor: 0.45,
            child: Image.asset(
              'assets/images/Behtar-Logo.png',
              height: 96,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: BehtarSpacing.xs),
        Expanded(
          child: Text(
            'Behtar',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        if (_kScenarioPreviewEnabled)
          PopupMenuButton<DashboardScenario>(
            tooltip: 'Preview dashboard states',
            icon: const Icon(Icons.tune_rounded),
            onSelected: _selectScenario,
            itemBuilder: (context) => const [
              PopupMenuItem<DashboardScenario>(
                value: DashboardScenario.firstUse,
                child: Text('First use'),
              ),
              PopupMenuItem<DashboardScenario>(
                value: DashboardScenario.completedDay,
                child: Text('Completed day'),
              ),
              PopupMenuItem<DashboardScenario>(
                value: DashboardScenario.empty,
                child: Text('Empty'),
              ),
              PopupMenuItem<DashboardScenario>(
                value: DashboardScenario.loading,
                child: Text('Loading'),
              ),
              PopupMenuItem<DashboardScenario>(
                value: DashboardScenario.error,
                child: Text('Error'),
              ),
            ],
          ),
        const SizedBox(width: BehtarSpacing.xs),
        GestureDetector(
          onTap: () => _openTab(_tabProfile),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: BehtarColors.primary,
            child: initials.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    color: BehtarColors.surface,
                    size: 22,
                  )
                : Text(
                    initials,
                    style: const TextStyle(
                      color: BehtarColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_greetingForTime()},',
            textAlign: TextAlign.start,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(
            '${_firstName()}! 👋',
            textAlign: TextAlign.start,
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: BehtarSpacing.xs),
          Text(
            'Small steps. Big changes.',
            textAlign: TextAlign.start,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final data = DashboardData.forScenario(_scenario);

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
                      _dayCompleted ? 'All Done Today!' : 'Habits Completed',
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
          Row(
            children: [
              DashboardMiniStat(
                label: 'Focus time',
                value: data.focusLabel,
                icon: Icons.timer_rounded,
              ),
              const SizedBox(width: BehtarSpacing.base),
              DashboardMiniStat(
                label: 'Daily Wellness',
                value: _wellnessStatus,
                icon: Icons.mood_rounded,
              ),
            ],
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
        value: hasUsage ? _formatMinutes(usage) : data.screenTimeLabel,
        subtitle: hasUsage
            ? 'Limit: ${_formatMinutes(_trackedLimitMinutes)}'
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
          LinearProgressIndicator(
            value: challengeFraction,
            minHeight: 10,
            color: BehtarColors.secondary,
            backgroundColor: BehtarColors.mint,
            borderRadius: BorderRadius.circular(BehtarRadii.pill),
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
              label: 'View Screen Time',
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

  Widget _buildEmptyState() {
    return DashboardStateCard(
      icon: Icons.checklist_rounded,
      title: 'No habits started yet',
      description:
          'Start with a small habit, then come back here to track your momentum.',
      buttonLabel: 'Add a habit',
      onButton: () => _openTab(_tabHabits),
    );
  }

  Widget _buildErrorState() {
    return DashboardStateCard(
      icon: Icons.error_outline_rounded,
      title: 'Something went wrong',
      description: 'We could not load your dashboard. Try again in a moment.',
      buttonLabel: 'Retry',
      onButton: _showLoadingPreview,
    );
  }

  String _firstName() {
    final fullName = widget.controller?.fullName.trim() ?? '';
    if (fullName.isEmpty) return 'there';
    return fullName.split(RegExp(r'\s+')).first;
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
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}
