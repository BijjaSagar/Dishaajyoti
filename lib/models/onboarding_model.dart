import 'package:flutter/material.dart';

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

  static List<OnboardingModel> getSlides() {
    return [
      OnboardingModel(
        title: 'Career Guidance Made Simple',
        subtitle: 'Discover Your Path',
        description:
            'Get personalized career guidance based on ancient wisdom and modern AI technology',
        icon: '🎯',
        color: const Color(0xFF0066CC),
      ),
      OnboardingModel(
        title: 'Palmistry Analysis',
        subtitle: 'Read Your Future',
        description:
            'Upload your palm image and receive detailed analysis of your life lines and destiny',
        icon: '✋',
        color: const Color(0xFF2196F3),
      ),
      OnboardingModel(
        title: 'Vedic Jyotish',
        subtitle: 'Ancient Astrology',
        description:
            'Get insights from Vedic astrology based on your birth details and planetary positions',
        icon: '⭐',
        color: const Color(0xFF4CAF50),
      ),
      OnboardingModel(
        title: 'Numerology',
        subtitle: 'Power of Numbers',
        description:
            'Discover the hidden meanings in your numbers and how they influence your life',
        icon: '🔢',
        color: const Color(0xFFFF9800),
      ),
      OnboardingModel(
        title: 'Personalized Reports',
        subtitle: 'AI-Powered Insights',
        description:
            'Receive comprehensive PDF reports with actionable guidance for your career and life',
        icon: '📄',
        color: const Color(0xFF9C27B0),
      ),
      OnboardingModel(
        title: 'Ready to Begin',
        subtitle: 'Start Your Journey',
        description:
            'Join thousands of users who have found clarity and direction with DishaAjyoti',
        icon: '🚀',
        color: const Color(0xFFFF6B35),
      ),
    ];
  }
}
