# Design System — Levo Industrial Skeuomorphic UI

> **Golden rule for every UI decision**: Would this element look at home on a machinist's workbench?
> If the answer is no, redesign it.

---

## Philosophy

Levo's UI is not "dark mode" — it is a material simulation. Every surface has a physical analogue:

- **Dark panels** → anodized aluminum or powder-coated steel housings
- **Gradient borders** → machined edges catching light at different angles
- **Inset displays** → recessed LCD windows behind tinted glass
- **Bubble level area** → glass tube filled with green-tinted spirit fluid
- **Compass face** → brushed metal plate behind a glass dome
- **Ruler** → engraved aluminum or hardwood with etched markings
- **Buttons** → raised rubber or metal tactile switches

No drop shadows for "elevation". No Material ripples. No floating action buttons. Every element earns its place.

---

## Color Tokens

All colors defined as `const Color` values in `lib/app/theme/colors.dart`.

### Background & Surface Hierarchy

```dart
// Application background — near-black, like anodized aluminum
static const kBackground = Color(0xFF111111);

// Primary surface — slightly raised panel
static const kSurface = Color(0xFF1C1C1C);

// Elevated surface — more prominent raised element
static const kSurfaceElevated = Color(0xFF242424);

// Inset/recessed area (e.g., display cavity)
static const kSurfaceInset = Color(0xFF0A0A0A);

// Subtle divider / groove line
static const kDivider = Color(0xFF2A2A2A);
```

### Metal & Chrome Tones

```dart
// Chrome / brushed aluminum scale
static const kChromeLight     = Color(0xFFCCCCCC);
static const kChromeMid       = Color(0xFF888888);
static const kChromeDark      = Color(0xFF444444);
static const kChromeDarker    = Color(0xFF2A2A2A);

// Panel border highlights (light edge = top/left, dark edge = bottom/right)
static const kBorderHighlight = Color(0xFF3A3A3A);  // top and left edges
static const kBorderShadow    = Color(0xFF141414);  // bottom and right edges
```

### Brand Accent Colors

```dart
// Construction yellow — spirit level casing, primary accent
static const kYellow          = Color(0xFFF5C22B);
static const kYellowDark      = Color(0xFFCC9F1C);
static const kYellowDarker    = Color(0xFF8A6A12);

// Safety orange — secondary accent, protractor handles, warnings
static const kOrange          = Color(0xFFFF6B35);
static const kOrangeDark      = Color(0xFFCC4E1E);
```

### Semantic / Status Colors

```dart
// Level achieved — green
static const kLevelGreen      = Color(0xFF4EBA74);
static const kLevelGreenDim   = Color(0xFF1A3A28);
static const kLevelGreenGlow  = Color(0x334EBA74);  // for glow BoxShadow

// Close to level — warm yellow
static const kWarningYellow   = Color(0xFFFFCC00);
static const kWarningYellowDim = Color(0xFF3A3000);

// Off level / danger — red
static const kDangerRed       = Color(0xFFE84545);
static const kDangerRedDim    = Color(0xFF3A1010);
static const kDangerRedGlow   = Color(0x33E84545);

// Compass north needle
static const kCompassNorth    = Color(0xFFE84545);

// Compass body / water tones
static const kCompassBlue     = Color(0xFF3B9EEB);
static const kCompassBlueDim  = Color(0xFF0A1A2A);
```

### Digital Display Colors

```dart
// Green LED display (default for all numeric readouts)
static const kDisplayGreen    = Color(0xFF00FF41);
static const kDisplayGreenDim = Color(0xFF003310);   // unlit segments
static const kDisplayGreenGlow = Color(0x4400FF41);  // outer glow

// Amber LED display (alternative — user can toggle in Settings v2)
static const kDisplayAmber    = Color(0xFFFF8C00);
static const kDisplayAmberDim = Color(0xFF2A1500);

// Display cavity background
static const kDisplayBg       = Color(0xFF050505);
```

### Text Colors

```dart
static const kTextPrimary     = Color(0xFFEEEEEE);
static const kTextSecondary   = Color(0xFF888888);
static const kTextTertiary    = Color(0xFF555555);
static const kTextOnYellow    = Color(0xFF1A1A1A);   // text on yellow buttons
static const kTextOnGreen     = Color(0xFF0A2010);   // text on level-green
```

---

## Typography

Three font families. No system fonts in primary UI. All fonts shipped as TTF assets.

### Font Stack

| Family | File | Usage |
|--------|------|-------|
| `BebasNeue` | `BebasNeue-Regular.ttf` | Tool names, section headers, unit labels, app bar title |
| `ShareTechMono` | `ShareTechMono-Regular.ttf` | All numeric readings, digital displays, coordinates |
| `Inter` | `Inter-Regular/Medium/SemiBold.ttf` | Body text, settings, descriptions, captions |

### Text Style Constants (`lib/app/theme/typography.dart`)

```dart
// ── Digital Displays ──────────────────────────────────────────────────────

// Primary measurement reading (e.g., "47.23°")
static const kDisplayXL = TextStyle(
  fontFamily: 'ShareTechMono', fontSize: 56,
  color: kDisplayGreen, letterSpacing: 3,
);

// Standard measurement (e.g., "1247 lux")
static const kDisplayL = TextStyle(
  fontFamily: 'ShareTechMono', fontSize: 40,
  color: kDisplayGreen, letterSpacing: 2,
);

// Secondary measurement (e.g., peak dB, average)
static const kDisplayM = TextStyle(
  fontFamily: 'ShareTechMono', fontSize: 28,
  color: kDisplayGreen, letterSpacing: 1.5,
);

// Small reading (e.g., min/max labels)
static const kDisplayS = TextStyle(
  fontFamily: 'ShareTechMono', fontSize: 18,
  color: kDisplayGreenDim.withOpacity(0.9), letterSpacing: 1,
);


// ── Bebas Neue Labels ─────────────────────────────────────────────────────

// App bar / tool screen title
static const kTitleXL = TextStyle(
  fontFamily: 'BebasNeue', fontSize: 26,
  color: kTextPrimary, letterSpacing: 4,
);

// Tool name on home grid card
static const kTitleL = TextStyle(
  fontFamily: 'BebasNeue', fontSize: 18,
  color: kTextPrimary, letterSpacing: 2.5,
);

// Section header in settings
static const kSectionHeader = TextStyle(
  fontFamily: 'BebasNeue', fontSize: 13,
  color: kTextSecondary, letterSpacing: 3,
);

// Unit labels (mm, dB, °C)
static const kUnitLabel = TextStyle(
  fontFamily: 'BebasNeue', fontSize: 22,
  color: kTextSecondary, letterSpacing: 1.5,
);


// ── Inter Body Text ───────────────────────────────────────────────────────

static const kBody = TextStyle(
  fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400,
  color: kTextPrimary,
);

static const kBodySmall = TextStyle(
  fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400,
  color: kTextSecondary,
);

static const kCaption = TextStyle(
  fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w400,
  color: kTextSecondary, letterSpacing: 1.2,
);

static const kButton = TextStyle(
  fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600,
  color: kTextPrimary, letterSpacing: 0.5,
);
```

---

## Shadow System (`lib/app/theme/shadows.dart`)

No Material elevation. Shadows simulate real-world 3D physical depth.

### Two-Component Model
Every raised element has:
1. **Top highlight** — simulates ambient light hitting the top edge
2. **Bottom shadow** — simulates depth below the element

```dart
// Raised panel (thick machined plate)
static const kShadowPanel = [
  BoxShadow(color: Color(0x20FFFFFF), offset: Offset(0, -1), blurRadius: 2),
  BoxShadow(color: Color(0xBB000000), offset: Offset(0, 6),  blurRadius: 14, spreadRadius: -2),
];

// Tactile button — normal (raised)
static const kShadowButtonNormal = [
  BoxShadow(color: Color(0x18FFFFFF), offset: Offset(0, -1), blurRadius: 1),
  BoxShadow(color: Color(0xCC000000), offset: Offset(0, 4),  blurRadius: 8),
];

// Tactile button — pressed (recessed)
static const kShadowButtonPressed = [
  BoxShadow(color: Color(0x99000000), offset: Offset(0, 1),  blurRadius: 3),
];

// LED display bezel (inset / recessed into panel)
static const kShadowInset = [
  BoxShadow(color: Color(0xAA000000), offset: Offset(2, 2),  blurRadius: 6),
  BoxShadow(color: Color(0x12FFFFFF), offset: Offset(-1, -1), blurRadius: 2),
];

// Level-achieved glow (animated on/off)
static List<BoxShadow> kShadowGlowGreen = [
  const BoxShadow(color: kLevelGreenGlow, blurRadius: 24, spreadRadius: 3),
];

// Danger glow
static List<BoxShadow> kShadowGlowRed = [
  const BoxShadow(color: kDangerRedGlow, blurRadius: 24, spreadRadius: 3),
];
```

---

## Gradient Library (`lib/app/theme/colors.dart`)

```dart
// Brushed aluminum — use as panel background gradient
static const kGradientBrushedAluminum = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFF282828), Color(0xFF1A1A1A)],
);

// Brushed metal horizontal (e.g., ruler surface)
static const kGradientBrushedHorizontal = LinearGradient(
  colors: [Color(0xFF3A3A3A), Color(0xFF6E6E6E), Color(0xFF3A3A3A)],
  stops: [0.0, 0.5, 1.0],
);

// Construction yellow casing (e.g., spirit level body)
static const kGradientYellowCasing = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [Color(0xFFF5C22B), Color(0xFFC0910F)],
);

// Chrome / metallic ring (use in CustomPainter via sweep gradient)
// For compass bezel, dial rings, etc.
static const kGradientChromeSweep = SweepGradient(
  colors: [
    Color(0xFF2A2A2A), Color(0xFF6A6A6A), Color(0xFFCCCCCC),
    Color(0xFF6A6A6A), Color(0xFF2A2A2A),
  ],
  stops: [0.0, 0.2, 0.5, 0.8, 1.0],
);

// Tactile button face — normal
static const kGradientButtonNormal = LinearGradient(
  begin: Alignment.topCenter, end: Alignment.bottomCenter,
  colors: [Color(0xFF303030), Color(0xFF252525)],
);

// Tactile button face — pressed (reversed)
static const kGradientButtonPressed = LinearGradient(
  begin: Alignment.topCenter, end: Alignment.bottomCenter,
  colors: [Color(0xFF222222), Color(0xFF2D2D2D)],
);

// Active (yellow) button
static const kGradientButtonActive = LinearGradient(
  begin: Alignment.topCenter, end: Alignment.bottomCenter,
  colors: [Color(0xFFF5C22B), Color(0xFFC0910F)],
);
```

---

## Core Widget Specifications

Implement each widget exactly as described. These are reusable across all tool screens.

---

### `MetalPanel` Widget

A container that looks like a piece of machined metal panel. The fundamental building block for all tool UI sections.

```
BoxDecoration:
  gradient: kGradientBrushedAluminum
  border: Border(
    top:    BorderSide(color: kBorderHighlight, width: 1),
    left:   BorderSide(color: kBorderHighlight, width: 1),
    bottom: BorderSide(color: kBorderShadow,    width: 1),
    right:  BorderSide(color: kBorderShadow,    width: 1),
  )
  borderRadius: BorderRadius.circular(12)
  boxShadow: kShadowPanel

Padding: EdgeInsets.all(16) by default, configurable
```

---

### `TactileButton` Widget

A button that looks physically pressable. Use `GestureDetector` + `AnimatedContainer`.

```
States:
  Normal:
    gradient: kGradientButtonNormal
    border: top/left = kBorderHighlight(1px), bottom/right = kBorderShadow(1px)
    boxShadow: kShadowButtonNormal
    borderRadius: BorderRadius.circular(8)
    padding: horizontal 16, vertical 12

  Pressed (onTapDown → set state):
    gradient: kGradientButtonPressed
    boxShadow: kShadowButtonPressed
    Transform.scale: 0.97

  Active/Toggle-On:
    gradient: kGradientButtonActive
    text/icon color: kTextOnYellow

Animation: 80ms duration, Curves.easeOut for press, 150ms release

Content:
  Row with optional leading icon + text (kButton style)
  Icon: custom SVG or simple Icon widget, 16px, color matches text
```

---

### `LedDisplay` Widget

Digital readout resembling a green LED/LCD display.

```
Outer container (the bezel cavity):
  color: kDisplayBg
  border: Border.all(color: Color(0xFF003310), width: 1)
  boxShadow: kShadowInset
  borderRadius: BorderRadius.circular(6)
  padding: horizontal 12, vertical 8

Value text:
  style: kDisplayL (or other size as needed)
  color: kDisplayGreen

Optional glow when displaying active reading:
  Add to outer container boxShadow:
    BoxShadow(color: kDisplayGreenGlow, blurRadius: 10)

Optional unit label to the right of value:
  style: kUnitLabel
  color: kDisplayGreenDim

Dim/inactive state (when Hold is active or sensor offline):
  value color: kDisplayGreenDim
```

---

### `BubbleLevelWidget` — CustomPainter (2D Mode)

The centerpiece of the Spirit Level. Paint in layers:

```
Layer 1 — Fluid container (filled circle):
  Color: Color(0xFF0A1A0F)  — dark green-tinted "fluid"
  Stroke: 3px, Color(0xFF1A3A20)
  Clip all subsequent painting to this circle

Layer 2 — Crosshair grid lines:
  Two perpendicular lines through center
  Color: Color(0xFF18281A), strokeWidth 1
  Optional dashed pattern: PathEffect-like with canvas.drawLine segments

Layer 3 — Concentric target rings:
  5 rings, each 15% of radius apart
  Color: Color(0xFF1C2E1E), strokeWidth 0.5
  Innermost ring: fill with kLevelGreen at 15% opacity (the "level zone")

Layer 4 — The bubble:
  Position: offset from center = (roll × scaleFactor, pitch × scaleFactor)
  scaleFactor: (containerRadius × 0.7) / maxDisplayAngle (e.g., 30°)
  Clamp position so bubble never exits container boundary

  Bubble rendering:
    Outer circle: radius = containerRadius × 0.15
    Fill: RadialGradient(
      colors: [Color(0xCCD4EFFF), Color(0x88A0C8E0)],
      center: Alignment(-0.3, -0.3)  — off-center for 3D look
    )
    Stroke: 2px, Color(0xFF88AACC)
    Inner highlight: small filled white circle at (-30%, -30%) offset
      radius = bubble_radius × 0.25, color = Color(0xAAFFFFFF)

Layer 5 — Outer casing ring (painted ON TOP):
  Thick annular ring (width = containerRadius × 0.08)
  Gradient based on level state:
    Level:   kGradientYellowCasing (with green glow)
    Close:   gradient toward kWarningYellow
    Off:     gradient toward kDangerRed
  Add kShadowGlowGreen or kShadowGlowRed to container for glow
```

```
State → Color transitions:
  Animate using AnimatedColor or Tween<Color> over 300ms
  When level is achieved:
    1. Casing ring color → kLevelGreen
    2. Container gets kShadowGlowGreen
    3. Play beep (if enabled)
    4. Vibrate (if enabled)
    5. Glow pulses 3× then holds
```

---

### `CompassWidget` — CustomPainter

```
Layer 1 — Outer bezel ring:
  Annular shape: outer = widget size, inner = 85% of outer
  Paint with kGradientChromeSweep (SweepGradient)
  Tick marks on inner edge:
    Every 5°: 4px line
    Every 10°: 6px line
    Every 90°: 10px line (N/E/S/W positions)

Layer 2 — Background plate:
  Filled dark circle: Color(0xFF0D0D0D)
  Optional: subtle radial gradient for depth

Layer 3 — Compass rose (static art):
  4-point star shape at center (decorative)
  Very subtle, low contrast against background

Layer 4 — Cardinal point labels (rotate WITH the compass):
  N: BebasNeue 16sp, kCompassNorth (red)
  E, S, W: BebasNeue 14sp, kTextSecondary
  NE, SE, SW, NW: BebasNeue 10sp, kTextTertiary
  All labels positioned at 75% of container radius from center

Layer 5 — Compass needle (rotates by -heading in radians):
  Diamond / elongated teardrop shape using Path
  Top half (north): filled kCompassNorth (red)
  Bottom half (south): filled kChromeLight (white/silver)
  Total length: 55% of container radius
  Width at widest: 8% of container radius

Layer 6 — Center cap:
  Small filled circle: radius = 5% of container radius
  Fill: RadialGradient([kChromeLight, kChromeDark])
  Specular highlight: tiny white dot at (-20%, -20%)

Animation: Wrap needle rotation in AnimationController
  Target = -heading_rad
  Use spring simulation or 200ms linear tween with shortest-path rotation
  (handle 359° → 1° wrapping: use atan2(sin, cos) difference)
```

---

### `AnalogDialWidget` — CustomPainter (reusable: Sound Meter + Light Meter)

```
Parameters:
  double value         // 0.0 to 1.0 (normalized)
  List<DialZone> zones // {double start, double end, Color color}
  String title
  String minLabel, maxLabel

Sweep angle: 220° total, from -110° to +110° (6 o'clock = 0, full sweep clockwise)

Layer 1 — Background circle:
  Dark: Color(0xFF0A0A0A)
  Engraved concentric rings: 3 rings, Color(0xFF1A1A1A), strokeWidth 0.5

Layer 2 — Zone arcs (painted in sequence, each DialZone):
  Arc width: 12% of radius
  Use canvas.drawArc with appropriate sweep angles
  Colors from zones list (e.g., green → yellow → orange → red for dB meter)

Layer 3 — Tick marks on arc:
  Major (every 10%): 10px line, kChromeLight
  Minor (every 5%): 6px line, kChromeMid
  Very minor (every 2%): 3px line, kChromeDark

Layer 4 — Needle:
  Thin triangle: base at center, tip at 60% of radius
  Fill: kDangerRed (red tip is standard for analog meters)
  Rotates based on value: angle = -110° + (value × 220°)
  Spring-damped animation: use PhysicsSimulation or AnimationController

Layer 5 — Center cap (same as compass)

Overlay (not painted, Widget layer):
  LedDisplay widget centered at 70% down (below center) showing current value
```

---

### `ToolCard` Widget (Home Screen Grid)

```
Root: GestureDetector > AnimatedContainer (for press animation)

AnimatedContainer:
  decoration: MetalPanel-style BoxDecoration
  duration: 100ms
  onTapDown: scale 0.95
  onTapUp/Cancel: scale 1.0

Content (Column, centered):
  SvgPicture.asset(iconPath, width: 56, height: 56)        — tool icon
  SizedBox(height: 10)
  Text(toolName, style: kTitleL)                            — Bebas Neue
  SizedBox(height: 4)
  Text(description, style: kCaption, textAlign: center)    — Inter
  SizedBox(height: 8)
  Row(mainAxisAlignment: end):
    Container(width: 8, height: 8, decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isSensorAvailable ? kLevelGreen : kDangerRed
    ))                                                       — sensor dot

Aspect ratio: height = width × 1.25 (portrait card)
```

---

## App-Wide Layout Rules

### Navigation
- No `BottomNavigationBar`
- No `NavigationRail`
- Home screen is the only hub
- All tools are full-screen, accessed via GoRouter push
- Back arrow in AppBar returns to Home

### AppBar (Custom)
All tool screens use a custom AppBar, not Flutter's default:
```
MetalPanel container with height 56px
  Row:
    GestureDetector > back arrow icon (← chevron, kChromeLight, 24px)
    Expanded > Text(toolName, style: kTitleXL, textAlign: center)
    SizedBox(width: 48)  — spacer to balance back arrow
```

### Spacing Grid
Use multiples of 4px:
`4, 8, 12, 16, 24, 32, 48, 64`

### Border Radius Scale
```
Panels and cards: 12px
Buttons: 8px
Displays: 6px
Chips/badges: 4px
Circular elements: no borderRadius (use BoxShape.circle)
```

---

## Animation Specifications

| Element | Duration | Curve | Notes |
|---------|----------|-------|-------|
| Screen push transition | 280ms | Curves.easeInOut | Fade + slight scale up (0.96→1.0) |
| Button press | 80ms | Curves.easeOut | scale 1.0 → 0.97 |
| Button release | 150ms | Curves.easeOut | scale 0.97 → 1.0 |
| Bubble physics | Continuous | Spring stiffness:120 damping:18 | Simulate realistic fluid resistance |
| Compass needle | 200ms | Curves.easeOut | Shortest-path rotation, handle wrap-around |
| Dial needle | 150ms | Curves.easeOut | Damped spring simulation |
| Level achieved glow | 400ms × 3 | Curves.easeInOut | Pulse 3 times then hold |
| ToolCard tap | 100ms in / 150ms out | Curves.easeIn / Out | Scale press animation |
| LedDisplay value | 120ms | Linear | Number transition, no animation needed — just update |

---

## Icon Guidelines

### Tool Card Icons (SVG, 56×56 viewBox)
Each tool has one custom icon. Style requirements:
- NOT flat — use 2–3 shading levels to imply depth
- Shows the physical tool in miniature
- Dominant color = tool's accent color (see list below)
- Small highlight/shadow to suggest the object is 3D
- No outlines — fill-based illustration

| Tool | Accent Color | Icon Description |
|------|-------------|-----------------|
| Spirit Level | `kYellow` | Side view of level with bubble in tube |
| Digital Ruler | `kChromeMid` | Short ruler section with tick marks |
| Compass | `kCompassBlue` | Compass rose with red needle |
| Protractor | `kOrange` | Semicircular protractor with degree markings |
| Sound Meter | `kLevelGreen` | VU meter needle over arc |
| Vibration Meter | `kLevelGreen` | Waveform line with peaks |
| Light Meter | `kWarningYellow` | Sun/light disc with exposure meter needle |
| Metal Detector | `kChromeMid` | Magnet horseshoe shape |
| Unit Converter | `kTextSecondary` | Arrow ↔ symbol between two unit squares |
| Clinometer | `kOrange` | Tilted surface with angle arc |

---

## "Do Not" Rules

1. **Do not use Material ripple effects** (`InkWell` splash). Use `GestureDetector` + `AnimatedContainer` for all interactive elements.
2. **Do not use `ElevatedButton`, `TextButton`, or `FilledButton`** anywhere in tool screens. All buttons are `TactileButton`.
3. **Do not use `Card` widget** — use `MetalPanel`.
4. **Do not use `SnackBar`** — use a `MetalPanel` overlay banner that auto-dismisses.
5. **Do not use flat single-color backgrounds** — all panel surfaces must have the `kGradientBrushedAluminum` or equivalent gradient.
6. **Do not use emoji in UI** — this is a professional tool, use SVG icons.
7. **Do not use `Colors.grey`** — use the defined `kChrome*` constants.
8. **Do not use `Text(value, style: Theme.of(context).textTheme.bodyMedium)`** — always use explicit `kTextStyle*` constants.
9. **Do not use `LinearProgressIndicator`** — not in the industrial vocabulary. Use analog displays.
10. **Do not use `showModalBottomSheet` with default styling** — style any sheet as a MetalPanel rising from bottom.
