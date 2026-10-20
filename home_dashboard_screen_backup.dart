import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../settings/settings_controller.dart';

/// Compile-time switch for the developer-only scenario preview menu.
/// Enable with: --dart-define=dashboard_state_preview=true
const bool _kScenarioPreviewEnabled =
    bool.fromEnvironment('dashboard_state_preview');

enum DashboardScenario {
  firstUse,
  completedDay,
  empty,
  loading,
  error,
}

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
  List<_HabitEntry> _habits = const [];

  @override
  void initState() {
    super.initState();
    _showLoadingPreview();
  }

  Future<void> _showLoadingPreview() async {
    setState(() => _scenario = DashboardScenario.loading);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _applyScenario(DashboardScenario.firstUse);
  }

  void _applyScenario(DashboardScenario scenario) {
    setState(() {
      _scenario = scenario;
      _habits = List<_HabitEntry>.of(_dashboardDataFor(scenario).habits);
    });
  }

  void _selectScenario(DashboardScenario scenario) {
    if (scenario == DashboardScenario.loading) {
      _showLoadingPreview();
      return;
    }

    _applyScenario(scenario);
  }

  void _toggleHabit(int index) {
    setState(() {
      final habit = _habits[index];
      _habits[index] = _HabitEntry(
        title: habit.title,
        subtitle: habit.subtitle,
        icon: habit.icon,
        completed: !habit.completed,
      );
    });
  }

  int get _completedCount => _habits.where((habit) => habit.completed).length;

  double get _progressFraction =>
      _habits.isEmpty ? 0 : _completedCount / _habits.length;

  bool get _dayCompleted =>
      _habits.isNotEmpty && _completedCount == _habits.length;

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
                BehtarSpacing.base,
                BehtarSpacing.base,
                BehtarSpacing.xl,
              ),
              children: [
                _buildHeader(context),
                const SizedBox(height: BehtarSpacing.lg),
                _buildGreeting(context),
                const SizedBox(height: BehtarSpacing.lg),
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
      children: [
        const Icon(Icons.eco_rounded, color: BehtarColors.primary, size: 30),
        const SizedBox(width: BehtarSpacing.sm),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_greetingForTime()},', style: theme.textTheme.titleMedium),
        const SizedBox(height: BehtarSpacing.xs),
        Text('${_firstName()}! 👋', style: theme.textTheme.headlineLarge),
        const SizedBox(height: BehtarSpacing.xs),
        Text('Small steps. Big changes.', style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final data = _dashboardDataFor(_scenario);

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
        _buildHabitsCard(context),
        const SizedBox(height: BehtarSpacing.base),
        _buildUsageCard(context, data),
        const SizedBox(height: BehtarSpacing.base),
        _buildChallengeCard(context, data),
        const SizedBox(height: BehtarSpacing.lg),
        _buildQuickActions(context),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, _DashboardData data) {
    final theme = Theme.of(context);

    if (_habits.isEmpty) {
      return _SectionCard(
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

    return _SectionCard(
      title: 'Today’s Progress',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProgressRing(
                fraction: _progressFraction,
                label: '$_completedCount/${_habits.length}',
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
              _MiniStat(
                label: 'Focus time',
                value: data.focusLabel,
                icon: Icons.timer_rounded,
              ),
              const SizedBox(width: BehtarSpacing.base),
              _MiniStat(
                label: 'Mood',
                value: data.moodLabel,
                icon: Icons.mood_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, _DashboardData data) {
    return Expanded(
      child: _StatCard(
        icon: Icons.local_fire_department_rounded,
        iconBackground: const Color(0xFFFFF3CD),
        iconColor: Colors.orange.shade700,
        label: 'Streak',
        value: '${data.streak} Days',
        subtitle: _streakSubtitle(data.streak),
      ),
    );
  }

  Widget _buildScreenTimeCard(BuildContext context, _DashboardData data) {
    return Expanded(
      child: _StatCard(
        icon: Icons.phone_android_rounded,
        iconBackground: BehtarColors.mint,
        iconColor: BehtarColors.primary,
        label: 'Screen Time',
        value: data.screenTimeLabel,
        subtitle: data.screenTimeSubtitle,
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, _DashboardData data) {
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

  Widget _buildHabitsCard(BuildContext context) {
    return _SectionCard(
      title: 'Today’s Habits',
      actionLabel: 'View all',
      onAction: () => _openDetailScreen(
        context,
        'Today’s Habits',
        _habits
            .map(
              (habit) =>
                  '${habit.title} — ${habit.completed ? 'done' : 'pending'}',
            )
            .toList(),
      ),
      child: Column(
        children: [
          for (var index = 0; index < _habits.length; index++) ...[
            if (index > 0) const SizedBox(height: BehtarSpacing.md),
            _HabitRow(
              habit: _habits[index],
              onToggle: () => _toggleHabit(index),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsageCard(BuildContext context, _DashboardData data) {
    final theme = Theme.of(context);
    final hasWarning = data.usageAlerts.any((alert) => alert.level == 'warning');

    return _SectionCard(
      title: 'App Usage',
      actionLabel: 'See apps',
      onAction: () => _openDetailScreen(
        context,
        'App Usage',
        data.usageAlerts
            .map((alert) => '${alert.title}: ${alert.value}')
            .toList(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(BehtarSpacing.md),
            decoration: BoxDecoration(
              color: hasWarning ? const Color(0xFFFFF3CD) : BehtarColors.mint,
              borderRadius: BorderRadius.circular(BehtarRadii.control),
            ),
            child: Row(
              children: [
                Icon(
                  hasWarning
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,
                  color: hasWarning
                      ? Colors.orange.shade700
                      : BehtarColors.primary,
                  size: 20,
                ),
                const SizedBox(width: BehtarSpacing.sm),
                Expanded(
                  child: Text(
                    data.usageStatusLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: BehtarColors.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: BehtarSpacing.base),
          ...data.usageAlerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: BehtarSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: alert.level == 'warning'
                          ? const Color(0xFFFFF3CD)
                          : BehtarColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: alert.level == 'warning'
                        ? Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange.shade700,
                            size: 18,
                          )
                        : _AppBrandIcon(
                            appId: alert.appId,
                            color: BehtarColors.primary,
                            background: BehtarColors.mint,
                          ),
                  ),
                  const SizedBox(width: BehtarSpacing.sm),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    alert.value,
                    style: const TextStyle(
                      color: BehtarColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, _DashboardData data) {
    final theme = Theme.of(context);
    final challengeFraction = data.challengeTotal == 0
        ? 0.0
        : data.challengeProgress / data.challengeTotal;

    return _SectionCard(
      title: '7-Day Challenge',
      actionLabel: 'Open',
      onAction: () => _openDetailScreen(
        context,
        '7-Day Challenge',
        const [
          'Complete 7 days of low phone checks',
          'Keep social app usage below 32 mins/day',
          'Finish 3 habit streaks',
        ],
      ),
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
            _QuickActionTile(
              icon: Icons.add_rounded,
              label: 'Add Habit',
              onTap: () => _openTab(_tabHabits),
            ),
            _QuickActionTile(
              icon: Icons.phone_android_rounded,
              label: 'Screen Time',
              onTap: () => _openTab(_tabApps),
            ),
            _QuickActionTile(
              icon: Icons.emoji_events_rounded,
              label: 'Challenge',
              onTap: () => _openTab(_tabChallenges),
            ),
            _QuickActionTile(
              icon: Icons.group_rounded,
              label: 'View Group',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Groups are not available yet.')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const _LoadingScreen();
  }

  Widget _buildEmptyState() {
    return _StateCard(
      icon: Icons.checklist_rounded,
      title: 'No habits started yet',
      description:
          'Start with a small habit, then come back here to track your momentum.',
      buttonLabel: 'Add a habit',
      onButton: () => _openTab(_tabHabits),
    );
  }

  Widget _buildErrorState() {
    return _StateCard(
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
    final parts =
        name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
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

  void _openDetailScreen(
    BuildContext context,
    String title,
    List<String> items,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DashboardDetailScreen(title: title, items: items),
      ),
    );
  }

  _DashboardData _dashboardDataFor(DashboardScenario scenario) {
    switch (scenario) {
      case DashboardScenario.firstUse:
        return _DashboardData(
          points: 240,
          pointsDelta: 35,
          streak: 6,
          focusLabel: '42 min',
          moodLabel: 'Focused',
          screenTimeLabel: '2h 18m',
          screenTimeSubtitle: 'Limit: 3h',
          usageStatusLabel: 'Instagram is approaching its daily limit',
          challengeName: '7-Day Calm Scroll Reset',
          challengeProgress: 4,
          challengeTotal: 7,
          challengeReward: 'Premium plant badge',
          habits: const [
            _HabitEntry(
              title: 'Morning check-in',
              subtitle: 'Log how you feel',
              icon: Icons.wb_sunny_rounded,
              completed: true,
            ),
            _HabitEntry(
              title: 'No-phone before class',
              subtitle: 'Keep your phone away for 30 mins',
              icon: Icons.phone_iphone_rounded,
              completed: true,
            ),
            _HabitEntry(
              title: 'Read 10 pages',
              subtitle: 'Build a learning habit',
              icon: Icons.menu_book_rounded,
              completed: false,
            ),
            _HabitEntry(
              title: 'Stretch and reset',
              subtitle: '2-minute movement break',
              icon: Icons.self_improvement_rounded,
              completed: false,
            ),
          ],
          usageAlerts: const [
            _UsageAlert(
              appId: 'instagram',
              title: 'Instagram',
              value: '42 min',
              level: 'warning',
            ),
            _UsageAlert(
              appId: 'youtube',
              title: 'YouTube',
              value: '25 min',
              level: 'ok',
            ),
            _UsageAlert(
              appId: 'whatsapp',
              title: 'WhatsApp',
              value: '19 min',
              level: 'ok',
            ),
          ],
          progressBreakdown: const [
            '3/5 habits finished',
            'Stay on track with your daily rhythm',
            'One more habit unlocks your streak badge',
          ],
        );
      case DashboardScenario.completedDay:
        return _DashboardData(
          points: 520,
          pointsDelta: 80,
          streak: 11,
          focusLabel: '1h 12m',
          moodLabel: 'Energized',
          screenTimeLabel: '1h 45m',
          screenTimeSubtitle: 'Limit: 3h',
          usageStatusLabel: 'Healthy usage — nice balance today',
          challengeName: '7-Day Calm Scroll Reset',
          challengeProgress: 7,
          challengeTotal: 7,
          challengeReward: 'Golden habit badge',
          habits: const [
            _HabitEntry(
              title: 'Morning check-in',
              subtitle: 'Log how you feel',
              icon: Icons.wb_sunny_rounded,
              completed: true,
            ),
            _HabitEntry(
              title: 'No-phone before class',
              subtitle: 'Keep your phone away for 30 mins',
              icon: Icons.phone_iphone_rounded,
              completed: true,
            ),
            _HabitEntry(
              title: 'Read 10 pages',
              subtitle: 'Build a learning habit',
              icon: Icons.menu_book_rounded,
              completed: true,
            ),
            _HabitEntry(
              title: 'Stretch and reset',
              subtitle: '2-minute movement break',
              icon: Icons.self_improvement_rounded,
              completed: true,
            ),
          ],
          usageAlerts: const [
            _UsageAlert(
              appId: 'instagram',
              title: 'Instagram',
              value: '15 min',
              level: 'ok',
            ),
            _UsageAlert(
              appId: 'youtube',
              title: 'YouTube',
              value: '18 min',
              level: 'ok',
            ),
            _UsageAlert(
              appId: 'whatsapp',
              title: 'WhatsApp',
              value: '12 min',
              level: 'ok',
            ),
          ],
          progressBreakdown: const [
            'All habits complete',
            'You reached your daily goal',
            'Your challenge streak is still active',
          ],
        );
      case DashboardScenario.empty:
        return _DashboardData(
          points: 0,
          pointsDelta: 0,
          streak: 0,
          focusLabel: '0 min',
          moodLabel: 'Fresh',
          screenTimeLabel: 'Not tracked',
          screenTimeSubtitle: 'No limit set yet',
          usageStatusLabel: 'Set up app limits to start tracking usage',
          challengeName: 'Start your first week',
          challengeProgress: 0,
          challengeTotal: 7,
          challengeReward: 'Starter badge',
          habits: const [],
          usageAlerts: const [
            _UsageAlert(
              appId: '',
              title: 'Your phone time',
              value: 'Not tracked',
              level: 'ok',
            ),
            _UsageAlert(
              appId: '',
              title: 'Social apps',
              value: 'No limit set',
              level: 'ok',
            ),
          ],
          progressBreakdown: const [
            'Create your first habit',
            'Set a realistic target',
            'Build momentum one small step at a time',
          ],
        );
      case DashboardScenario.loading:
      case DashboardScenario.error:
        return _DashboardData(
          points: 0,
          pointsDelta: 0,
          streak: 0,
          focusLabel: '—',
          moodLabel: '—',
          screenTimeLabel: '—',
          screenTimeSubtitle: '—',
          usageStatusLabel: '—',
          challengeName: 'Loading challenge',
          challengeProgress: 0,
          challengeTotal: 7,
          challengeReward: '—',
          habits: const [],
          usageAlerts: const [],
          progressBreakdown: const [],
        );
    }
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.fraction, required this.label});

  final double fraction;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: fraction,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: BehtarColors.primary,
              backgroundColor: BehtarColors.mint,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: BehtarColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('habits', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(BehtarRadii.control),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: BehtarSpacing.md),
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: BehtarSpacing.xs),
            Text(value, style: theme.textTheme.headlineSmall),
            const SizedBox(height: BehtarSpacing.xs),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (actionLabel != null && onAction != null)
                  TextButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
              ],
            ),
            const SizedBox(height: BehtarSpacing.base),
            child,
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BehtarColors.mint,
          borderRadius: BorderRadius.circular(BehtarRadii.control),
        ),
        child: Padding(
          padding: const EdgeInsets.all(BehtarSpacing.sm),
          child: Row(
            children: [
              Icon(icon, color: BehtarColors.primary, size: 18),
              const SizedBox(width: BehtarSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: BehtarColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.habit, required this.onToggle});

  final _HabitEntry habit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(BehtarRadii.control),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BehtarSpacing.sm,
          vertical: BehtarSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: habit.completed
                    ? BehtarColors.mint
                    : BehtarColors.background,
                borderRadius: BorderRadius.circular(BehtarRadii.control),
              ),
              child: Icon(
                habit.icon,
                color: habit.completed
                    ? BehtarColors.primary
                    : BehtarColors.secondaryText,
                size: 22,
              ),
            ),
            const SizedBox(width: BehtarSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.title, style: theme.textTheme.titleMedium),
                  Text(habit.subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: BehtarSpacing.sm),
            Icon(
              habit.completed
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: habit.completed ? BehtarColors.primary : BehtarColors.sage,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BehtarRadii.control),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: BehtarSpacing.sm),
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: BehtarColors.mint,
                child: Icon(icon, color: BehtarColors.primary, size: 24),
              ),
              const SizedBox(height: BehtarSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BehtarColors.primaryText,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBrandIcon extends StatelessWidget {
  const _AppBrandIcon({
    required this.appId,
    required this.color,
    required this.background,
  });

  final String appId;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final CustomPainter painter;
    switch (appId) {
      case 'instagram':
        painter = _InstagramIconPainter(color: color, background: background);
      case 'youtube':
        painter = _YouTubeIconPainter(color: color, background: background);
      case 'whatsapp':
        painter = _WhatsAppIconPainter(color: color, background: background);
      default:
        return const Icon(Icons.check_circle_rounded, color: BehtarColors.primary, size: 18);
    }

    return CustomPaint(painter: painter, size: const Size.square(18));
  }
}

class _InstagramIconPainter extends CustomPainter {
  const _InstagramIconPainter({required this.color, required this.background});

  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s).deflate(s * 0.045),
        Radius.circular(s * 0.26),
      ),
      outline,
    );
    canvas.drawCircle(Offset(s / 2, s / 2), s * 0.24, outline);
    canvas.drawCircle(
      Offset(s * 0.74, s * 0.26),
      s * 0.06,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _InstagramIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.background != background;
}

class _YouTubeIconPainter extends CustomPainter {
  const _YouTubeIconPainter({required this.color, required this.background});

  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0, s * 0.18, s, s * 0.82),
        Radius.circular(s * 0.18),
      ),
      Paint()..color = color,
    );
    final triangle = Path()
      ..moveTo(s * 0.40, s * 0.34)
      ..lineTo(s * 0.40, s * 0.66)
      ..lineTo(s * 0.70, s * 0.50)
      ..close();
    canvas.drawPath(triangle, Paint()..color = background);
  }

  @override
  bool shouldRepaint(covariant _YouTubeIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.background != background;
}

class _WhatsAppIconPainter extends CustomPainter {
  const _WhatsAppIconPainter({required this.color, required this.background});

  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09;

    // Speech-bubble outline.
    final center = Offset(s * 0.5, s * 0.46);
    canvas.drawCircle(center, s * 0.36, stroke);

    // Bubble tail at the lower-left.
    final tail = Path()
      ..moveTo(s * 0.30, s * 0.74)
      ..lineTo(s * 0.10, s * 0.92)
      ..lineTo(s * 0.16, s * 0.62)
      ..close();
    canvas.drawPath(tail, Paint()..color = color);

    // Telephone handset, tilted diagonally inside the bubble.
    final handset = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.46, s * 0.46), radius: s * 0.21),
      -math.pi * 0.06,
      math.pi * 0.62,
      false,
      handset,
    );
    canvas.drawCircle(Offset(s * 0.677, s * 0.422), s * 0.07, Paint()..color = color);
    canvas.drawCircle(Offset(s * 0.422, s * 0.677), s * 0.07, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WhatsAppIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.background != background;
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onButton,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(BehtarSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: BehtarColors.mint,
              child: Icon(icon, color: BehtarColors.primary, size: 28),
            ),
            const SizedBox(height: BehtarSpacing.base),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BehtarSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: BehtarSpacing.base),
            FilledButton(
              onPressed: onButton,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(BehtarSpacing.xl),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: BehtarSpacing.base),
              Text('Loading your dashboard...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardDetailScreen extends StatelessWidget {
  const _DashboardDetailScreen({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(BehtarSpacing.base),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: BehtarSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.chevron_right_rounded),
              title: Text(item),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.points,
    required this.pointsDelta,
    required this.streak,
    required this.focusLabel,
    required this.moodLabel,
    required this.screenTimeLabel,
    required this.screenTimeSubtitle,
    required this.usageStatusLabel,
    required this.challengeName,
    required this.challengeProgress,
    required this.challengeTotal,
    required this.challengeReward,
    required this.habits,
    required this.usageAlerts,
    required this.progressBreakdown,
  });

  final int points;
  final int pointsDelta;
  final int streak;
  final String focusLabel;
  final String moodLabel;
  final String screenTimeLabel;
  final String screenTimeSubtitle;
  final String usageStatusLabel;
  final String challengeName;
  final int challengeProgress;
  final int challengeTotal;
  final String challengeReward;
  final List<_HabitEntry> habits;
  final List<_UsageAlert> usageAlerts;
  final List<String> progressBreakdown;
}

class _HabitEntry {
  const _HabitEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.completed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool completed;
}

class _UsageAlert {
  const _UsageAlert({
    required this.appId,
    required this.title,
    required this.value,
    required this.level,
  });

  /// Stable identifier for the tracked app (e.g. 'instagram').
  ///
  /// Kept separate from [title] so the icon and any future Screen Timer
  /// data resolve by identity rather than by display-name matching.
  final String appId;
  final String title;
  final String value;
  final String level;
}
