import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/data/app_data.dart';
import 'package:digital_wellbeing_app/features/digital_wellbeing/models/app_usage.dart';
import 'app_usage_detail_screen.dart';
import 'tracked_apps_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:digital_wellbeing_app/core/widgets/behtar_progress_bar.dart';

class UsageOverviewScreen extends StatefulWidget {
  const UsageOverviewScreen({super.key});

  @override
  State<UsageOverviewScreen> createState() => _UsageOverviewScreenState();
}

class _UsageOverviewScreenState extends State<UsageOverviewScreen> {
  bool _showBreakReminder = true;

  @override
  Widget build(BuildContext context) {
    final apps = AppData().apps.where((app) => app.isTracked).toList();
    final totalUsage = apps.fold<int>(0, (sum, app) => sum + app.usageMinutes);
    final totalLimit = apps.fold<int>(
      0,
      (sum, app) => sum + app.dailyLimitMinutes,
    );
    final overallPercentage = totalLimit > 0
        ? (totalUsage / totalLimit).clamp(0.0, 1.5)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Screen Time'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuccessCard(),
            const SizedBox(height: 24),
            _buildLiveUsageBar(totalUsage, totalLimit, overallPercentage),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Selected Apps', style: AppTypography.h3)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackedAppsScreen(),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  child: Text(
                    'Manage',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final appData = apps[index];
                return _buildAppUsageItem(
                  appName: appData.appName,
                  usageMinutes: appData.usageMinutes,
                  limitMinutes: appData.dailyLimitMinutes,
                );
              },
            ),
            const SizedBox(height: 32),
            Text('Daily Usage', style: AppTypography.h3),
            const SizedBox(height: 12),
            _buildDailyUsageChart(),
            const SizedBox(height: 24),
            if (_showBreakReminder) _buildBreakReminder(),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveUsageBar(int totalUsage, int totalLimit, double percentage) {
    final Color barColor = percentage >= 1.0
        ? AppColors.error
        : (percentage >= 0.8 ? AppColors.warning : AppColors.primary);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: percentage >= 1.0 ? AppColors.error.withValues(alpha: 0.3) : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Today\'s Total Usage',
                  style: AppTypography.h3.copyWith(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${_formatMinutes(totalUsage)} / ${_formatMinutes(totalLimit)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BehtarProgressBar(
            value: percentage,
            color: barColor,
            semanticsLabel: 'Total daily usage',
          ),
          const SizedBox(height: 8),
          Text(
            percentage >= 1.0
                ? '⚠️ You\'ve exceeded your total daily limit!'
                : (percentage >= 0.8
                    ? '⚠️ You are approaching your total daily limit (${(percentage * 100).toStringAsFixed(0)}%)'
                    : '${(percentage * 100).toStringAsFixed(0)}% of daily limit used'),
            style: AppTypography.small.copyWith(
              color: percentage >= 1.0
                  ? AppColors.error
                  : (percentage >= 0.8
                      ? AppColors.warning
                      : AppColors.textSecondary),
              fontWeight: percentage >= 0.8 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    final apps = AppData().apps.where((app) => app.isTracked).toList();
    final overLimitApps = apps
        .where((app) => app.usageMinutes >= app.dailyLimitMinutes)
        .toList();
    final isAnyOverLimit = overLimitApps.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            isAnyOverLimit ? Icons.warning_rounded : Icons.check_circle_outline,
            color: isAnyOverLimit ? AppColors.error : AppColors.secondary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnyOverLimit ? 'Some apps exceeded!' : "You're doing well!",
                  style: AppTypography.h3.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  isAnyOverLimit
                      ? '${overLimitApps.length} app(s) over daily limit.'
                      : 'Your screen time is within your daily limit.',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppUsageItem({
    required String appName,
    required int usageMinutes,
    required int limitMinutes,
  }) {
    final percentage = limitMinutes > 0 ? (usageMinutes / limitMinutes) : 0.0;
    final Color indicatorColor = percentage >= 1.0
        ? AppColors.error
        : (percentage >= 0.8 ? AppColors.warning : AppColors.primary);

    final appData = AppUsage(
      appName: appName,
      usageMinutes: usageMinutes,
      dailyLimitMinutes: limitMinutes,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppUsageDetailScreen(appData: appData),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: percentage >= 1.0
                ? AppColors.error.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: percentage >= 1.0
                    ? AppColors.error.withValues(alpha: 0.1)
                    : (percentage >= 0.8
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : AppColors.mint),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _getAppIcon(
                  appName,
                  iconColor: percentage >= 1.0
                      ? AppColors.error
                      : (percentage >= 0.8
                          ? AppColors.warning
                          : AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appName,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (percentage >= 1.0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Exceeded',
                            style: AppTypography.small.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        )
                      else if (percentage >= 0.8)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Near Limit',
                            style: AppTypography.small.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BehtarProgressBar(
                    value: percentage,
                    color: indicatorColor,
                    semanticsLabel: '$appName usage',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatMinutes(usageMinutes)} / ${_formatMinutes(limitMinutes)}',
                    style: AppTypography.small.copyWith(
                      color: percentage >= 1.0
                          ? AppColors.error
                          : (percentage >= 0.8
                              ? AppColors.warning
                              : AppColors.textSecondary),
                      fontWeight:
                          percentage >= 0.8 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.sage, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _getAppIcon(String appName, {Color iconColor = AppColors.primary}) {
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

    return FaIcon(iconData, color: iconColor, size: 22);
  }

  Widget _buildDailyUsageChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'];
    final weeklyUsageMinutes = AppData().getWeeklyUsage();
    final maxMinutes = weeklyUsageMinutes
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final chartMaxHeight = 100.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              int index = entry.key;
              String day = entry.value;
              int minutes = weeklyUsageMinutes[index];
              double hours = minutes / 60.0;
              double barHeight = maxMinutes > 0
                  ? (minutes / maxMinutes) * chartMaxHeight
                  : 0;

              Color barColor;
              if (minutes == 0) {
                barColor = AppColors.border;
              } else if (index == days.length - 1) {
                barColor = AppColors.primary;
              } else if (minutes >= maxMinutes * 0.8) {
                barColor = AppColors.primary;
              } else if (minutes >= maxMinutes * 0.5) {
                barColor = AppColors.secondary;
              } else {
                barColor = AppColors.lightGreen;
              }

              return Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: chartMaxHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 28,
                            height: barHeight.clamp(4.0, chartMaxHeight),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: index == days.length - 1
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: index == days.length - 1
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hours.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakReminder() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.self_improvement,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time for a break?',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try a 10-minute break from social media. Your future self will thank you!',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showBreakReminder = false;
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}
