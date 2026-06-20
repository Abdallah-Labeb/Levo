import 'package:shared_preferences/shared_preferences.dart';

/// Service wrapping [SharedPreferences] for Levo application settings.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  // Key Constants
  static const _kOnboardingComplete = 'onboarding_complete';
  static const _kIsPro = 'levo_prem_status';
  static const _kLastInterstitialMs = 'last_interstitial_ts';
  static const _kLanguageCode = 'language_code';
  static const _kKeepScreenOn = 'keep_screen_on';

  static const _kLevelViscosity = 'level_viscosity';
  static const _kLevelThreshold = 'level_threshold';
  static const _kLevelMode = 'level_mode';
  static const _kLevelSoundOn = 'level_sound';
  static const _kLevelHapticOn = 'level_haptic';

  static const _kRulerScaleFactor = 'ruler_scale_factor';
  static const _kRulerDefaultUnit = 'ruler_default_unit';

  static const _kConverterDefaultCat = 'converter_default_cat';
  static const _kTrueNorthEnabled = 'true_north_enabled';
  static const _kMetalFirstLaunchWarned = 'metal_first_launch_warned';
  static const _kProtractorSnapEnabled = 'protractor_snap_enabled';

  // ── Onboarding ────────────────────────────────────────────────────────────
  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;
  Future<void> markOnboardingComplete() =>
      _prefs.setBool(_kOnboardingComplete, true);

  // ── Premium / Pro Status ──────────────────────────────────────────────────
  bool get isPro => _prefs.getBool(_kIsPro) ?? false;
  Future<void> setIsPro(bool value) => _prefs.setBool(_kIsPro, value);

  // ── Ad Interstitial Delay ──────────────────────────────────────────────────
  int get lastInterstitialMs => _prefs.getInt(_kLastInterstitialMs) ?? 0;
  Future<void> setLastInterstitialMs(int ms) =>
      _prefs.setInt(_kLastInterstitialMs, ms);

  // ── General Application Settings ──────────────────────────────────────────
  String? get languageCode => _prefs.getString(_kLanguageCode);
  Future<void> setLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_kLanguageCode);
    } else {
      await _prefs.setString(_kLanguageCode, code);
    }
  }

  bool get keepScreenOn => _prefs.getBool(_kKeepScreenOn) ?? true;
  Future<void> setKeepScreenOn(bool value) =>
      _prefs.setBool(_kKeepScreenOn, value);

  // ── Spirit Level Settings ─────────────────────────────────────────────────
  double get levelViscosity => _prefs.getDouble(_kLevelViscosity) ?? 0.5;
  Future<void> setLevelViscosity(double value) =>
      _prefs.setDouble(_kLevelViscosity, value);

  double get levelThreshold => _prefs.getDouble(_kLevelThreshold) ?? 1.0;
  Future<void> setLevelThreshold(double value) =>
      _prefs.setDouble(_kLevelThreshold, value);

  int get levelModeIndex => _prefs.getInt(_kLevelMode) ?? 1;
  Future<void> setLevelModeIndex(int value) =>
      _prefs.setInt(_kLevelMode, value);

  bool get levelSoundOn => _prefs.getBool(_kLevelSoundOn) ?? true;
  Future<void> setLevelSoundOn(bool value) =>
      _prefs.setBool(_kLevelSoundOn, value);

  bool get levelHapticOn => _prefs.getBool(_kLevelHapticOn) ?? true;
  Future<void> setLevelHapticOn(bool value) =>
      _prefs.setBool(_kLevelHapticOn, value);

  // ── Ruler Settings ────────────────────────────────────────────────────────
  double get rulerScaleFactor => _prefs.getDouble(_kRulerScaleFactor) ?? 1.0;
  Future<void> setRulerScaleFactor(double value) =>
      _prefs.setDouble(_kRulerScaleFactor, value);

  String get rulerDefaultUnit => _prefs.getString(_kRulerDefaultUnit) ?? 'mm';
  Future<void> setRulerDefaultUnit(String value) =>
      _prefs.setString(_kRulerDefaultUnit, value);

  // ── Unit Converter Settings ────────────────────────────────────────────────
  String get converterDefaultCategory =>
      _prefs.getString(_kConverterDefaultCat) ?? 'length';
  Future<void> setConverterDefaultCategory(String value) =>
      _prefs.setString(_kConverterDefaultCat, value);

  // ── Compass Settings ──────────────────────────────────────────────────────
  bool get trueNorthEnabled => _prefs.getBool(_kTrueNorthEnabled) ?? false;
  Future<void> setTrueNorthEnabled(bool value) =>
      _prefs.setBool(_kTrueNorthEnabled, value);

  // ── Metal Detector Settings ───────────────────────────────────────────────
  bool get metalFirstLaunchWarned =>
      _prefs.getBool(_kMetalFirstLaunchWarned) ?? false;
  Future<void> setMetalFirstLaunchWarned(bool value) =>
      _prefs.setBool(_kMetalFirstLaunchWarned, value);

  // ── Protractor Settings ────────────────────────────────────────────────────
  bool get protractorSnapEnabled =>
      _prefs.getBool(_kProtractorSnapEnabled) ?? true;
  Future<void> setProtractorSnapEnabled(bool value) =>
      _prefs.setBool(_kProtractorSnapEnabled, value);

  // ── Reset All Settings ────────────────────────────────────────────────────
  Future<void> clearAllCalibration() async {
    await _prefs.remove(_kRulerScaleFactor);
    await _prefs.remove(_kMetalFirstLaunchWarned);
  }
}
