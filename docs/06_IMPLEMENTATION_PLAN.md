# LEVO — Implementation Plan
> Phased build plan. Complete each phase fully before starting the next.
> "Fully" means: code written, l10n keys added to BOTH ARB files, and unit tests passing.

---

## PHASE 0 — Project Foundation
**Goal:** A runnable Flutter project with the full skeleton in place. No tool logic yet.

### Tasks (in order):

**0.1 — Project Init**
```bash
flutter create --org com.levo.app --project-name levo --platforms android levo
```
- Set `minSdkVersion 23` in `android/app/build.gradle`
- Enable R8 minification in `android/app/build.gradle`:
  ```gradle
  buildTypes {
    release {
      minifyEnabled true
      shrinkResources true
      proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
  }
  ```

**0.2 — Pubspec Setup**
- Add all approved packages from `00_MASTER_SYSTEM_PROMPT.md`
- Add all font assets (BebasNeue, ShareTechMono, Inter variants)
- Add all SVG icon assets (placeholder SVGs are acceptable in this phase)
- Add audio asset (`level_beep.mp3`)
- Add `l10n.yaml` and `flutter: generate: true`

**0.3 — Theme System (COMPLETE, NOT PARTIAL)**
Create these files with ALL constants defined:
- `lib/app/theme/app_colors.dart` — every color token from `03_DESIGN_SYSTEM.md`
- `lib/app/theme/app_typography.dart` — every TextStyle from `03_DESIGN_SYSTEM.md`
- `lib/app/theme/app_dimensions.dart`:
  ```dart
  class AppDimensions {
    AppDimensions._();
    // Spacing
    static const double space4  = 4.0;
    static const double space8  = 8.0;
    static const double space12 = 12.0;
    static const double space16 = 16.0;
    static const double space24 = 24.0;
    static const double space32 = 32.0;
    static const double space48 = 48.0;
    static const double space64 = 64.0;
    // Convenient aliases
    static const double paddingXS = space4;
    static const double paddingS  = space8;
    static const double paddingM  = space12;
    static const double paddingL  = space16;
    static const double paddingXL = space24;
    // Border radius
    static const double radiusPanel   = 12.0;
    static const double radiusButton  = 8.0;
    static const double radiusDisplay = 6.0;
    static const double radiusChip    = 4.0;
    // Icon sizes
    static const double iconTool     = 56.0;
    static const double iconSmall    = 16.0;
    static const double iconMedium   = 24.0;
    static const double iconBack     = 24.0;
    // App bar
    static const double appBarHeight = 56.0;
    // Sensor dot
    static const double sensorDotSize = 8.0;
    // ToolCard
    static const double toolCardAspectRatio = 0.8; // width/height
    static const double gridGap        = 12.0;
    static const double gridPaddingH   = 16.0;
    static const double gridPaddingTop = 24.0;
  }
  ```
- `lib/app/theme/app_animations.dart`:
  ```dart
  class AppAnimations {
    AppAnimations._();
    static const Duration screenTransition = Duration(milliseconds: 280);
    static const Duration buttonPress      = Duration(milliseconds: 80);
    static const Duration buttonRelease    = Duration(milliseconds: 150);
    static const Duration levelGlowPulse   = Duration(milliseconds: 400);
    static const Duration compassNeedle    = Duration(milliseconds: 200);
    static const Duration dialNeedle       = Duration(milliseconds: 150);
    static const Duration levelStatusColor = Duration(milliseconds: 300);
    static const Duration bannerDismiss    = Duration(seconds: 3);
    // Spring physics
    static const double bubbleStiffness = 120.0;
    static const double bubbleDamping   = 18.0;
  }
  ```
- `lib/app/theme/app_theme.dart` — assembles `ThemeData` using the constants above

**0.4 — Core Widgets (Skeleton)**
Build these widgets with their FULL visual implementation (not placeholders):
- `MetalPanel` — complete with gradients, borders, shadows
- `TactileButton` — complete with press animation, active state
- `LedDisplay` — complete with glow effect, dim state
- `LevoAppBar` — custom app bar with back arrow
- `LevoBanner` — MetalPanel overlay that auto-dismisses
- `SensorErrorView` — shown when a required sensor is missing
- `ToolCard` — home screen card with sensor dot

**0.5 — Localization Scaffold**
- Create `lib/l10n/app_en.arb` with ALL keys from `01_ARCHITECTURE_SPEC.md`
- Create `lib/l10n/app_ar.arb` with complete Arabic translations for every key
- Run `flutter gen-l10n` and verify `AppLocalizations` is generated
- Add `BuildContext.l10n` extension

**0.6 — DI + Router + Main**
- `lib/app/di/injection.dart` — register all services and cubits
- `lib/app/router/app_router.dart` — all 11 routes (home + 10 tools + settings)
- `lib/main.dart`:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupDependencies();
    runApp(const LevoApp());
  }

  class LevoApp extends StatelessWidget {
    const LevoApp({super.key});
    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => getIt<SettingsCubit>(),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp.router(
              routerConfig: appRouter,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: settings.locale,
              theme: AppTheme.darkTheme,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      );
    }
  }
  ```

**0.7 — Core Services**
- `PreferencesService` (complete, all keys)
- `SensorAvailabilityService`
- `AdService`
- `LowPassFilter`

**Phase 0 Completion Check:**
- `flutter analyze` → zero issues
- `flutter run` → home screen visible with correct dark background and font
- Language change in settings → UI updates to Arabic with RTL layout

---

## PHASE 1 — Home Screen + Onboarding
**Goal:** Complete home screen grid and first-launch onboarding.

### Tasks:

**1.1 — SensorAvailabilityCubit**
- Check all sensors on init
- Emit availability map: `Map<ToolId, SensorStatus>`

**1.2 — Home Screen**
- `GridView.builder` responsive: 2 columns on phones, 3 on tablets (≥600dp)
- `ToolCard` for all 10 tools
- Sensor status dots connected to `SensorAvailabilityCubit`
- Long-press bottom sheet (MetalPanel style)
- Background grain texture via `ShaderMask` + cached noise `ui.Image`
- Settings icon in top-right corner → `/settings`

**1.3 — Onboarding Flow**
- 3-page `PageView` with `MetalPanel` cards
- Only shown if `prefs.onboardingComplete == false`
- GoRouter redirect: if not onboarded, redirect `/` to `/onboarding`
- After "Get Started": mark complete, navigate to home

**1.4 — Settings Screen**
Build the complete settings screen (even though not all settings have effects yet):
- All sections from `02_FEATURES_SPECIFICATION.md`
- Language switcher: updates `SettingsCubit` locale
- Theme: shows "Coming Soon" for Light/System
- Keep Screen On toggle
- Pro status display
- About section with `showLicensePage`

---

## PHASE 2 — Spirit Level (Priority 1 Tool)
**Goal:** Fully working spirit level with all modes, calibration, and feedback.

### Tasks:

**2.1 — SpiritLevelCubit**
- Accelerometer stream with LowPassFilter
- Mode switching (2D/1D/Plumb)
- Calibration wizard logic (3-step, stores offsets)
- Hold toggle
- Sound/haptic toggle
- Degree/percent toggle
- Gimbal lock detection

**2.2 — BubbleLevelWidget (2D Mode)**
- All 5 layers as specified in `03_DESIGN_SYSTEM.md`
- Spring physics for bubble animation
- Color transitions for level status
- Glow pulse animation on level-achieved

**2.3 — BubbleLevelWidget (1D Mode)**
- Horizontal tube widget
- Bubble position based on roll only
- Same color state system

**2.4 — Plumb Bob Widget**
- Hanging line visualization
- Deviation indicator

**2.5 — Controls Panel**
- Mode selector (3-tab segmented — NOT Flutter's TabBar, custom with TactileButton)
- All control buttons as TactileButton
- Viscosity slider (custom styled — no default Slider widget chrome)
- HOLD badge overlay on LedDisplay

**2.6 — Calibration Wizard Screen**
- 3-step flow as specified
- Progress indicator (custom, not LinearProgressIndicator)

**2.7 — Sound + Haptic**
- `audioplayers` for level beep
- `vibration` package for haptic pulse
- Respects Hold state (no feedback while held)

---

## PHASE 3 — Compass
**Goal:** Tilt-compensated compass with smooth animation.

### Tasks:

**3.1 — CompassCubit**
- `FlutterCompass.events` stream
- Low-pass filter (alpha 0.2)
- Magnetic interference detection (> 30° jump in < 100ms)
- Accuracy mapping
- True North computation via Geolocator (optional, permission-gated)
- Lock/freeze heading toggle

**3.2 — CompassWidget (CustomPainter)**
- All 6 layers from `03_DESIGN_SYSTEM.md`
- Shortest-path rotation animation (handle 359° → 1° wrap)
- Chrome sweep gradient bezel
- Engraved tick marks at every 5°/10°/90°

**3.3 — Compass Screen**
- LED display for heading
- Cardinal direction label
- Accuracy indicator banner
- Calibration hint overlay
- True North toggle + declination display

---

## PHASE 4 — Ruler + Protractor (Visual Tools)

### Ruler (4.1–4.3):

**4.1 — RulerCubit**
- DPI computation from `devicePixelRatio`
- Scale factor from calibration
- Two-point marker mode

**4.2 — RulerWidget (CustomPainter)**
- Full-height ruler with tick hierarchy (major/minor/sub-minor)
- Momentum-based pan gesture
- Unit switching (mm/cm/in with fractional inch display)
- Marker A/B indicators
- Uncalibrated warning banner

**4.3 — Ruler Calibration Screen**
- Preset selector (drum picker widget — custom, not DropdownButton)
- Slider for fine-tuning
- Confirmation dialog

### Protractor (4.4–4.5):

**4.4 — ProtractorCubit**
- Angle computation between two handles
- Snap logic (common angles ± 2°)
- Reflex angle toggle

**4.5 — ProtractorWidget (CustomPainter)**
- Light paper background (the one exception to dark theme)
- Draggable Handle A (yellow) and Handle B (orange)
- Arc sector fill
- Angle label centered in sector
- Center pivot chrome circle

---

## PHASE 5 — Audio/Sensor Meters

### Sound Meter (5.1–5.2):

**5.1 — SoundMeterCubit**
- Permission request flow (with rationale screen)
- `NoiseMeter` stream
- Peak, average (5-sec rolling), min tracking
- Very loud flash (> 110 dB) + strong haptic

**5.2 — Sound Meter Screen**
- `AnalogDialWidget` (reused widget with sound zones config)
- VU bars (decorative, based on mono signal)
- Microphone grille illustration (SVG)
- LED display panel

### Vibration Meter (5.3–5.4):

**5.3 — VibrationMeterCubit**
- Net vibration computation (remove gravity: `|magnitude - 9.81|`)
- 1-second baseline calibration on start
- Queue-based sample history (10 seconds at ~30Hz)
- Peak tracking

**5.4 — Seismograph Screen**
- `SeismographPainter` — scrolling waveform
- Auto-scaling Y-axis
- Green waveform on near-black background
- Grid lines
- Peak display with timestamp

---

## PHASE 6 — Light Meter + Metal Detector

### Light Meter (6.1–6.2):

**6.1 — LightMeterCubit**
- Primary: `light` package ambient sensor
- Fallback: camera luminance estimation (permission-gated)
- EV computation: `EV = log2(lux / 2.5)`
- Scene label from lux range

**6.2 — Light Meter Screen**
- `AnalogDialWidget` (styled as vintage exposure meter)
- LED display for lux + EV
- Scene label
- Camera viewfinder frame (decorative)

### Metal Detector (6.3–6.4):

**6.3 — MetalDetectorCubit**
- 1.5-second baseline on open
- `delta_uT` computation
- Detection level mapping
- Beep interval control
- Sensitivity slider multiplier
- Recalibrate button
- First-launch warning flag (per-tool SharedPreferences key)

**6.4 — Metal Detector Screen**
- Large proximity indicator circle (fills screen)
- Color shift animation (dark → green → yellow → red)
- Concentric pulsing rings
- LED display for delta_uT
- Beep audio + haptic at correct intervals

---

## PHASE 7 — Unit Converter + Clinometer

### Unit Converter (7.1–7.2):

**7.1 — ConversionEngine (pure Dart)**
- All conversion factors as `const double`
- SI base unit approach for all categories
- Temperature formula conversion
- No async, no dependencies

```dart
// lib/features/unit_converter/domain/conversion_engine.dart
class ConversionEngine {
  static const Map<String, double> _lengthToMeter = {
    'mm': 0.001,
    'cm': 0.01,
    'm': 1.0,
    'km': 1000.0,
    'in': 0.0254,
    'ft': 0.3048,
    'yd': 0.9144,
    'mile': 1609.344,
  };
  // ... all other categories

  static double convert({
    required double value,
    required UnitCategory category,
    required String from,
    required String to,
  }) {
    if (category == UnitCategory.temperature) {
      return _convertTemperature(value, from, to);
    }
    final factors = _factorsFor(category);
    final valueInBase = value * factors[from]!;
    return valueInBase / factors[to]!;
  }
}
```

**7.2 — Unit Converter Screen**
- Horizontal scrollable category tabs (BebasNeue styled — NOT default TabBar)
- From/To panels with drum picker for unit selection
- Real-time computation on text input
- Swap button with rotation animation
- Copy button on each field

### Clinometer (7.3–7.4):

**7.3 — ClinometerCubit**
- Same accelerometer stream as spirit level (shared LowPassFilter)
- Pitch angle + grade computation
- Direction determination (left/right/level)
- Grade classification lookup
- Uses same viscosity SharedPreferences key as Spirit Level

**7.4 — Clinometer Screen**
- Top 50%: slope diagram CustomPainter
  - Ground line
  - Tilted surface line (animates)
  - Device rectangle on surface
  - Arrow + angle arc
- Bottom 50%: MetalPanel with dual LED displays
- Direction label + grade classification label
- Hold button + °/% toggle

---

## PHASE 8 — Ads + IAP
**Goal:** Integrate ads and in-app purchase for Pro tier.

### Tasks:

**8.1 — Banner Ads**
- `AdaptiveBannerAd` at bottom of home screen and all tool screens
- Respects Pro status (invisible when Pro)
- Correct bottom padding so content is not hidden behind ad

**8.2 — Interstitial Ads**
- Shown on return to home, max once per 10 minutes
- Rate limiting via `PreferencesService`

**8.3 — In-App Purchase**
- `in_app_purchase` package
- Product ID: `levo_pro_lifetime` (configure in Play Console)
- Purchase flow: tap button → purchase → on success, set `prefs.isPro = true`
- Restore purchases button in Settings
- No server validation

---

## PHASE 9 — Polish, Testing, Release Prep

### Tasks:

**9.1 — Screen Transition Animation**
- Custom GoRouter page builder: fade + slight scale (0.96 → 1.0), 280ms

**9.2 — RTL Audit**
- Open every screen with `locale: const Locale('ar')`
- Fix any `EdgeInsets.only(left:...)`, hardcoded `Row` children ordering issues
- Verify compass and bubble level do NOT flip (they should not)
- Verify all text is in Arabic

**9.3 — Performance Audit**
- Profile with Flutter DevTools
- Fix any `shouldRepaint` returning `true` unconditionally
- Add `RepaintBoundary` around all `CustomPainter` widgets
- Check for missing `const` constructors

**9.4 — Sensor Cleanup Audit**
- Verify every `StreamSubscription` is cancelled in `close()`
- Use Flutter DevTools memory profiler to check for leaks
- Test: open every tool → background app → foreground → close tool → no active subscriptions

**9.5 — Tests**
- Unit tests for ConversionEngine (all categories, all edge cases)
- Unit tests for LowPassFilter
- Unit tests for angle math (pitch/roll)
- Unit tests for calibration offset computation
- Unit tests for Ad rate limiter
- Widget tests for MetalPanel, TactileButton, LedDisplay

**9.6 — APK Size Check**
```bash
flutter build apk --release --split-per-abi
# Check outputs/flutter-apk/
# arm64-v8a APK should be ≤ 30 MB
```
If over limit:
1. Check for unused assets
2. Remove any packages not in the approved list
3. Ensure `shrinkResources true` is set
4. Consider splitting audio assets if they're large

**9.7 — Release Config**
- `android/app/proguard-rules.pro` — add rules for all packages
- Signing config in `build.gradle` (do NOT commit keystore — document the process)
- `android:debuggable` → false in release manifest
- Remove all `debugPrint` and `kDebugMode` wrappers aren't missed

---

## PHASE GATE CRITERIA

Before moving between phases, ALL of the following must be true:

| Check | Requirement |
|-------|-------------|
| `flutter analyze` | Zero issues |
| `flutter test` | All tests pass |
| Localization | No hardcoded user-facing strings |
| RTL | Current phase screens tested in Arabic |
| Sensors | All subscriptions cancelled on dispose |
| Naming | No magic numbers in widget files |
| Build | `flutter build apk --debug` succeeds |

---

## FEATURE FLAGS (SharedPreferences keys)

Document every SharedPreferences key used in the app:

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `onboarding_complete` | bool | false | First-launch onboarding shown |
| `levo_prem_status` | bool | false | Pro purchase status |
| `last_interstitial_ts` | int | 0 | Last interstitial timestamp (ms) |
| `language_code` | String? | null | Forced locale (null = system) |
| `keep_screen_on` | bool | true | WakeLock setting |
| `cal_level_pitch` | double | 0.0 | Spirit level pitch offset |
| `cal_level_roll` | double | 0.0 | Spirit level roll offset |
| `level_viscosity` | double | 0.7 | Low-pass filter strength |
| `level_threshold` | double | 1.0 | Level-achieved threshold (°) |
| `level_mode` | int | 0 | SpiritLevelMode index |
| `level_sound` | bool | true | Beep on level |
| `level_haptic` | bool | true | Haptic on level |
| `ruler_scale_factor` | double | 1.0 | Ruler DPI calibration |
| `ruler_default_unit` | String | 'mm' | Default unit |
| `converter_default_cat` | String | 'length' | Default converter category |
| `true_north_enabled` | bool | false | Compass true north |
| `metal_first_launch_warned` | bool | false | Metal detector first-launch notice |
| `protractor_snap_enabled` | bool | true | Angle snapping |
