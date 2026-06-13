import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/noise_texture_helper.dart';
import 'package:levo/l10n/l10n_extension.dart';

/// Walkthrough shown on the very first launch of the application.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _onFinish() async {
    final prefs = getIt<PreferencesService>();
    await prefs.markOnboardingComplete();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShaderMask(
        shaderCallback: (rect) {
          return NoiseTextureHelper.getNoiseShader(rect) ??
              const LinearGradient(
                colors: [Colors.transparent, Colors.transparent],
              ).createShader(rect);
        },
        blendMode: BlendMode.srcOver,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            children: [
              const Spacer(),
              // Horizontal PageView of Onboarding Details
              SizedBox(
                height: 360.0,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                  },
                  children: [
                    _OnboardingCard(
                      title: context.l10n.onboardingPage1Title,
                      subtitle: context.l10n.onboardingPage1Subtitle,
                      icon: Icons.grid_view_rounded,
                    ),
                    _OnboardingCard(
                      title: context.l10n.onboardingPage2Title,
                      subtitle: context.l10n.onboardingPage2Subtitle,
                      icon: Icons.construction_rounded,
                    ),
                    _OnboardingCard(
                      title: context.l10n.onboardingPage3Title,
                      subtitle: context.l10n.onboardingPage3Subtitle,
                      icon: Icons.compass_calibration_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space32),
              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isActive = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: isActive ? 16.0 : 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.kYellow
                          : AppColors.kChromeDark,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: isActive
                          ? const [
                              BoxShadow(
                                color: AppColors.kYellow,
                                blurRadius: 4.0,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              const Spacer(),
              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPage < 2)
                    TactileButton(
                      onPressed: _onNext,
                      text: context.l10n.onboardingButtonNext,
                      icon: const Icon(Icons.arrow_forward_rounded),
                    )
                  else
                    TactileButton(
                      onPressed: _onFinish,
                      text: context.l10n.onboardingButtonFinish,
                      icon: const Icon(Icons.check_rounded),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return MetalPanel(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Skeuomorphic circular emblem container
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: AppColors.kSurfaceInset,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.kBorderShadow, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12FFFFFF),
                  offset: Offset(-1, -1),
                  blurRadius: 2,
                ),
                BoxShadow(
                  color: Color(0xAA000000),
                  offset: Offset(2, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.kYellow, size: 40.0),
          ),
          const SizedBox(height: AppDimensions.space24),
          Text(
            title,
            style: AppTypography.kTitleL.copyWith(fontSize: 22.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space12),
          Text(
            subtitle,
            style: AppTypography.kBodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
