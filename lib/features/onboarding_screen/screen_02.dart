import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_layout.dart';
import 'screen_03.dart';

class OnboardingScreenTwo extends StatelessWidget {
  final VoidCallback onFinished;

  const OnboardingScreenTwo({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      pageIndex: 1,
      pageCount: 3,
      illustration: const _ImproveIllustration(),
      title: 'Improve a Little Every Day',
      description:
          'Set healthy limits and focus goals. Small, steady changes add up to a calmer, more balanced digital life.',
      buttonLabel: 'Next',
      buttonIcon: Icons.arrow_forward_rounded,
      onSkip: onFinished,
      onBack: () => Navigator.of(context).maybePop(),
      onNext: () => Navigator.of(context).push(
        onboardingRoute(OnboardingScreenThree(onFinished: onFinished)),
      ),
    );
  }
}

class _ImproveIllustration extends StatelessWidget {
  const _ImproveIllustration();

  @override
  Widget build(BuildContext context) {
    return OnboardingIllustrationFrame(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 40,
            top: 76,
            width: 220,
            height: 158,
            child: _BarCard(),
          ),

          const Positioned(
            top: 30,
            left: 4,
            child: OnboardingChip(
              icon: Icons.notifications_paused_outlined,
              title: 'Focus mode',
              value: 'On',
            ),
          ),

          Positioned(
            top: 50,
            right: 10,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: OnboardingColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        OnboardingColors.primaryGreen.withValues(alpha: 0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),

          const Positioned(
            bottom: 26,
            right: 0,
            child: OnboardingChip(
              icon: Icons.timer_outlined,
              title: 'Daily limit',
              value: '2h 00m',
            ),
          ),
        ],
      ),
    );
  }
}

class _BarCard extends StatelessWidget {
  const _BarCard();

  static const List<double> _heights = [30, 46, 40, 68, 88];

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      OnboardingColors.sageGreen,
      OnboardingColors.sageGreen,
      OnboardingColors.lightGreen,
      OnboardingColors.secondaryGreen,
      OnboardingColors.primaryGreen,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OnboardingColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: OnboardingColors.primaryGreen.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Focus score',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: OnboardingColors.secondaryText,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: OnboardingColors.mint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+24%',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: OnboardingColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_heights.length, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _heights[index]),
                  duration: Duration(milliseconds: 600 + index * 120),
                  curve: Curves.easeOutCubic,
                  builder: (context, height, _) {
                    return Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        color: colors[index],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}