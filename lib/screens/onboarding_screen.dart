import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_model.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// Onboarding screen with 6 slides showcasing app features
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<OnboardingModel> _slides = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize slides with localized content
    _slides = OnboardingModel.getSlides(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back and skip buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (visible after first slide)
                  if (!isFirstPage)
                    Semantics(
                      button: true,
                      label: l10n.onboarding_back,
                      hint: l10n.onboarding_back_hint,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.primaryBlue,
                        onPressed: _previousPage,
                      ),
                    )
                  else
                    const SizedBox(width: 48),

                  // Skip button
                  Semantics(
                    button: true,
                    label: l10n.onboarding_skip,
                    hint: l10n.onboarding_skip_hint,
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        l10n.onboarding_skip,
                        style: AppTypography.button.copyWith(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView with slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(slide: _slides[index]);
                },
              ),
            ),

            // Page indicators (dots)
            Semantics(
              label: l10n.onboarding_page_indicator(
                _currentPage + 1,
                _slides.length,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primaryOrange
                            : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Next/Get Started button
                  PrimaryButton(
                    label: isLastPage
                        ? l10n.onboarding_get_started
                        : l10n.onboarding_next,
                    onPressed: _nextPage,
                    width: double.infinity,
                  ),

                  // Back button for mobile (alternative to top back)
                  if (!isFirstPage) ...[
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: l10n.onboarding_back,
                      onPressed: _previousPage,
                      width: double.infinity,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
