import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:levo/core/storage/preferences_service.dart';

/// Manages loading, showing, and rate-limiting Google Mobile Ads.
/// Respects user Premium (Pro) status.
class AdService {
  AdService(this._prefs);

  final PreferencesService _prefs;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // Test Ad Unit IDs (Android)
  static const String _kTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _kTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Initializes the Mobile Ads SDK.
  Future<void> initialize() async {
    if (_prefs.isPro) return;
    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  /// Loads the banner ad.
  void _loadBannerAd() {
    if (_prefs.isPro) return;

    _bannerAd = BannerAd(
      adUnitId: _kTestBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  /// Loads the interstitial ad.
  void _loadInterstitialAd() {
    if (_prefs.isPro || _isInterstitialLoading || _interstitialAd != null)
      return;

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: _kTestInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              // Reload ad for next time
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Returns the current loaded banner ad, or null if the user is Pro.
  BannerAd? getBannerAd() {
    if (_prefs.isPro) return null;
    if (_bannerAd == null) {
      _loadBannerAd(); // Attempt to load if not initialized
    }
    return _bannerAd;
  }

  /// Shows the interstitial ad if the user is not Pro and 10 minutes have passed.
  Future<void> maybeShowInterstitial() async {
    if (_prefs.isPro) return;
    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _prefs.lastInterstitialMs;
    const tenMinutes = 10 * 60 * 1000;

    if (now - last >= tenMinutes) {
      await _interstitialAd!.show();
      await _prefs.setLastInterstitialMs(now);
    }
  }

  /// Disposes loaded ads and frees memory.
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
