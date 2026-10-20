import 'package:flutter/material.dart';

import '../../features/challenges/challenges_controller.dart';
import '../../features/challenges/challenges_screen.dart';
import '../../features/digital_wellbeing/screens/usage_overview_screen.dart';
import '../../features/groups/groups_controller.dart';
import '../../features/groups/groups_screen.dart';
import '../../features/rewards/progress_screen.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/settings/profile_screen.dart';
import '../../features/habits/presentation/screens/habit_list_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/behtar_bottom_navigation_bar.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({required this.settingsController, super.key});

  final SettingsController settingsController;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;

  late final ChallengesController _challengesController =
      ChallengesController();

  late final GroupsController _groupsController = GroupsController();

  @override
  void dispose() {
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
          const _DestinationPlaceholder(
            title: 'Home',
            message: 'Your day starts with one small step.',
            icon: Icons.home_rounded,
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
          currentUserName: widget.settingsController.fullName,
        ),
      ),
    );
  }
}

class _DestinationPlaceholder extends StatelessWidget {
  const _DestinationPlaceholder({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(BehtarSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: BehtarColors.mint,
                foregroundColor: BehtarColors.primary,
                child: Icon(icon, size: 30),
              ),
              const SizedBox(height: BehtarSpacing.base),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
