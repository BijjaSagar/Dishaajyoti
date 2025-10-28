import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class OnboardingModel {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final Color color;

  OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });

  static List<OnboardingModel> getSlides(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return [
      OnboardingModel(
        title: l10n.onboarding_slide1_title,
        subtitle: l10n.onboarding_slide1_subtitle,
        description: l10n.onboarding_slide1_description,
        icon: '🎯',
        color: const Color(0xFF0066CC),
      ),
      OnboardingModel(
        title: l10n.onboarding_slide2_title,
        subtitle: l10n.onboarding_slide2_subtitle,
        description: l10n.onboarding_slide2_description,
        icon: '✋',
        color: const Color(0xFF2196F3),
      ),
      OnboardingModel(
        title: l10n.onboarding_slide3_title,
        subtitle: l10n.onboarding_slide3_subtitle,
        description: l10n.onboarding_slide3_description,
        icon: '⭐',
        color: const Color(0xFF4CAF50),
      ),
      OnboardingModel(
        title: l10n.onboarding_slide4_title,
        subtitle: l10n.onboarding_slide4_subtitle,
        description: l10n.onboarding_slide4_description,
        icon: '🔢',
        color: const Color(0xFFFF9800),
      ),
      OnboardingModel(
        title: l10n.onboarding_slide5_title,
        subtitle: l10n.onboarding_slide5_subtitle,
        description: l10n.onboarding_slide5_description,
        icon: '📄',
        color: const Color(0xFF9C27B0),
      ),
      OnboardingModel(
        title: l10n.onboarding_slide6_title,
        subtitle: l10n.onboarding_slide6_subtitle,
        description: l10n.onboarding_slide6_description,
        icon: '🚀',
        color: const Color(0xFFFF6B35),
      ),
    ];
  }
}
