import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';
import 'package:digital_wellbeing_app/data/app_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UsageLimitsScreen extends StatefulWidget {
  const UsageLimitsScreen({super.key});
  @override
  State<UsageLimitsScreen> createState() => _UsageLimitsScreenState();
}

class _UsageLimitsScreenState extends State<UsageLimitsScreen> {
  bool _warningEnabled = true;

  @override
  Widget build(BuildContext context) {
    final apps = AppData().apps.where((app) => app.isTracked).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Usage Limits', style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: SwitchListTile(
              title: Text('Gentle Reminders', style: AppTypography.h3.copyWith(fontSize: 20)),
              subtitle: Text('Warn me when I reach 80% of my daily limit', style: AppTypography.body),
              value: _warningEnabled,
              activeColor: AppColors.primary,
              onChanged: (bool value) { setState(() { _warningEnabled = value; }); },
            ),
          ),
          const SizedBox(height: 24),
          Text('App Time Limits', style: AppTypography.h3),
          const SizedBox(height: 12),
          ...apps.map((app) => _buildAppLimitCard(app)),
        ],
      ),
    );
  }

  Widget _buildAppLimitCard(app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Specific App Icon in Green Theme
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
                      'Current Limit: ${_formatMinutes(app.dailyLimitMinutes)}',
                      style: AppTypography.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: app.dailyLimitMinutes.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (double value) {
              AppData().updateLimit(app.appName, value.round());
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // Helper: Returns specific icon in Primary Green
  Widget _getAppIcon(String appName) {
    IconData iconData;
    switch (appName.toLowerCase()) {
      case 'instagram': iconData = FontAwesomeIcons.instagram; break;
      case 'tiktok': iconData = FontAwesomeIcons.tiktok; break;
      case 'youtube': iconData = FontAwesomeIcons.youtube; break;
      case 'whatsapp': iconData = FontAwesomeIcons.whatsapp; break;
      case 'facebook': iconData = FontAwesomeIcons.facebook; break;
      case 'twitter / x': case 'twitter': iconData = FontAwesomeIcons.xTwitter; break;
      case 'snapchat': iconData = FontAwesomeIcons.snapchat; break;
      default: iconData = Icons.apps;
    }
    return Icon(iconData, color: AppColors.primary, size: 22);
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}