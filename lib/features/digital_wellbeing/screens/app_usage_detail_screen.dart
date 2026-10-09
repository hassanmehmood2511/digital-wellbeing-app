import 'package:flutter/material.dart';
import 'package:digital_wellbeing_app/core/theme/app_colors.dart';
import 'package:digital_wellbeing_app/core/theme/app_typography.dart';
import 'package:digital_wellbeing_app/models/app_usage.dart';
import 'package:digital_wellbeing_app/data/app_data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class AppUsageDetailScreen extends StatefulWidget {
  final AppUsage appData;
  const AppUsageDetailScreen({super.key, required this.appData});

  @override
  State<AppUsageDetailScreen> createState() => _AppUsageDetailScreenState();
}

class _AppUsageDetailScreenState extends State<AppUsageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final currentAppData = AppData().apps.firstWhere(
          (app) => app.appName == widget.appData.appName,
      orElse: () => widget.appData,
    );

    final percentage = currentAppData.usageMinutes / currentAppData.dailyLimitMinutes;
    final isOverLimit = percentage > 1.0;
    final timeSaved = currentAppData.dailyLimitMinutes - currentAppData.usageMinutes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(currentAppData.appName, style: AppTypography.h3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      // FIX 2: Bottom padding 100 kar di taake button navigation bar se cut na ho
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // FIX 1: Icon ko Theme Colors (Mint + Primary Green) mein convert kiya
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mint, // Design System Rule #5: Soft icon container
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(child: _getAppIcon(currentAppData.appName)),
            ),

            const SizedBox(height: 16),
            Text(currentAppData.appName, style: AppTypography.h1),
            const SizedBox(height: 32),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: percentage.clamp(0.0, 1.0),
                    strokeWidth: 20,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverLimit ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(_formatMinutes(currentAppData.usageMinutes), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const Text('used', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  Icon(isOverLimit ? Icons.warning_rounded : Icons.check_circle_outline, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isOverLimit ? 'Over Limit!' : 'Within Limit', style: AppTypography.h3.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(isOverLimit ? 'You exceeded your limit by ${_formatMinutes((currentAppData.usageMinutes - currentAppData.dailyLimitMinutes).abs())}' : 'You saved ${_formatMinutes(timeSaved)} today', style: AppTypography.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Align(alignment: Alignment.centerLeft, child: Text('Detailed Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            const SizedBox(height: 12),
            _buildStatRow('Daily Limit', _formatMinutes(currentAppData.dailyLimitMinutes), Icons.timer_outlined),
            _buildStatRow('Time Used', _formatMinutes(currentAppData.usageMinutes), Icons.phone_android),
            _buildStatRow('Remaining', isOverLimit ? 'Exceeded by ${_formatMinutes((currentAppData.usageMinutes - currentAppData.dailyLimitMinutes).abs())}' : _formatMinutes(timeSaved), isOverLimit ? Icons.trending_up : Icons.trending_down),
            _buildStatRow('Usage Percentage', '${(percentage * 100).toStringAsFixed(0)}%', Icons.pie_chart_outline),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border, width: 1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 24), const SizedBox(width: 8), const Text('Suggestion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary))]),
                  const SizedBox(height: 12),
                  Text(isOverLimit ? 'Try reducing your ${currentAppData.appName} usage tomorrow.' : 'Great job! You\'re managing your ${currentAppData.appName} usage well.', style: AppTypography.body),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Edit Button (Ab yeh cut nahi hoga kyunke upar padding barha di hai)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditLimitDialog(context, currentAppData),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Daily Limit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border, width: 1)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.body)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _showEditLimitDialog(BuildContext context, AppUsage currentAppData) {
    int newLimit = currentAppData.dailyLimitMinutes;
    final TextEditingController _limitController = TextEditingController(text: currentAppData.dailyLimitMinutes.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Edit Daily Limit', style: AppTypography.h3),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentAppData.appName, style: AppTypography.body),
                  const SizedBox(height: 16),

                  // 1. Existing Slider (Quick adjustment ke liye)
                  Slider(
                    value: newLimit.clamp(15, 240).toDouble(),
                    min: 15,
                    max: 240,
                    divisions: 15,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: (double value) {
                      setDialogState(() {
                        newLimit = value.round();
                        _limitController.text = newLimit.toString();
                      });
                    },
                  ),
                  Text('Slider: ${_formatMinutes(newLimit.clamp(15, 240))}', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),

                  // 2. New Manual Input (Zyada time set karne ke liye)
                  const Text('Or enter manually (in minutes):', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Sirf numbers allow karega
                    decoration: InputDecoration(
                      hintText: 'Enter minutes (e.g., 300 for 5h)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: AppColors.mint,
                    ),
                    onChanged: (value) {
                      int? parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setDialogState(() {
                          newLimit = parsed;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Total Limit: ${_formatMinutes(newLimit)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
                ElevatedButton(
                  onPressed: () {
                    AppData().updateLimit(currentAppData.appName, newLimit);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${currentAppData.appName} limit updated'), backgroundColor: AppColors.primary));
                    setState(() {});
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // FIX 1: Icon ab hamesha Primary Green color mein aayega (Design System Rule #5)
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
    return Icon(iconData, color: AppColors.primary, size: 32);
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }
}