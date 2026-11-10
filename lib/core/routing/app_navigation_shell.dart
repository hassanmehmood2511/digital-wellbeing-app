import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/challenges/challenges_controller.dart';
import '../../features/challenges/challenges_screen.dart';
import '../../features/digital_wellbeing/data/app_data.dart';
import '../../features/digital_wellbeing/data/device_usage_service.dart';
import '../../features/digital_wellbeing/screens/usage_overview_screen.dart';
import '../../features/digital_wellbeing/widgets/usage_access_sheet.dart';
import '../../features/groups/groups_controller.dart';
import '../../features/groups/groups_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/rewards/progress_screen.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/habits/presentation/screens/habit_list_screen.dart';
import '../widgets/behtar_bottom_navigation_bar.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({required this.settingsController, super.key});

  final SettingsController settingsController;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  static const String _usagePromptSnoozeKey = 'usage_prompt_snoozed_until';
  static const Duration _usagePromptSnooze = Duration(days: 3);
  bool _sentToUsageSettings = false;
  Timer? _usagePromptTimer;

  late final ChallengesController _challengesController =
      ChallengesController();

  late final GroupsController _groupsController = GroupsController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Let Home load first, then ask about screen time if needed.
    _usagePromptTimer = Timer(
      const Duration(seconds: 2),
      _maybeAskForUsageAccess,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_sentToUsageSettings) return;
    _sentToUsageSettings = false;
    AppData().syncFromDevice().then((granted) {
      if (!mounted || !granted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screen time tracking is on. See it in the Apps tab.'),
        ),
      );
    });
  }

  /// Once per start-up (unless snoozed): explain usage access and offer to
  /// open Android settings.
  Future<void> _maybeAskForUsageAccess() async {
    if (!mounted || !DeviceUsageService.isSupported) return;
    if (await DeviceUsageService.hasPermission()) return;

    final prefs = await SharedPreferences.getInstance();
    final snoozedUntil = prefs.getInt(_usagePromptSnoozeKey) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch < snoozedUntil) return;
    if (!mounted) return;
    // Don't cover another screen the user has opened on top.
    if (ModalRoute.of(context)?.isCurrent == false) return;

    final allow = await showUsageAccessSheet(context);
    if (allow) {
      _sentToUsageSettings = true;
      await DeviceUsageService.openSettings();
    } else {
      await prefs.setInt(
        _usagePromptSnoozeKey,
        DateTime.now().add(_usagePromptSnooze).millisecondsSinceEpoch,
      );
    }
  }

  @override
  void dispose() {
    _usagePromptTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _challengesController.dispose();
    _groupsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeDashboardScreen(
            controller: widget.settingsController,
            onOpenTab: (index) => setState(() => _currentIndex = index),
            challengesController: _challengesController,
          ),

          // Habit feature connected to the navigation shell.
          const HabitListScreen(),

          // Challenges feature from dev.
          ChallengesScreen(
            controller: _challengesController,
            onOpenGroups: _openGroups,
          ),

          const ProgressScreen(),
          const UsageOverviewScreen(),
          ProfileScreen(controller: widget.settingsController),
        ],
      ),
      bottomNavigationBar: BehtarBottomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  void _openGroups() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GroupsScreen(
          controller: _groupsController,
          currentUserName: widget.settingsController.displayName,
        ),
      ),
    );
  }
}
