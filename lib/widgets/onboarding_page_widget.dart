import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';
import '../theme/app_typography.dart';
import '../theme/app_colors.dart';

/// Widget for displaying individual onboarding slide
class OnboardingPageWidget extends StatelessWidget {
  final OnboardingModel slide;

  const OnboardingPageWidget({
    super.key,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with circular background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                slide.icon,
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            slide.title,
            style: AppTypography.h1.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            slide.subtitle,
            style: AppTypography.h3.copyWith(
              color: slide.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            slide.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
