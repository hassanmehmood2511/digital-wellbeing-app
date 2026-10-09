import 'package:flutter/material.dart';

import '../../features/home/home_dashboard_screen.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/settings/profile_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeDashboardScreen(
            controller: widget.settingsController,
            onOpenTab: (index) => setState(() => _currentIndex = index),
          ),
          const _DestinationPlaceholder(
            title: 'Habits',
            message: 'Your habits will appear here.',
            icon: Icons.checklist_rounded,
          ),
          const _DestinationPlaceholder(
            title: 'Challenges',
            message: 'Find a challenge to grow together.',
            icon: Icons.emoji_events_rounded,
          ),
          const _DestinationPlaceholder(
            title: 'Progress',
            message: 'Your progress will be shown here.',
            icon: Icons.insights_rounded,
          ),
          const _DestinationPlaceholder(
            title: 'Apps',
            message: 'Apps you choose to manage with Behtar will appear here.',
            icon: Icons.phonelink_lock_rounded,
          ),
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
