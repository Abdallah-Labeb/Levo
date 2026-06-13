# Features Specification — Levo v1.0.0

> This document is the authoritative feature spec. Every tool must behave exactly as described.
> All features are 100% local. No network calls are permitted from any tool.

---

## Tool 1: Spirit Level (Bubble Level)

### Modes
1. **2D Surface Level** — Circular bubble for flat surfaces (tables, countertops, floors)
2. **1D Edge Level** — Single horizontal tube for walls, frames, beams, pipes
3. **Plumb Bob** — Detects perfect vertical (device held against a wall or column)

### Data Source
`accelerometerEventStream()` from `sensors_plus`. Apply low-pass filter before computing angles.

```
pitch = atan2(-x, sqrt(y² + z²)) × (180 / π)
roll  = atan2( y, z)              × (180 / π)
```

Subtract stored calibration offsets before emitting state:
```
corrected_pitch = raw_pitch - cal_pitch_offset
corrected_roll  = raw_roll  - cal_roll_offset
```

### Display Values
- Angle in degrees (°) with **2 decimal places** — e.g., `1.24°`
- Toggle to inclination percentage (%) — formula: `tan(angle_rad) × 100`
- Level state color (update in real-time):
  - **Green** : `|angle| ≤ threshold` (default threshold: 1.0°)
  - **Yellow**: `threshold < |angle| ≤ threshold × 3`
  - **Red**   : `|angle| > threshold × 3`

### Controls & Interactions

| Control | Type | Behavior |
|---------|------|----------|
| Mode selector | 3-tab segmented control | 2D / 1D / Plumb — persisted in SharedPreferences |
| Lock Orientation | Toggle button | Locks device screen orientation for the tool screen |
| Angle Hold | Toggle button | Freezes the displayed reading; shows "HOLD" badge on display |
| Set Reference | Button | Stores current angle as the new zero reference (added to offset) |
| Calibrate | Button | Opens calibration wizard (see below) |
| Sound | Toggle | Beep (via `audioplayers`) when device is level |
| Haptic | Toggle | Short vibration pulse (via `vibration`) when device is level |
| °/% | Toggle | Switches display between degrees and percentage slope |

### Calibration Wizard (3-step)
1. **Step 1**: User places device on any flat surface → tap "Capture A"
2. **Step 2**: User rotates device 180° on same surface → tap "Capture B"
3. **Step 3**: App computes `offset = (A + B) / 2`, stores in SharedPreferences as `cal_level_pitch` and `cal_level_roll`

This two-position calibration eliminates surface tilt error.

### Adjustable Settings
- **Viscosity** (0–100%, default 70%): Controls low-pass filter alpha.
  - 0% → alpha = 1.0 (raw, no filtering)
  - 70% → alpha = 0.15 (default, smooth)
  - 100% → alpha = 0.03 (very slow, molasses-like)
- **Level Threshold** (0.1°–5.0°, default 1.0°): The angle below which surface is considered level.

### Edge Cases
- Accelerometer unavailable → show `SensorErrorView` with icon and message: "Accelerometer not available on this device"
- Gimbal lock in Plumb mode (phone pointed straight down) → detect and display "Rotate device" hint
- Angle Hold active + level achieved → still show "HOLD" badge, do not fire haptic/sound for held value

---

## Tool 2: Digital Ruler

### Description
Uses the device display as a physical ruler. Accuracy depends on actual screen DPI, which must be calibrated. The ruler spans the full screen height (portrait) or width (landscape).

### Data Source
`MediaQuery.of(context).devicePixelRatio` and `View.of(context).physicalSize`. Derive millimeters-per-logical-pixel from screen DPI:
```
physical_dpi     = devicePixelRatio × 160   // approximate base PPI
mm_per_px        = 25.4 / physical_dpi
calibrated_mm_px = mm_per_px × calibration_scale_factor
```

### Units
- Millimeters (mm) — default
- Centimeters (cm)
- Inches (in) with fractional display (e.g., `3 7/16"`)

### Calibration Flow (Preset-Based)

User selects a reference object of known physical size:

| Preset | Width/Height | Axis |
|--------|-------------|------|
| Credit Card (ISO 7810) | 85.60 mm | Width |
| A4 Paper Width | 210.00 mm | Width |
| A4 Paper Height | 297.00 mm | Height |
| ID Card | 53.98 mm | Width |
| Custom | User-entered mm value | User-chosen |

User places object alongside on-screen guide line → adjusts slider until markings match object edge → confirms. Scale factor saved as `ruler_scale_factor` in SharedPreferences.

### Display & Interaction
- Ruler rendered as full-height custom painted widget with tick marks
- Tick mark hierarchy: **major** (10mm / 1cm / 1in), **minor** (5mm / 0.5cm / 0.5in), **sub-minor** (1mm / 1mm / 1/8in)
- Numbers stamped at each major tick (Bebas Neue font)
- Drag to scroll ruler (pan gesture, momentum-based)
- **Two-point mode**: Tap anywhere to place Marker A → tap again to place Marker B → floating label shows distance between them in selected unit
- Units selector: 3-position toggle at top (mm / cm / in)

### Edge Cases
- Uncalibrated state → show warning banner "Ruler not calibrated — readings may be inaccurate" until user completes calibration
- Very small screen (< 4 inch): reduce sub-minor tick density

---

## Tool 3: Compass

### Description
Tilt-compensated magnetic compass. Uses magnetometer corrected by accelerometer for accuracy when phone is tilted. Optional true-north correction via last-known GPS location.

### Data Source
- Primary: `FlutterCompass.events` from `flutter_compass` (wraps sensor fusion internally)
- GPS (optional, on user toggle): `Geolocator.getLastKnownPosition()` → compute magnetic declination

### Display
- Heading in degrees: 0° = North, 90° = East, 180° = South, 270° = West
- Cardinal direction label: N / NNE / NE / ENE / E / ESE / SE / SSE / S / SSW / SW / WSW / W / WNW / NW / NNW
- Current heading readout in LED_Display: e.g., `247°`
- Cardinal label below readout: e.g., `WSW`

### Accuracy Indicator
`flutter_compass` emits accuracy values. Map to user-facing label:
- `accuracy == null` or `< 15°`: "Low accuracy — calibrate sensor"
- `15° – 45°`: "Medium accuracy"  
- `< 15°`: "High accuracy"

Show calibration hint when accuracy is LOW: "Wave your phone in a figure-8 pattern".

### Settings
- True North toggle: If enabled, request `ACCESS_FINE_LOCATION` permission → compute declination → add to heading
- Declination display: Show computed value (e.g., `+3.2° E declination`) when True North is active

### Interaction
- Compass rose rotates smoothly as device rotates — rotate the background, keep N label visually fixed
- Tap anywhere on compass to lock/freeze heading (show "LOCKED" badge)
- Apply low-pass filter (alpha 0.2) to heading values to prevent jitter

### Edge Cases
- Magnetic interference (heading jumps > 30° in < 100ms): Show "Magnetic interference detected" banner for 3 seconds
- Location permission denied: Fall back to magnetic north silently, do not re-prompt
- Device has no magnetometer: Show `SensorErrorView`

---

## Tool 4: Protractor

### Description
Measure the angle between two lines by drawing them on a canvas with touch gestures.

### Interaction Flow
1. Canvas appears with a center pivot point (fixed, centered on screen)
2. **Handle A** (yellow circle): Drag from center to set first line — initially at 0° (pointing right)
3. **Handle B** (orange circle): Drag from center to set second line — initially at 90° (pointing up)
4. Angle between lines is computed and displayed in real-time as user drags
5. Arc drawn between the two lines shows which angle is being measured

### Computed Values
- Angle in degrees (°) — displayed in center of arc
- Option to display as complement (360° − angle) — reflex angle toggle
- Percentage rise/run displayed below main angle (for ramp/slope use): `tan(angle_rad) × 100`%

### Angle Snapping
When snap is enabled (toggle button), handles snap to common angles within 2° tolerance:
`0°, 15°, 30°, 45°, 60°, 75°, 90°, 105°, 120°, 135°, 150°, 165°, 180°`

### Controls
| Control | Behavior |
|---------|----------|
| Reset | Returns A to 0°, B to 90° |
| Snap toggle | Enables/disables angle snapping |
| Reflex toggle | Measures 360° − current angle instead |
| Copy value | Copies angle text to clipboard |

### Visual
- Canvas background: light off-white (`#F0EDE8`) to simulate paper/drafting surface — this is one of few places where a lighter background is used
- Lines: dark charcoal, 2px stroke, extend from center to handle
- Arc: orange (`#FF6B35`), filled sector with 30% opacity
- Angle label: large, centered in arc sector, Bebas Neue
- Handle A: yellow filled circle, 24px radius, with "A" label
- Handle B: orange filled circle, 24px radius, with "B" label
- Center pivot: small chrome circle, 8px radius

---

## Tool 5: Sound Level Meter (dB Meter)

### Description
Real-time sound pressure level (SPL) measurement using device microphone. Output in decibels (dB SPL).

### Permission
`android.permission.RECORD_AUDIO` — use `permission_handler`. Show permission rationale screen before requesting if permission was previously denied.

### Data Source
`NoiseMeter` from `noise_meter` package. Listen to `NoiseMeter().noise` stream which emits `NoiseReading` with `meanDecibel` and `maxDecibel` values.

### Computed & Displayed Values
| Value | Description |
|-------|-------------|
| Current dB | Instantaneous `meanDecibel` from current frame |
| Peak dB | Maximum recorded since session start (reset button available) |
| Average dB | Rolling 5-second moving average |
| Min dB | Minimum recorded since session start |

### dB Reference Zones (for dial color coding and labels)

| dB Range | Label | Zone Color |
|----------|-------|-----------|
| 0 – 30 | Silence | `#4EBA74` (green) |
| 30 – 50 | Whisper / Library | `#7EC85A` (light green) |
| 50 – 65 | Conversation | `#FFCC00` (yellow) |
| 65 – 80 | Traffic / Restaurant | `#FF8C00` (amber) |
| 80 – 90 | Loud music / Shouting | `#FF5500` (orange) |
| 90 – 110 | Power tools / Concert | `#E84545` (red) |
| > 110 | Dangerous / Jet | `#8B0000` (deep red) |

### Display Layout
- Top 60%: `AnalogDialWidget` with needle pointing to current dB, colored arc zones
- Left and right of dial: decorative stereo VU bar meters (based on same mono signal, decorative only)
- Bottom: `LedDisplay` showing current dB value (e.g., `67.3 dB`)
- Small panel below LED: Peak, Avg, Min values in smaller text
- Decorative: microphone grille illustration at very bottom of screen

### Edge Cases
- Permission permanently denied → show rationale + "Open Settings" button
- No microphone → show `SensorErrorView`
- Very loud sound > 110 dB → screen flashes deep red for 500ms + strong haptic

---

## Tool 6: Vibration Meter

### Description
Displays real-time device vibration / acceleration as a scrolling seismograph waveform.

### Data Source
`accelerometerEventStream(samplingPeriod: SensorInterval.ui)` from `sensors_plus`.

Compute net vibration magnitude (remove gravity):
```
raw_magnitude = sqrt(x² + y² + z²)
net_vibration = |raw_magnitude - 9.81|
```

On session start, record 1-second baseline and subtract it from all subsequent readings to correct for static tilt.

### Display
- **Waveform**: Scrolling right-to-left waveform (last 10 seconds of data, sampled at ~30Hz for display)
  - Background: `#0A0A0A` with subtle grid lines (`#1A1A1A`)
  - Waveform line: `#00FF41` (green), 1.5px stroke
  - Y-axis: auto-scaled to ±3× current peak value
  - Y-axis labels: m/s² values, engraved style
- **Current value**: `LedDisplay` widget in top-right corner (m/s²)
- **Peak value**: displayed in corner, with timestamp since session start

### Controls
- Reset button: clears history, resets peak, re-samples baseline

### Seismograph Implementation
Keep a `Queue<double>` of the last N values where `N = displayWidthPx / 3` (one point per 3 pixels). On each sensor event, push new value and pop oldest. Trigger `CustomPainter.repaint()` via a `ChangeNotifier`.

---

## Tool 7: Light Meter

### Description
Measures ambient illuminance in lux. Secondarily computes Exposure Value (EV) for photography use.

### Data Source (Priority order)
1. `Light` from `light` package — hardware ambient light sensor (if available and returns `> 0` lux)
2. Camera-based fallback — compute average luminance of camera preview frame via `camera` package, then estimate lux

### Computed Values
- **Lux** (lx): raw illuminance value
- **EV at ISO 100**: `EV = log2(lux / 2.5)` (approximate)
- **Scene label**: Derived from lux range (see table below)

| Lux Range | Scene Label |
|-----------|-------------|
| < 1 | Very Dark Night |
| 1 – 10 | Candlelight |
| 10 – 100 | Dark Indoors |
| 100 – 500 | Normal Indoors |
| 500 – 2000 | Bright Indoors |
| 2000 – 10000 | Overcast Daylight |
| 10000 – 50000 | Full Daylight |
| > 50000 | Direct Sunlight |

### Display
- `AnalogDialWidget` styled as vintage exposure meter (dark circular face, engraved scale)
- `LedDisplay` for lux value
- Scene label text below LED
- EV value in smaller secondary display
- Top section: simple camera viewfinder rectangle frame (decorative, indicates camera is in use for fallback mode)

### Permissions
`android.permission.CAMERA` — request only if ambient light sensor is unavailable.

---

## Tool 8: Metal Detector

### Description
Detects nearby ferrous/magnetic objects by monitoring total magnetic field strength. Uses the magnetometer, NOT audio-based or radar.

### Data Source
`MagnetometerEvent` from `sensors_plus`.

```
total_field_uT = sqrt(x² + y² + z²)   // in microtesla (µT)
```

On open: record 1.5s baseline average. Continuously compute:
```
delta_uT = |current_field - baseline_field|
```

### Detection Thresholds

| delta_uT | Detection Level | Color | Audio Beep Interval |
|---------|----------------|-------|---------------------|
| < 15 | None | `#111111` | Silent |
| 15 – 40 | Weak | `#1A3A1A` → `#4EBA74` | 1200ms |
| 40 – 80 | Medium | `#4EBA74` | 600ms |
| 80 – 150 | Strong | `#FFCC00` | 200ms |
| > 150 | Very Strong | `#E84545` | Continuous tone |

### Display
- Large circular proximity indicator, fills screen
- Color shifts from dark background through green → yellow → red as field increases
- Concentric animated rings pulse outward (frequency = beep frequency)
- `LedDisplay`: current delta_uT value
- Audio: repeating beep tone (use `audioplayers`) at frequency from table above
- Haptic: short vibration at same interval as beep

### Controls
- Re-calibrate button: re-samples baseline (useful when user moves to a different location)
- Sensitivity slider: adjusts threshold multipliers (default = 1.0×, range 0.5×–3.0×)

### Important Notes for Implementation
- Warn user: "Results may be affected by nearby electronics, speaker magnets, or metal tables" — show as dismissible info card on first launch of this tool only.
- High sensitivity varies greatly by device — this is expected and acceptable.

---

## Tool 9: Unit Converter

### Description
Offline unit converter for all construction and engineering-relevant measurement categories. Pure math, zero network calls, all conversion factors hardcoded as `const double`.

### Categories and Units

**Length**: mm, cm, m, km, in, ft, yd, mile

**Area**: mm², cm², m², km², in², ft², yd², acre, hectare

**Volume**: mm³, cm³, m³, mL, L, in³, ft³, US gallon, UK gallon

**Mass**: mg, g, kg, tonne (metric), oz, lb, US short ton

**Temperature**: °C, °F, K  
  *(Note: temperature uses formula conversion, not a simple factor)*

**Pressure**: Pa, kPa, MPa, bar, psi (lbf/in²), atm

**Speed**: m/s, km/h, mph, ft/s, knot

**Angle**: degree (°), radian (rad), gradian (grad), arcminute, arcsecond

### Interaction Flow
1. User selects a category from horizontal scrollable tab strip at top
2. Two panels appear: **From** (top) and **To** (bottom)
3. Each panel has: unit selector (scrollable drum picker widget) + numeric value
4. User types in either field → other field updates in real-time
5. Swap button (↑↓) in center reverses From/To instantly
6. Copy button on each field copies value to clipboard

### Implementation Note
Store all conversion factors relative to an SI base unit. For Length, base = meters. All conversions: `value_meters = input × from_to_meter_factor`, then `output = value_meters / to_to_meter_factor`. Temperature uses direct formulas.

---

## Tool 10: Clinometer (Slope / Grade Meter)

### Description
Measures the slope angle of a surface for use with roads, ramps, drainage pipes, rooflines, and wheelchair ramps. Reports in both degrees and percentage grade.

### Data Source
Same as Spirit Level: `accelerometerEventStream()` from `sensors_plus`, pitch axis only (single-axis: device held on its edge against the surface, like a long level).

```
pitch_degrees = atan2(-x, sqrt(y² + z²)) × (180 / π)
grade_percent = tan(pitch_radians) × 100
```

### Display Layout
- Top 50%: Animated side-view slope diagram:
  - Horizontal ground line
  - Tilted surface line at current angle (animates smoothly)
  - Device rectangle sitting on the tilted surface
  - Arrow pointing to higher end of surface
  - Angle arc labeled with current degrees
- Bottom 50%: `MetalPanel` containing:
  - `LedDisplay`: angle in degrees (e.g., `4.7°`)
  - `LedDisplay`: grade percentage (e.g., `8.2%`)
  - Direction label: "Left side higher" / "Right side higher" / "Level"
  - Grade classification label (see table below)

### Grade Reference Table (shown as reference in tool UI)

| % Grade | Classification |
|---------|---------------|
| 0% | Flat / Level |
| 1 – 2% | Minimum drainage slope |
| 4 – 5% | Gentle pedestrian ramp |
| 8.33% | ADA/DDA maximum ramp grade |
| 10 – 12% | Steep ramp |
| 15 – 20% | Very steep road |
| 45% | 24.2° |
| 100% | 45° (1:1) |

### Controls
- Angle Hold: freeze current reading
- °/% toggle: switch primary display unit
- Uses same Viscosity setting as Spirit Level (shared SharedPreferences key)

---

## Home Screen

### Layout
`GridView` with 2 columns (phones) / 3 columns (tablets ≥600dp). Cells are `ToolCard` widgets with 12px gap between cards, 16px horizontal outer padding, 24px top padding.

### ToolCard Content
- Skeuomorphic SVG icon (56×56px)
- Tool name (Bebas Neue, 18sp)
- One-line description (Inter, 12sp, `kColorTextSecondary`)
- Sensor status dot: green = sensor available, red = unavailable, grey = permission not granted

### Background
`#111111` with a subtle full-screen grain texture (5% opacity `ShaderMask` with noise texture — or a cached `ui.Image` generated once at startup via `dart:ui` pixel manipulation).

### Long Press on ToolCard
Show `Tooltip` or bottom sheet with:
- Tool description (2 sentences)
- Required sensors/permissions
- Quick-access calibrate button (if applicable)

---

## Settings Screen

### Sections

**Appearance**
- Theme: Dark / Light / System *(Dark only active in v1 — Light and System are visible but show "Coming soon" tag)*
- Language: English / العربية / System

**Measurement Defaults**
- Default unit for Ruler: mm / cm / in
- Default category for Unit Converter: Length / Area / Volume / Mass / Temperature / Pressure / Speed / Angle

**Sensor & Calibration**
- Spirit Level Calibration: shows current offsets, button to recalibrate or reset
- Ruler Calibration: shows current scale factor, button to recalibrate or reset
- Reset All Calibration: confirmation dialog before executing

**Display**
- Keep Screen On (WakeLock): toggle — enabled by default

**Pro / Ads**
- Status: "Free — Ads enabled" or "Pro — No ads"
- "Remove Ads — $2.99" button (if not Pro)

**About**
- App version
- Open source licenses (use `showLicensePage`)
- Privacy policy link (opens in browser)
- Rate the app link (Google Play)

---

## Permission Strategy

Request permissions only when the user opens the relevant tool for the first time. Never request upfront.

| Permission | Android Name | Tool | Rationale shown |
|-----------|-------------|------|----------------|
| Microphone | `RECORD_AUDIO` | Sound Level Meter | "Needed to measure sound levels" |
| Location | `ACCESS_FINE_LOCATION` | Compass (True North only) | "Used once to compute magnetic declination" |
| Camera | `CAMERA` | Light Meter (fallback) | "Used to estimate ambient light when sensor unavailable" |

Use `permission_handler`. If permanently denied, show a screen with an "Open App Settings" button that calls `openAppSettings()`.

---

## Shared Behaviors

### WakeLock
All tool screens (not Settings or Home) acquire `WakelockPlus.enable()` on `initState` and release on `dispose()`. Overridden by user's Keep Screen On setting.

### Back Navigation
All tool screens use the system back button / back gesture to return to Home. No in-tool navigation between tools (user must go back to Home first).

### First Launch
On very first app launch, show a 3-page onboarding:
1. "10 professional tools — one app" — hero image of tool grid
2. "Industrial feel — real precision" — animated bubble level preview
3. "Calibrate for accuracy" — brief mention of calibration for Level and Ruler

After onboarding, mark `onboarding_complete = true` in SharedPreferences and never show again.

### Measurement History (v1: minimal)
v1 does NOT include a full history log. The only persistence is:
- Last calibration values
- User settings/preferences

Full measurement history with Hive is documented as a v2 feature.
