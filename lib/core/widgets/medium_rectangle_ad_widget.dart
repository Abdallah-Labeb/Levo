import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/core/storage/preferences_service.dart';

/// A widget that displays a Google Mobile Ads [BannerAd] with [AdSize.mediumRectangle] (300x250)
/// if the user is a free tier user.
/// It renders a [SizedBox.shrink] if the user has purchased the Pro lifetime tier.
class MediumRectangleAdWidget extends StatefulWidget {
  const MediumRectangleAdWidget({super.key});

  @override
  State<MediumRectangleAdWidget> createState() => _MediumRectangleAdWidgetState();
}

class _MediumRectangleAdWidgetState extends State<MediumRectangleAdWidget> {
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
    if (!_prefs.isPro) {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        size: AdSize.mediumRectangle,
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
      alignment: Alignment.center,
      width: double.infinity,
      height: 250.0,
      color: Colors.transparent,
      child: Container(
        width: 300.0,
        height: 250.0,
        decoration: _isAdLoaded && _bannerAd != null
            ? BoxDecoration(
                color: const Color(0xFF0F1114), // Dark inset slot background
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: const Color(0xFF1E2126), // uniform edge border
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              )
            : const BoxDecoration(
                color: Colors.transparent,
              ),
        child: _isAdLoaded && _bannerAd != null
            ? AdWidget(ad: _bannerAd!)
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
    );
  }
}
