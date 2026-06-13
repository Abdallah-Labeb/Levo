import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/core/ads/ad_service.dart';
import 'package:levo/core/storage/preferences_service.dart';

/// A wrapper widget that displays a Google Mobile Ads [BannerAd] if the user is a free tier user.
/// It renders a [SizedBox.shrink] if the user has purchased the Pro lifetime tier.
class AdaptiveBannerAdWidget extends StatefulWidget {
  const AdaptiveBannerAdWidget({super.key});

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  late final AdService _adService = getIt<AdService>();
  late final PreferencesService _prefs = getIt<PreferencesService>();
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (!_prefs.isPro) {
      setState(() {
        _bannerAd = _adService.getBannerAd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs.isPro || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      color: Colors.transparent,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
