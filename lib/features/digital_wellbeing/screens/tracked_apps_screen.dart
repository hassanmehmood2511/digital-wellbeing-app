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
  late List<AppUsage> _pendingApps;

  @override
  void initState() {
    super.initState();
    _loadPendingApps();
  }

  void _loadPendingApps() {
    _pendingApps = AppData().apps.map((a) => AppUsage(
      appName: a.appName,
      usageMinutes: a.usageMinutes,
      dailyLimitMinutes: a.dailyLimitMinutes,
      isTracked: a.isTracked,
    )).toList();
  }

  bool get _hasUnsavedChanges {
    final currentApps = AppData().apps;
    if (_pendingApps.length != currentApps.length) return true;
    for (int i = 0; i < _pendingApps.length; i++) {
      if (_pendingApps[i].appName != currentApps[i].appName ||
          _pendingApps[i].isTracked != currentApps[i].isTracked) {
        return true;
      }
    }
    return false;
  }

  void _saveChanges() {
    AppData().saveApps(_pendingApps.map((a) => AppUsage(
      appName: a.appName,
      usageMinutes: a.usageMinutes,
      dailyLimitMinutes: a.dailyLimitMinutes,
      isTracked: a.isTracked,
    )).toList());

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App tracking changes saved successfully.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {});
  }

  Future<bool?> _showUnsavedChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text('Discard unsaved changes?', style: AppTypography.h3),
        content: const Text(
          'You have unconfirmed changes to your app tracking settings. Leaving will discard these changes.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard', style: TextStyle(color: AppColors.error)),
          ),
          ElevatedButton(
            onPressed: () {
              _saveChanges();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Grab the navigator before the dialog so no context is used later.
        final navigator = Navigator.of(context);
        final shouldLeave = await _showUnsavedChangesDialog();
        if (shouldLeave == true) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Manage Tracked Apps', style: AppTypography.h3),
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        body: Column(
          children: [
            if (_hasUnsavedChanges)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.warning.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'You have pending changes. Tap "Confirm Changes" to apply.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _pendingApps.length,
                itemBuilder: (context, index) {
                  final app = _pendingApps[index];
                  return _buildAppListItem(app, index);
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _hasUnsavedChanges
                        ? () {
                            _saveChanges();
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.border,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _hasUnsavedChanges ? 'Confirm Changes' : 'Saved',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _hasUnsavedChanges ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddAppDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildAppListItem(AppUsage app, int index) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  app.isTracked ? 'Tracked' : 'Excluded',
                  style: TextStyle(
                    fontSize: 13,
                    color: app.isTracked ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
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
                _pendingApps[index].isTracked = value ?? !_pendingApps[index].isTracked;
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
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final exists = _pendingApps.any(
                    (a) => a.appName.toLowerCase() == text.toLowerCase(),
                  );
                  if (!exists) {
                    setState(() {
                      _pendingApps.add(
                        AppUsage(
                          appName: text,
                          usageMinutes: 0,
                          dailyLimitMinutes: 60,
                          isTracked: true,
                        ),
                      );
                    });
                  }
                  Navigator.pop(context);
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
