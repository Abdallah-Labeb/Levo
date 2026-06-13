# LEVO — Architecture & Engineering Specification

> Read `00_MASTER_SYSTEM_PROMPT.md` before this file.
> This document defines HOW the app is built — patterns, data flow, and technical decisions.

---

## LAYER ARCHITECTURE

Levo uses a clean feature-slice architecture. Each feature is self-contained:

```
Feature Slice (e.g., spirit_level):
  ┌─────────────────────────────────────┐
  │  View Layer (Widgets)               │  ← pure UI, subscribes to Cubit state
  │  spirit_level_screen.dart           │
  │  bubble_level_widget.dart           │
  ├─────────────────────────────────────┤
  │  State Layer (Bloc/Cubit)           │  ← business logic, sensor reading
  │  spirit_level_cubit.dart            │
  │  spirit_level_state.dart            │
  ├─────────────────────────────────────┤
  │  Domain (models + constants)        │  ← pure Dart, no Flutter deps
  │  spirit_level_reading.dart          │
  │  constants.dart                     │
  └─────────────────────────────────────┘
         ↓ depends on
  ┌─────────────────────────────────────┐
  │  Core Services (lib/core/)          │  ← sensor service, storage, permissions
  └─────────────────────────────────────┘
```

**Rules:**
- View layer never reads sensor streams directly.
- Cubit/Bloc never imports Flutter widgets.
- Core services are injected via GetIt — never instantiated in widgets.

---

## STATE MANAGEMENT PATTERNS

### Pattern 1: Sensor Tool Cubit

All sensor-based tools follow this exact Cubit pattern:

```dart
// spirit_level_state.dart
enum SpiritLevelMode { flat2d, edge1d, plumb }
enum LevelStatus { level, close, off }

@immutable
class SpiritLevelState extends Equatable {
  const SpiritLevelState({
    this.pitch = 0.0,
    this.roll = 0.0,
    this.status = LevelStatus.off,
    this.mode = SpiritLevelMode.flat2d,
    this.isHeld = false,
    this.showPercent = false,
    this.isSensorAvailable = true,
    this.errorMessage,
  });

  final double pitch;
  final double roll;
  final LevelStatus status;
  final SpiritLevelMode mode;
  final bool isHeld;
  final bool showPercent;
  final bool isSensorAvailable;
  final String? errorMessage;

  // Derived values — compute here, not in widgets
  double get displayAngle => mode == SpiritLevelMode.flat2d
      ? math.sqrt(pitch * pitch + roll * roll)
      : pitch;

  double get displayPercent => math.tan(displayAngle * math.pi / 180) * 100;

  SpiritLevelState copyWith({...}) { ... }

  @override
  List<Object?> get props => [pitch, roll, status, mode, isHeld, showPercent,
      isSensorAvailable, errorMessage];
}
```

```dart
// spirit_level_cubit.dart
class SpiritLevelCubit extends Cubit<SpiritLevelState> {
  SpiritLevelCubit({
    required PreferencesService prefs,
  }) : _prefs = prefs, super(const SpiritLevelState());

  final PreferencesService _prefs;
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  // Low-pass filter state
  double _filteredPitch = 0.0;
  double _filteredRoll = 0.0;
  double get _alpha => _computeAlpha(_prefs.levelViscosity);

  static double _computeAlpha(double viscosity) {
    // viscosity 0..1 → alpha 1.0..0.03
    return 1.0 - (viscosity * 0.97);
  }

  Future<void> initialize() async {
    // Check sensor availability
    // Load persisted mode, calibration offsets
    // Start listening
  }

  void startListening() {
    try {
      _sensorSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.ui,
      ).listen(
        _onSensorEvent,
        onError: (_) => emit(state.copyWith(
          isSensorAvailable: false,
        )),
      );
    } catch (_) {
      emit(state.copyWith(isSensorAvailable: false));
    }
  }

  void _onSensorEvent(AccelerometerEvent event) {
    if (state.isHeld) return; // freeze when hold is active

    final rawPitch = math.atan2(-event.x,
        math.sqrt(event.y * event.y + event.z * event.z)) *
        (180 / math.pi);
    final rawRoll = math.atan2(event.y, event.z) * (180 / math.pi);

    // Apply low-pass filter
    _filteredPitch = _alpha * rawPitch + (1 - _alpha) * _filteredPitch;
    _filteredRoll  = _alpha * rawRoll  + (1 - _alpha) * _filteredRoll;

    // Apply calibration offset
    final calPitch = _filteredPitch - _prefs.calLevelPitch;
    final calRoll  = _filteredRoll  - _prefs.calLevelRoll;

    // Determine level status
    final angle = math.sqrt(calPitch * calPitch + calRoll * calRoll);
    final threshold = _prefs.levelThreshold;
    final status = angle <= threshold
        ? LevelStatus.level
        : angle <= threshold * 3
            ? LevelStatus.close
            : LevelStatus.off;

    emit(state.copyWith(
      pitch: calPitch,
      roll: calRoll,
      status: status,
    ));
  }

  void toggleHold() => emit(state.copyWith(isHeld: !state.isHeld));
  void togglePercent() => emit(state.copyWith(showPercent: !state.showPercent));
  void setMode(SpiritLevelMode mode) { ... }

  @override
  Future<void> close() async {
    await _sensorSub?.cancel();
    return super.close();
  }
}
```

### Pattern 2: Pure Math Tool (Unit Converter)

No Cubit needed for async operations — use a simple Cubit with synchronous computation:

```dart
class UnitConverterCubit extends Cubit<UnitConverterState> {
  UnitConverterCubit() : super(UnitConverterState.initial());

  void convert({required double input, required UnitCategory category,
                required String fromUnit, required String toUnit}) {
    // Pure computation — no async, no sensors
    final result = ConversionEngine.convert(
      value: input, category: category,
      from: fromUnit, to: toUnit,
    );
    emit(state.copyWith(result: result, ...));
  }
}
```

---

## CORE SERVICES

### PreferencesService

Single source of truth for all persistent state. Wrap SharedPreferences here — never call it directly from a Cubit.

```dart
// lib/core/storage/preferences_service.dart
class PreferencesService {
  PreferencesService(this._prefs);
  final SharedPreferences _prefs;

  // ── Spirit Level ─────────────────────────────────────────────────────────
  static const _kCalLevelPitch   = 'cal_level_pitch';
  static const _kCalLevelRoll    = 'cal_level_roll';
  static const _kLevelViscosity  = 'level_viscosity';
  static const _kLevelThreshold  = 'level_threshold';
  static const _kLevelMode       = 'level_mode';
  static const _kLevelSoundOn    = 'level_sound';
  static const _kLevelHapticOn   = 'level_haptic';

  double get calLevelPitch => _prefs.getDouble(_kCalLevelPitch) ?? 0.0;
  Future<void> setCalLevelPitch(double v) => _prefs.setDouble(_kCalLevelPitch, v);

  double get levelViscosity => _prefs.getDouble(_kLevelViscosity) ?? 0.7;
  Future<void> setLevelViscosity(double v) => _prefs.setDouble(_kLevelViscosity, v);

  double get levelThreshold => _prefs.getDouble(_kLevelThreshold) ?? 1.0;

  // ── Ruler ─────────────────────────────────────────────────────────────────
  static const _kRulerScaleFactor   = 'ruler_scale_factor';
  static const _kRulerDefaultUnit   = 'ruler_default_unit';

  double get rulerScaleFactor => _prefs.getDouble(_kRulerScaleFactor) ?? 1.0;

  // ── Pro / Ads ─────────────────────────────────────────────────────────────
  static const _kIsPro          = 'levo_prem_status';
  static const _kLastInterstitialMs = 'last_interstitial_ts';

  bool get isPro => _prefs.getBool(_kIsPro) ?? false;
  Future<void> setIsPro(bool v) => _prefs.setBool(_kIsPro, v);

  int get lastInterstitialMs => _prefs.getInt(_kLastInterstitialMs) ?? 0;
  Future<void> setLastInterstitialMs(int ms) =>
      _prefs.setInt(_kLastInterstitialMs, ms);

  // ── Onboarding ────────────────────────────────────────────────────────────
  static const _kOnboardingDone = 'onboarding_complete';
  bool get onboardingComplete => _prefs.getBool(_kOnboardingDone) ?? false;
  Future<void> markOnboardingComplete() =>
      _prefs.setBool(_kOnboardingDone, true);

  // ── App Settings ─────────────────────────────────────────────────────────
  static const _kLanguageCode  = 'language_code';
  static const _kKeepScreenOn  = 'keep_screen_on';

  String? get languageCode => _prefs.getString(_kLanguageCode);
  Future<void> setLanguageCode(String code) =>
      _prefs.setString(_kLanguageCode, code);

  bool get keepScreenOn => _prefs.getBool(_kKeepScreenOn) ?? true;
  Future<void> setKeepScreenOn(bool v) => _prefs.setBool(_kKeepScreenOn, v);
}
```

### SensorAvailabilityService

Checks which sensors exist on the device at startup. Result drives the green/red dots on home screen.

```dart
// lib/core/sensors/sensor_availability_service.dart
class SensorAvailabilityService {
  /// Returns true if accelerometer is available.
  /// Use a brief subscription test, not just package availability.
  Future<bool> checkAccelerometer() async {
    try {
      await accelerometerEventStream().first
          .timeout(const Duration(seconds: 2));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkMagnetometer() async { ... }
  Future<bool> checkAmbientLight() async { ... }
  // Microphone and Camera: permission_handler checks only
}
```

### AdService

Centralize all ad logic here. Cubits call this service — they never reference `google_mobile_ads` directly.

```dart
// lib/core/ads/ad_service.dart
class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  final PreferencesService _prefs;

  /// Returns null if user is Pro
  BannerAd? getBannerAd(AdSize size) {
    if (_prefs.isPro) return null;
    return _bannerAd;
  }

  /// Shows interstitial max once per 10 minutes
  Future<void> maybeShowInterstitial() async {
    if (_prefs.isPro) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = _prefs.lastInterstitialMs;
    if (now - last < const Duration(minutes: 10).inMilliseconds) return;
    // show ad
    await _prefs.setLastInterstitialMs(now);
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
```

---

## NAVIGATION — GoRouter

```dart
// lib/app/router/app_router.dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/spirit-level',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SpiritLevelCubit>()..initialize(),
        child: const SpiritLevelScreen(),
      ),
    ),
    GoRoute(path: '/compass',         builder: (_, __) => ...),
    GoRoute(path: '/ruler',           builder: (_, __) => ...),
    GoRoute(path: '/protractor',      builder: (_, __) => ...),
    GoRoute(path: '/sound-meter',     builder: (_, __) => ...),
    GoRoute(path: '/vibration-meter', builder: (_, __) => ...),
    GoRoute(path: '/light-meter',     builder: (_, __) => ...),
    GoRoute(path: '/metal-detector',  builder: (_, __) => ...),
    GoRoute(path: '/unit-converter',  builder: (_, __) => ...),
    GoRoute(path: '/clinometer',      builder: (_, __) => ...),
    GoRoute(path: '/settings',        builder: (_, __) => ...),
  ],
);
```

Cubit is created ON the route, not injected globally. This ensures sensor streams start only when the tool is opened and stop when it's closed (BlocProvider auto-closes the Cubit when the route is popped).

---

## DEPENDENCY INJECTION — GetIt

```dart
// lib/app/di/injection.dart
final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core — eager singletons
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<PreferencesService>(PreferencesService(prefs));
  getIt.registerSingleton<SensorAvailabilityService>(SensorAvailabilityService());
  getIt.registerSingleton<AdService>(AdService(getIt<PreferencesService>()));

  // Feature Cubits — factories (new instance per route)
  getIt.registerFactory<SpiritLevelCubit>(
    () => SpiritLevelCubit(prefs: getIt<PreferencesService>()),
  );
  getIt.registerFactory<CompassCubit>(
    () => CompassCubit(prefs: getIt<PreferencesService>()),
  );
  // ... all other cubits
}
```

---

## SENSOR LOW-PASS FILTER — SHARED IMPLEMENTATION

Do not duplicate this logic. Put it in core and reuse.

```dart
// lib/core/sensors/low_pass_filter.dart

/// Exponential moving average (EMA) low-pass filter.
/// alpha close to 1.0 = raw/fast. alpha close to 0.0 = smooth/slow.
class LowPassFilter {
  LowPassFilter({required double alpha}) : _alpha = alpha;

  double _alpha;
  double _value = 0.0;
  bool _initialized = false;

  /// Update [alpha] when user changes viscosity setting.
  set alpha(double value) => _alpha = value.clamp(0.0, 1.0);

  double filter(double newValue) {
    if (!_initialized) {
      _value = newValue;
      _initialized = true;
      return _value;
    }
    _value = _alpha * newValue + (1.0 - _alpha) * _value;
    return _value;
  }

  void reset() {
    _initialized = false;
    _value = 0.0;
  }
}
```

The Spirit Level, Vibration Meter, and Clinometer all share this class with different alpha values.

---

## CUSTOM PAINTER PERFORMANCE RULES

All CustomPainter widgets in this app (bubble level, compass, analog dial, seismograph, ruler, clinometer slope diagram) MUST follow these rules:

### Rule 1: shouldRepaint must be precise
```dart
// ✅ CORRECT
@override
bool shouldRepaint(BubbleLevelPainter oldDelegate) =>
    oldDelegate.pitch != pitch ||
    oldDelegate.roll != roll ||
    oldDelegate.status != status;

// ❌ WRONG — causes full repaint every frame even when data unchanged
@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
```

### Rule 2: Wrap in RepaintBoundary
```dart
// In the widget tree:
RepaintBoundary(
  child: CustomPaint(
    painter: BubbleLevelPainter(pitch: state.pitch, ...),
    size: Size(containerSize, containerSize),
  ),
)
```

### Rule 3: Pre-compute paint objects
```dart
class BubbleLevelPainter extends CustomPainter {
  // Pre-allocate Paint objects — do NOT create them in paint()
  static final _fluidPaint = Paint()
    ..color = const Color(0xFF0A1A0F)
    ..style = PaintingStyle.fill;

  static final _gridPaint = Paint()
    ..color = const Color(0xFF18281A)
    ..strokeWidth = 1.0;

  // ❌ WRONG — allocates new object every frame
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green; // BAD
  }
}
```

### Rule 4: Seismograph uses a queue, not a list
```dart
// lib/features/vibration_meter/widgets/seismograph_painter.dart
class SeismographPainter extends CustomPainter {
  // Queue<double> passed in — do NOT store raw history in the painter
  const SeismographPainter({required this.samples, required this.peakValue});
  final List<double> samples; // converted from Queue externally
  final double peakValue;
}

// In the Cubit:
final Queue<double> _samples = Queue();
void _onSensorEvent(AccelerometerEvent e) {
  final value = _computeNetVibration(e);
  _samples.addLast(value);
  if (_samples.length > _maxSamples) _samples.removeFirst();
  emit(state.copyWith(samples: _samples.toList(), ...));
}
```

---

## LOCALIZATION SETUP

### pubspec.yaml additions
```yaml
flutter:
  generate: true

flutter_localizations:
  sdk: flutter
```

### l10n.yaml (project root)
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
nullable-getter: false
```

### Usage in widgets
```dart
// Access via extension for brevity
extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// In a widget:
Text(context.l10n.spiritLevelTitle)
```

### app_en.arb structure (excerpt)
```json
{
  "@@locale": "en",
  "@@last_modified": "2024-01-01",

  "appName": "Levo",
  "@appName": { "description": "Application name" },

  "homeScreenTitle": "Levo",
  "@homeScreenTitle": { "description": "Home screen header title" },

  "spiritLevelTitle": "Spirit Level",
  "@spiritLevelTitle": { "description": "Tool screen title" },

  "spiritLevelModeFlat": "2D Surface",
  "spiritLevelModeEdge": "1D Edge",
  "spiritLevelModePlumb": "Plumb Bob",

  "spiritLevelButtonCalibrate": "Calibrate",
  "spiritLevelButtonHold": "Hold",
  "spiritLevelButtonRelease": "Release",
  "spiritLevelButtonSetRef": "Set Reference",
  "spiritLevelLabelHeld": "HOLD",

  "spiritLevelErrorNoSensor": "Accelerometer not available on this device",
  "spiritLevelGimbalLockHint": "Rotate device to avoid gimbal lock",

  "commonUnitDegrees": "°",
  "commonUnitPercent": "%",
  "commonUnitMm": "mm",
  "commonUnitCm": "cm",
  "commonUnitInch": "in",
  "commonUnitLux": "lx",
  "commonUnitDecibel": "dB",
  "commonUnitMicrotesla": "µT",
  "commonUnitMetersPerSecSq": "m/s²",

  "commonButtonReset": "Reset",
  "commonButtonCopy": "Copy",
  "commonButtonClose": "Close",
  "commonButtonOpenSettings": "Open Settings",

  "sensorErrorTitle": "Sensor Unavailable",
  "sensorErrorBody": "{sensorName} is not available on this device.",
  "@sensorErrorBody": {
    "placeholders": {
      "sensorName": { "type": "String" }
    }
  },

  "permissionMicTitle": "Microphone Access",
  "permissionMicBody": "Needed to measure sound levels",
  "permissionLocationTitle": "Location Access",
  "permissionLocationBody": "Used once to compute magnetic declination for true north",
  "permissionCameraTitle": "Camera Access",
  "permissionCameraBody": "Used to estimate ambient light when sensor unavailable",
  "permissionDeniedPermanentlyBody": "Permission permanently denied. Open app settings to grant it.",

  "settingsTitle": "Settings",
  "settingsSectionAppearance": "Appearance",
  "settingsSectionDefaults": "Measurement Defaults",
  "settingsSectionSensor": "Sensor & Calibration",
  "settingsSectionDisplay": "Display",
  "settingsSectionPro": "Pro & Ads",
  "settingsSectionAbout": "About",

  "settingsThemeLabel": "Theme",
  "settingsThemeDark": "Dark",
  "settingsThemeLight": "Light (Coming Soon)",
  "settingsThemeSystem": "System (Coming Soon)",

  "settingsLanguageLabel": "Language",
  "settingsLanguageEnglish": "English",
  "settingsLanguageArabic": "العربية",
  "settingsLanguageSystem": "System Default",

  "settingsKeepScreenOn": "Keep Screen On",
  "settingsProStatusFree": "Free — Ads Enabled",
  "settingsProStatusPro": "Pro — No Ads",
  "settingsProUpgradeButton": "Remove Ads — $2.99",

  "onboardingPage1Title": "10 Professional Tools",
  "onboardingPage1Subtitle": "One app. Always offline.",
  "onboardingPage2Title": "Industrial Feel",
  "onboardingPage2Subtitle": "Real precision, real materials.",
  "onboardingPage3Title": "Calibrate for Accuracy",
  "onboardingPage3Subtitle": "Set up the level and ruler once — they stay calibrated.",
  "onboardingButtonNext": "Next",
  "onboardingButtonFinish": "Get Started",

  "compassAccuracyLow": "Low accuracy — calibrate sensor",
  "compassAccuracyMedium": "Medium accuracy",
  "compassAccuracyHigh": "High accuracy",
  "compassCalibrationHint": "Wave your phone in a figure-8 pattern",
  "compassInterferenceWarning": "Magnetic interference detected",
  "compassLocked": "LOCKED",
  "compassTrueNorthLabel": "True North",
  "compassDeclinationLabel": "Declination",

  "rulerUncalibratedWarning": "Ruler not calibrated — readings may be inaccurate",
  "rulerCalibrationTitle": "Calibrate Ruler",
  "rulerPresetCreditCard": "Credit Card (85.6 mm)",
  "rulerPresetA4Width": "A4 Width (210 mm)",
  "rulerPresetA4Height": "A4 Height (297 mm)",
  "rulerPresetIdCard": "ID Card (54 mm)",
  "rulerPresetCustom": "Custom size",
  "rulerMarkerA": "A",
  "rulerMarkerB": "B",

  "metalDetectorFirstLaunchWarning": "Results may be affected by nearby electronics, speaker magnets, or metal tables.",
  "metalDetectorRecalibrate": "Recalibrate",
  "metalDetectorDetectionNone": "No metal detected",
  "metalDetectorDetectionWeak": "Weak signal",
  "metalDetectorDetectionMedium": "Medium signal",
  "metalDetectorDetectionStrong": "Strong signal",
  "metalDetectorDetectionVeryStrong": "Very strong signal",

  "soundMeterPeak": "Peak",
  "soundMeterAverage": "Avg",
  "soundMeterMin": "Min",
  "soundMeterZoneSilence": "Silence",
  "soundMeterZoneWhisper": "Whisper",
  "soundMeterZoneConversation": "Conversation",
  "soundMeterZoneTraffic": "Traffic",
  "soundMeterZoneLoud": "Loud",
  "soundMeterZoneDangerous": "Dangerous",
  "soundMeterZoneJet": "Jet / Extreme",

  "clinometerDirectionLeft": "Left side higher",
  "clinometerDirectionRight": "Right side higher",
  "clinometerDirectionLevel": "Level",
  "clinometerGradeFlat": "Flat / Level",
  "clinometerGradeDrainage": "Minimum drainage slope",
  "clinometerGradePedRamp": "Gentle pedestrian ramp",
  "clinometerGradeAda": "ADA/DDA max ramp",
  "clinometerGradeSteepRamp": "Steep ramp",
  "clinometerGradeSteepRoad": "Very steep road"
}
```

### app_ar.arb must mirror every key from app_en.arb
All values in Arabic. Do NOT use placeholder translations or `TODO` values. If a value is a unit symbol that is the same in Arabic (like "°" or "mm"), it's acceptable to duplicate. But all UI text MUST be proper Arabic.

---

## ANDROID MANIFEST REQUIREMENTS

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="...">

  <!-- Required for in_app_purchase billing only -->
  <uses-permission android:name="android.permission.INTERNET" />

  <!-- Declared but not requested at startup — permission_handler handles runtime -->
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.VIBRATE" />

  <!-- Sensors — declared as "not required" so app installs on devices without them -->
  <uses-feature android:name="android.hardware.sensor.accelerometer"
                android:required="false" />
  <uses-feature android:name="android.hardware.sensor.compass"
                android:required="false" />
  <uses-feature android:name="android.hardware.sensor.light"
                android:required="false" />

  <application
    android:label="Levo"
    android:icon="@mipmap/ic_launcher"
    android:hardwareAccelerated="true"
    android:usesCleartextTraffic="false">   <!-- NO HTTP traffic -->

    <activity
      android:name=".MainActivity"
      android:exported="true"
      android:screenOrientation="portrait"   <!-- Default; overrideable per tool -->
      android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
      android:windowSoftInputMode="adjustResize">
      ...
    </activity>
  </application>
</manifest>
```

---

## WAKELOCK PATTERN

Every tool screen (NOT home, NOT settings) must manage WakeLock:

```dart
// In every tool screen's State:
@override
void initState() {
  super.initState();
  _acquireWakeLock();
}

@override
void dispose() {
  WakelockPlus.disable();
  super.dispose();
}

Future<void> _acquireWakeLock() async {
  final keepOn = getIt<PreferencesService>().keepScreenOn;
  if (keepOn) await WakelockPlus.enable();
}
```

---

## ADS INTEGRATION RULES

- Banner ad: `AdaptiveBannerAd` at the BOTTOM of tool screens and home screen.
- Ad widget must be wrapped in a `Visibility(visible: !isPro)` — never rendered for Pro users.
- Minimum bottom padding on all tool content = ad banner height when free tier is active.
- NEVER show a banner ad OVER measurement content. The tool content must scroll/resize ABOVE the ad.
- Interstitial: only on return to Home from any tool screen. Not on first open, not mid-tool.

```dart
// In HomeScreen, listen to when a tool route is popped:
// lib/features/home/view/home_screen.dart
// Use a post-frame callback after GoRouter.pop() resolves
WidgetsBinding.instance.addPostFrameCallback((_) {
  getIt<AdService>().maybeShowInterstitial();
});
```

---

## TESTING REQUIREMENTS

Every Cubit must have a corresponding test file:

```
test/
├── unit/
│   ├── features/
│   │   ├── spirit_level/
│   │   │   └── spirit_level_cubit_test.dart
│   │   ├── compass/
│   │   │   └── compass_cubit_test.dart
│   │   └── unit_converter/
│   │       └── conversion_engine_test.dart   ← pure math, fully testable
│   └── core/
│       └── low_pass_filter_test.dart
└── widget/
    ├── home_screen_test.dart
    └── led_display_test.dart
```

Minimum test coverage required:
- All conversion formulas in `unit_converter` → 100% (pure math, no excuses)
- Low-pass filter → 100%
- Sensor angle math (pitch/roll) → 100%
- Calibration offset computation → 100%
- Ad service rate limiting (10-minute rule) → 100%
- Cubit state transitions → critical paths only (not every edge case)
