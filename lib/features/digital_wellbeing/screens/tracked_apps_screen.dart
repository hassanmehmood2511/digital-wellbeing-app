import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/data/app_data.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/models/app_usage.dart';

class TrackedAppsScreen extends StatefulWidget {
  const TrackedAppsScreen({super.key});

  @override
  State<TrackedAppsScreen> createState() => _TrackedAppsScreenState();
}

class _TrackedAppsScreenState extends State<TrackedAppsScreen> {
  @override
  Widget build(BuildContext context) {
    final apps = AppData().apps;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Tracked Apps', style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return _buildAppListItem(app);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildAppListItem(AppUsage app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: _getAppIcon(app.appName)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              app.appName,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Checkbox(
            value: app.isTracked,
            activeColor: AppColors.primary,
            checkColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? value) {
              setState(() {
                AppData().toggleTracking(app.appName);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddAppDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text('Add New App', style: AppTypography.h3),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter app name (e.g., LinkedIn)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: AppColors.mint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  AppData().addNewApp(controller.text.trim());
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getAppIcon(String appName) {
    final FaIconData iconData;
    switch (appName.toLowerCase()) {
      case 'instagram':
        iconData = FontAwesomeIcons.instagram;
        break;
      case 'tiktok':
        iconData = FontAwesomeIcons.tiktok;
        break;
      case 'youtube':
        iconData = FontAwesomeIcons.youtube;
        break;
      case 'whatsapp':
        iconData = FontAwesomeIcons.whatsapp;
        break;
      case 'facebook':
        iconData = FontAwesomeIcons.facebook;
        break;
      case 'twitter / x':
      case 'twitter':
      case 'x':
        iconData = FontAwesomeIcons.xTwitter;
        break;
      case 'snapchat':
        iconData = FontAwesomeIcons.snapchat;
        break;
      default:
        iconData = FontAwesomeIcons.mobileScreen;
    }
    return FaIcon(iconData, color: AppColors.primary, size: 22);
  }
}
