
import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';

// A simple class to hold app data
class AppItem {
  final String name;
  final Color color;
  bool isTracked; // This will change when user clicks the checkbox

  AppItem({required this.name, required this.color, this.isTracked = false});
}

class TrackedAppsScreen extends StatefulWidget {
  const TrackedAppsScreen({super.key});

  @override
  State<TrackedAppsScreen> createState() => _TrackedAppsScreenState();
}

class _TrackedAppsScreenState extends State<TrackedAppsScreen> {
  // Mock data: List of apps available to track
  final List<AppItem> _allApps = [
    AppItem(name: 'Instagram', color: Colors.purple, isTracked: true),
    AppItem(name: 'TikTok', color: Colors.black, isTracked: true),
    AppItem(name: 'YouTube', color: Colors.red, isTracked: true),
    AppItem(name: 'WhatsApp', color: AppColors.success, isTracked: true),
    AppItem(name: 'Facebook', color: Colors.blue, isTracked: false),
    AppItem(name: 'Twitter / X', color: Colors.grey, isTracked: false),
    AppItem(name: 'Snapchat', color: Colors.yellowAccent, isTracked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Tracked Apps'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _allApps.length,
        itemBuilder: (context, index) {
          final app = _allApps[index];
          return _buildAppListItem(app);
        },
      ),
    );
  }

  // Widget for each app row
  Widget _buildAppListItem(AppItem app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // App Icon Placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: app.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.apps, color: app.color, size: 24),
          ),

          const SizedBox(width: 12),

          // App Name
          Expanded(
            child: Text(
              app.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
          ),

          // Checkbox
          Checkbox(
            value: app.isTracked,
            activeColor: AppColors.primary,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? value) {
              // This updates the state and refreshes the UI
              setState(() {
                app.isTracked = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }
}