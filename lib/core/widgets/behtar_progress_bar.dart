import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The single progress bar style used across Behtar.
///
/// Matches the bar on the Habits screen: 7px tall, sage track, primary
/// green fill and soft rounded corners. Use this everywhere a linear
/// progress bar is needed so every screen stays visually consistent.
class BehtarProgressBar extends StatelessWidget {
  const BehtarProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.height = 7,
    this.semanticsLabel,
  });

  /// Progress from 0.0 to 1.0. Values outside the range are clamped.
  final double value;

  /// Fill colour. Defaults to the primary green; pass a status colour
  /// (warning / error) only when the bar needs to signal a limit.
  final Color color;

  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final double safeValue =
        value.isNaN ? 0.0 : value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: LinearProgressIndicator(
        value: safeValue,
        minHeight: height,
        backgroundColor: AppColors.sage,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
