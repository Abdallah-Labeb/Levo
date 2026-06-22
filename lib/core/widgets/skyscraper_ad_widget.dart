import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/widgets/noise_background.dart';

/// A reusable widget that displays a Google Mobile Ads [BannerAd] with [AdSize.skyscraper] (120x600)
/// if the user is a free tier user.
/// It renders a [SizedBox.shrink] if the user has purchased the Pro lifetime tier.
class SkyscraperAdWidget extends StatefulWidget {
  const SkyscraperAdWidget({super.key});

  @override
  State<SkyscraperAdWidget> createState() => _SkyscraperAdWidgetState();
}

class _SkyscraperAdWidgetState extends State<SkyscraperAdWidget> {
  late final PreferencesService _prefs = getIt<PreferencesService>();
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    // ponytail: YAGNI - only load ad if not a pro user
    if (!_prefs.isPro) {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        size: const AdSize(width: 120, height: 600),
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _bannerAd = null;
                _isAdLoaded = false;
              });
            }
          },
        ),
      )..load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs.isPro) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 120.0,
      height: double.infinity,
      color: AppColors.kBackground,
      child: NoiseBackground(
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.kBorderShadow, width: 1.5),
            ),
            color: AppColors.kSurfaceInset,
          ),
          alignment: Alignment.center,
          child: _isAdLoaded && _bannerAd != null
              ? SizedBox(
                  width: 120.0,
                  height: 600.0,
                  child: AdWidget(ad: _bannerAd!),
                )
              : const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.kChromeMid,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
