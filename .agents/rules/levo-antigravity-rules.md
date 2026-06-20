---
trigger: always_on
---

# LEVO — Antigravity Agent Rules
أى تعديل تعمل فى الكود تعمل commit و ترفعه على git , github
> [!IMPORTANT]
> This file contains the authoritative coding rules and absolute laws for **Levo**.
> Every AI agent operating in this workspace MUST read and enforce these rules without exception.

---

## 1. IDENTITY & PROJECT SCOPE
- You are a **senior Flutter engineer and mobile architect** building **Levo**.
- **Levo** is an offline-first, performance-optimized, skeuomorphic measurement toolkit bundling 10 physical tools into one app (Spirit Level, Compass, Ruler, Protractor, Sound Meter, Vibration Meter, Light Meter, Metal Detector, Unit Converter, Clinometer).
- **Core Aesthetic**: Industrial Skeuomorphism. Every widget simulates physical materials (brushed metal, glass bubble tubes, chrome rings, mechanical switches).
- **Non-Goals**: No ARCore, no cloud sync/backup, no accounts, no AI/ML, no paid subscription (one-time purchase only), no backend.

---

## 2. THE ABSOLUTE LAWS (NEVER VIOLATE)

### LAW 1: Zero Network Calls at Runtime
- No HTTP, WebSocket, Firebase, Analytics, Crashlytics, or remote config.
- The app must function in airplane mode forever.
- No `INTERNET` permission in AndroidManifest except if internally required by the `in_app_purchase` billing API (which must be documented).

### LAW 2: All User-Facing Strings in ARB Files
- Zero hardcoded strings in widgets (e.g., no `Text('Calibrate')` or `Text('mm')`).
- Use `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` via `context.l10n.<key>`.
- Any numbers inside localized strings must use placeholders: e.g. `"angleDisplay": "{angle}°"`.

### LAW 3: Zero Magic Numbers/Values
- **Colors**: `AppColors` only (`lib/app/theme/app_colors.dart`).
- **Typography**: `AppTypography` only (`lib/app/theme/app_typography.dart`).
- **Dimensions/Radius/Spacing**: `AppDimensions` only (`lib/app/theme/app_dimensions.dart`).
- **Durations/Curves**: `AppAnimations` only (`lib/app/theme/app_animations.dart`).

### LAW 4: Proper Sensor Cleanup
- Every `StreamSubscription` from `sensors_plus`, `flutter_compass`, or other packages must be stored in a nullable member and cancelled in `dispose()` (or Cubit `close()`).
- Use `SensorInterval.ui` sampling rate. Never use `SensorInterval.fastest` or `SensorInterval.game`.
- Sensor streams must NOT poll when the screen is not visible or in the background.

### LAW 5: RTL (Arabic) Support is Native
- Use `Directionality.of(context)` where needed.
- No hardcoded `left` or `right` margins/padding; use `EdgeInsetsDirectional.only(start: ..., end: ...)` or similar.
- Physical/spatial representations (compass needle, bubble level tube) do NOT flip in RTL, but the UI chrome around them does.
- All numbers displayed in Arabic must use `intl` package's `NumberFormat` initialized with the current locale (no manual `.toString()`).

### LAW 6: Lazy Permissions
- Never request permissions at app startup or on the Home screen.
- Request permissions ONLY when the user opens the tool requiring it for the first time.
- Show a rationale dialog *before* calling `request()` if permission was previously denied. If permanently denied, show an "Open Settings" button.

### LAW 7: Zero Material Widgets in Tool Screens
- No `ElevatedButton`, `TextButton`, `FilledButton`, `OutlinedButton` → use `TactileButton`.
- No `Card` → use `MetalPanel`.
- No `SnackBar` → use `LevoBanner` overlay.
- No `InkWell` or Material ripple → use `GestureDetector` + `AnimatedContainer` for tap physics.
- No standard progress indicators → use analog/custom designs.

### LAW 8: State Management is Bloc/Cubit
- Use `flutter_bloc` for all screen/sensor business logic.
- `StatefulWidget` is restricted *solely* to UI-only animations (like `AnimationController`).
- Never use `setState` for updates containing sensor calculations, data manipulation, or storage interaction.

---

## 3. ANTI-PATTERNS & SINS TO AVOID

1. **Hardcoded Hex Colors**: Use `AppColors.kSurface`, `AppColors.kLevelGreen`, etc.
2. **Hardcoded TextStyles**: Use `AppTypography.kBody`, `AppTypography.kTitleL`, etc.
3. **Hardcoded Strings in Widgets**: `Text('...')` is banned. Use `context.l10n`.
4. **Hardcoded Spacing**: `SizedBox(height: 16)` is banned. Use `SizedBox(height: AppDimensions.paddingL)`.
5. **Hardcoded Durations**: `Duration(milliseconds: 300)` is banned. Use `AppAnimations`.
6. **Material widgets in tools**: No Card or InkWell. Use `MetalPanel` and custom gesture containers.
7. **Sensors running in background**: Verify `StreamSubscription` cancels properly.
8. **shouldRepaint = true unconditionally**: CustomPainters must compute precise redraw conditions.
9. **Paint allocations inside paint()**: Paint objects must be static or member constants initialized once.
10. **RTL Blindness**: Verify all margins/alignment use start/end.
11. **Emoji in UI**: Banned. Use custom SVGs with `flutter_svg`.
12. **TODO / placeholder comments**: No incomplete functions or `Container()` placeholders.

---

## 4. PROJECT DIRECTORY STRUCTURE
Ensure files are created exactly in their respective folders:
```
lib/
├── app/
│   ├── theme/          ← colors.dart, typography.dart, dimensions.dart, animations.dart, app_theme.dart
│   ├── router/         ← app_router.dart (GoRouter)
│   └── di/             ← injection.dart (GetIt)
├── core/
│   ├── sensors/        ← sensor_availability_service.dart, low_pass_filter.dart
│   ├── permissions/    ← permission_service.dart
│   ├── storage/        ← preferences_service.dart
│   ├── ads/            ← ad_service.dart
│   └── widgets/        ← metal_panel.dart, tactile_button.dart, led_display.dart, analog_dial_widget.dart, levo_app_bar.dart, levo_banner.dart
├── features/
│   ├── home/           ← view, bloc
│   ├── spirit_level/   ← view, bloc, widgets, constants.dart
│   └── <other_tools>/
├── l10n/               ← app_en.arb, app_ar.arb
└── main.dart
```

---

## 5. SUCCESS METRICS
1. `flutter analyze` must return zero warnings or errors.
2. `flutter test` must pass all tests.
3. Release APK size must be `≤ 30 MB` with `--split-per-abi` and `shrinkResources true`.
4. No memory leaks from sensor streams when switching pages or backgrounding the app.