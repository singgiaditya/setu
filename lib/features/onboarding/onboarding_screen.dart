import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:gap/gap.dart';
import '../../core/theme/theme_manager.dart';
import '../../providers/storage_provider.dart';
import 'onboarding_data.dart';
import 'onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(preferencesStoreProvider);
    await prefs.setCompletedOnboarding(true);
    if (mounted) {
      context.go('/connect');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(setuColorsProvider);
    final typography = ref.watch(setuTypographyProvider);
    final isLastPage = _currentPage == onboardingPages.length - 1;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SETU',
                    style: typography.brandSmall.copyWith(color: colors.primary),
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: typography.labelMedium.copyWith(
                          color: colors.foregroundMuted,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 36, width: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    item: onboardingPages[index],
                    colors: colors,
                    typography: typography,
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: Column(
                children: [
                  // Smooth Indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingPages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: colors.primary,
                      dotColor: colors.surfaceVariant,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3.5,
                      spacing: 6,
                    ),
                  ),
                  const Gap(28),

                  // Action Buttons
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Icon(Icons.arrow_back_rounded, color: colors.foreground, size: 20),
                        ),
                        const Gap(12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLastPage) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? 'Connect Your Machine' : 'Next',
                                style: typography.labelLarge.copyWith(
                                  color: const Color(0xFF0D1117),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Gap(8),
                              Icon(
                                isLastPage ? Icons.cable_rounded : Icons.arrow_forward_rounded,
                                size: 18,
                                color: const Color(0xFF0D1117),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  TextButton.icon(
                    onPressed: () => context.push('/setup-guide'),
                    icon: Icon(Icons.help_outline_rounded, size: 14, color: colors.foregroundMuted),
                    label: Text(
                      'Need help setting up your Linux machine? View Setup Guide',
                      style: typography.bodySmall.copyWith(
                        color: colors.foregroundMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
