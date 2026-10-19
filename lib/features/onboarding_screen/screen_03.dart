import 'package:flutter/material.dart';

import 'onboarding_layout.dart';

class OnboardingScreenThree extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingScreenThree({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      pageIndex: 2,
      pageCount: 3,
      illustration: const _BuildIllustration(),
      title: 'Build a Better You',
      description:
          'Stay consistent with streaks and challenges, and celebrate every milestone on your way to big results.',
      buttonLabel: 'Get Started',
      buttonIcon: Icons.arrow_forward_rounded,
      onBack: () => Navigator.of(context).maybePop(),
      onNext: onFinished,
    );
  }
}

class _BuildIllustration extends StatelessWidget {
  const _BuildIllustration();

  static const List<double> _heights = [50, 84, 118, 152];

  static const List<Color> _colors = [
    OnboardingColors.sageGreen,
    OnboardingColors.lightGreen,
    OnboardingColors.secondaryGreen,
    OnboardingColors.primaryGreen,
  ];

  // One step of the staircase. The last step also carries the flag.
  Widget _step(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: _heights[index]),
      duration: Duration(milliseconds: 600 + index * 150),
      curve: Curves.easeOutCubic,
      builder: (context, height, _) {
        final Widget bar = Container(
          width: 44,
          height: height,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: _colors[index],
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(14),
            ),
          ),
          child: height > 30
              ? Icon(
                  index == 3 ? Icons.star_rounded : Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                )
              : null,
        );

        if (index != 3) return bar;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flag_rounded,
              size: 40,
              color: OnboardingColors.primaryGreen,
            ),
            bar,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingIllustrationFrame(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Staircase of progress.
          Positioned(
            left: 50,
            bottom: 52,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _step(i),
                ],
              ],
            ),
          ),

          const Positioned(
            top: 34,
            left: 4,
            child: OnboardingChip(
              icon: Icons.local_fire_department_rounded,
              title: 'Streak',
              value: '7 days',
              iconColor: Color(0xFFF59E0B),
            ),
          ),

          Positioned(
            top: 112,
            left: 24,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: OnboardingColors.sageGreen.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        OnboardingColors.primaryGreen.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFF59E0B),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}