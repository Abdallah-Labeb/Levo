# LEVO — Anti-Patterns Guard
> This file is a quality enforcement checklist. Before submitting ANY code, run through every section.
> If your output contains ANY of these patterns, rewrite before delivering.

---

## SECTION 1: THE VIBE-CODING SINS
*These are the most common ways AI-generated Flutter apps fail. Every single one is banned.*

### SIN 1: Hardcoded Colors
```dart
// ❌ BANNED — found in widget file
color: Color(0xFF1C1C1C)
color: Colors.green
color: Colors.grey
color: Colors.grey[800]
backgroundColor: const Color(0xFF111111)

// ✅ REQUIRED
color: AppColors.kSurface
color: AppColors.kLevelGreen
color: AppColors.kChromeMid
backgroundColor: AppColors.kBackground
```
**Rule:** `grep -r "Color(0x" lib/features` must return 0 results.
**Rule:** `grep -r "Colors\." lib/features` must return 0 results except in theme files.

---

### SIN 2: Hardcoded Text Styles
```dart
// ❌ BANNED
style: TextStyle(fontSize: 18, fontFamily: 'BebasNeue', color: Color(0xFF...))
style: TextStyle(fontSize: 14, color: Colors.white)
style: Theme.of(context).textTheme.bodyMedium

// ✅ REQUIRED
style: AppTypography.kTitleL
style: AppTypography.kBody
style: AppTypography.kDisplayL
```

---

### SIN 3: Hardcoded Strings in Widgets
```dart
// ❌ BANNED — any user-visible string literal in a widget
Text('Spirit Level')
Text('Calibrate')
Text('mm')
Text('Not available')
Text('High accuracy')
tooltip: 'Reset'
errorText: 'Sensor not found'
hintText: 'Enter value'

// ✅ REQUIRED
Text(context.l10n.spiritLevelTitle)
Text(context.l10n.spiritLevelButtonCalibrate)
Text(context.l10n.commonUnitMm)
Text(context.l10n.sensorErrorTitle)
```
**Rule:** `grep -rn "Text('" lib/features` → zero results.
**Rule:** `grep -rn 'Text("' lib/features` → zero results.
**Exception:** Debug-only `debugPrint` statements are allowed with `kDebugMode` guard.

---

### SIN 4: Hardcoded Spacing/Sizing
```dart
// ❌ BANNED
SizedBox(height: 16)
Padding(padding: EdgeInsets.all(12))
SizedBox(width: 48)
borderRadius: BorderRadius.circular(12)
fontSize: 18

// ✅ REQUIRED
SizedBox(height: AppDimensions.paddingL)
Padding(padding: EdgeInsetsDirectional.all(AppDimensions.paddingM))
SizedBox(width: AppDimensions.space48)
borderRadius: BorderRadius.circular(AppDimensions.radiusPanel)
// font sizes are in AppTypography constants — never set manually
```

---

### SIN 5: Hardcoded Durations
```dart
// ❌ BANNED
duration: Duration(milliseconds: 300)
duration: Duration(milliseconds: 80)
AnimationController(duration: const Duration(milliseconds: 200), ...)

// ✅ REQUIRED
duration: AppAnimations.levelStatusColor
duration: AppAnimations.buttonPress
AnimationController(duration: AppAnimations.compassNeedle, ...)
```

---

### SIN 6: Material Widgets in Tool Screens
```dart
// ❌ BANNED anywhere in lib/features/*/view/ or lib/features/*/widgets/
ElevatedButton(...)
TextButton(...)
FilledButton(...)
OutlinedButton(...)
Card(...)
ListTile(...)
InkWell(...)
Scaffold(backgroundColor: ...) // Use custom scaffold structure
SnackBar(...)
showSnackBar(...)
LinearProgressIndicator(...)
CircularProgressIndicator(...)  // Use custom loading

// ✅ REQUIRED
TactileButton(...)      // for all buttons
MetalPanel(...)         // for all surface containers
GestureDetector(...)    // for all tap interactions
LevoBanner(...)         // for notifications
```
**Exception:** Settings screen may use `SwitchListTile`, `ListTile`, and `Divider` for accessibility.

---

### SIN 7: setState() for Business Logic
```dart
// ❌ BANNED
class _SpiritLevelScreenState extends State<SpiritLevelScreen> {
  double _pitch = 0.0;
  StreamSubscription? _sub;

  @override
  void initState() {
    _sub = accelerometerEventStream().listen((event) {
      setState(() { _pitch = event.x; }); // ← STATE MANAGEMENT IN WIDGET
    });
  }
}

// ✅ REQUIRED
// All sensor logic → Cubit
// Widget only calls BlocBuilder
class SpiritLevelScreen extends StatelessWidget { // prefer StatelessWidget
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpiritLevelCubit, SpiritLevelState>(
      builder: (context, state) {
        return BubbleLevelWidget(pitch: state.pitch, roll: state.roll);
      },
    );
  }
}
```

---

### SIN 8: Sensor Leak (No Cleanup)
```dart
// ❌ BANNED — subscription never cancelled
class SpiritLevelCubit extends Cubit<SpiritLevelState> {
  void startListening() {
    accelerometerEventStream().listen(_onEvent); // ← NO SUBSCRIPTION STORED
  }
  // ← NO close() override → sensor runs forever in background
}

// ✅ REQUIRED
class SpiritLevelCubit extends Cubit<SpiritLevelState> {
  StreamSubscription<AccelerometerEvent>? _sub;

  void startListening() {
    _sub = accelerometerEventStream(
      samplingPeriod: SensorInterval.ui,
    ).listen(_onEvent);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
```

---

### SIN 9: shouldRepaint Always True
```dart
// ❌ BANNED — repaints every frame even when data is identical
@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

// ❌ ALSO BANNED — not implemented at all (defaults to true in CustomPainter base)
class BubbleLevelPainter extends CustomPainter {
  // missing shouldRepaint
}

// ✅ REQUIRED
@override
bool shouldRepaint(BubbleLevelPainter oldDelegate) =>
    oldDelegate.pitch != pitch ||
    oldDelegate.roll != roll ||
    oldDelegate.status != status ||
    oldDelegate.isHeld != isHeld;
```

---

### SIN 10: Paint Objects Created Inside paint()
```dart
// ❌ BANNED — allocates new object on every frame (60+ times/second)
@override
void paint(Canvas canvas, Size size) {
  final bubblePaint = Paint()          // ← ALLOCATION INSIDE paint()
    ..color = AppColors.kLevelGreen
    ..style = PaintingStyle.fill;
  canvas.drawCircle(center, radius, bubblePaint);
}

// ✅ REQUIRED — pre-allocated as static fields
class BubbleLevelPainter extends CustomPainter {
  static final _bubblePaint = Paint()
    ..color = const Color(0xCCD4EFFF)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(center, radius, _bubblePaint);
  }
}
```

---

### SIN 11: LTR-Only Layout (RTL Blindness)
```dart
// ❌ BANNED — breaks Arabic RTL
EdgeInsets.only(left: 16)
EdgeInsets.symmetric(horizontal: 16)  // OK for symmetric, banned for one-sided
Alignment.centerLeft
Alignment.centerRight
Row(children: [backButton, Expanded(child: title), SizedBox(width: 48)])
// ↑ In RTL the back arrow should be on the right

// ✅ REQUIRED
EdgeInsetsDirectional.only(start: AppDimensions.paddingL)
AlignmentDirectional.centerStart
// For AppBar with back arrow — use Directionality.of(context) to flip icon
Icon(
  Directionality.of(context) == TextDirection.rtl
      ? Icons.chevron_right
      : Icons.chevron_left,
)
```

---

### SIN 12: Emoji in UI
```dart
// ❌ BANNED — unprofessional, inconsistent across Android versions
Text('✅ Level!')
Text('🔊 Sound')
Icon(Icons.emoji_emotions)
'⚠️ Sensor not available'

// ✅ REQUIRED
SvgPicture.asset('assets/icons/ic_check.svg')
Text(context.l10n.soundMeterZoneSilence)
SensorErrorView(sensorName: context.l10n.commonSensorAccelerometer)
```

---

### SIN 13: Sensor Fastest Rate
```dart
// ❌ BANNED — drains battery, overloads UI thread
accelerometerEventStream(samplingPeriod: SensorInterval.fastest)
accelerometerEventStream(samplingPeriod: SensorInterval.game)

// ✅ REQUIRED
accelerometerEventStream(samplingPeriod: SensorInterval.ui)
```

---

### SIN 14: Premature Permission Request
```dart
// ❌ BANNED — in main.dart, home screen, or any non-tool location
void main() async {
  await Permission.microphone.request(); // ← NEVER HERE
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ❌ NEVER request permissions here
  }
}

// ✅ REQUIRED — in the specific tool's initState or a "PermissionGateWidget"
// Only when user OPENS SoundMeterScreen for the first time
class SoundMeterScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    context.read<SoundMeterCubit>().checkAndRequestMicPermission();
  }
}
```

---

### SIN 15: TODO Comments as Shortcuts
```dart
// ❌ BANNED — incomplete implementations
void calibrate() {
  // TODO: implement calibration
}

Widget build(BuildContext context) {
  // TODO: add RTL support
  return Container(); // placeholder
}

// ... rest of implementation
```
**Rule:** No file you deliver may contain `// TODO`, `// FIXME`, `// HACK`, `// XXX`, or `// ...`.
**Rule:** No function body may contain only a comment with no implementation.
**Rule:** No widget may return `Container()` or `SizedBox()` as a placeholder.

---

### SIN 16: Global State Mutations
```dart
// ❌ BANNED — mutable global variables
double currentPitch = 0.0;  // top-level mutable variable
List<double> sensorHistory = []; // mutable global list

// ✅ REQUIRED — state lives in Cubit, scoped to its lifetime
class VibrationMeterCubit extends Cubit<VibrationMeterState> {
  final Queue<double> _samples = Queue(); // owned by Cubit, not global
}
```

---

### SIN 17: Missing `const` Constructor
```dart
// ❌ BANNED — every widget allocation that could be const, must be const
Widget build(BuildContext context) {
  return MetalPanel(    // ← missing const if MetalPanel has const constructor
    child: LedDisplay(  // ← missing const
      value: '0.00',
    ),
  );
}

// ✅ REQUIRED
Widget build(BuildContext context) {
  return const MetalPanel(
    child: LedDisplay(value: '0.00'),
  );
}
```
**Rule:** Run `dart fix --apply` and `flutter analyze` — zero "Prefer const" warnings.

---

### SIN 18: Network Calls Anywhere
```dart
// ❌ BANNED — any HTTP or network call
http.get(Uri.parse('https://...'))
Dio().get('https://...')
FirebaseFirestore.instance.collection('...')
FirebaseAnalytics.instance.logEvent(...)
Crashlytics.instance.recordError(...)

// ✅ REQUIRED: Zero network calls at runtime. Period.
// Exception: in_app_purchase billing library internally uses Play Store — that's acceptable.
```

---

### SIN 19: Incorrect Barrel Files
```dart
// ❌ BANNED — barrel file re-exporting everything
// lib/features/spirit_level/index.dart
export 'bloc/spirit_level_cubit.dart';
export 'bloc/spirit_level_state.dart';
export 'view/spirit_level_screen.dart';
export 'widgets/bubble_level_widget.dart';

// WHY: barrel files slow Dart compilation by forcing the compiler
// to analyze all exported files even when only one is needed.

// ✅ REQUIRED: direct imports
import 'package:levo/features/spirit_level/bloc/spirit_level_cubit.dart';
```

---

### SIN 20: Imprecise Equatable Props
```dart
// ❌ BANNED — missing fields in props means BlocBuilder won't rebuild
class SpiritLevelState extends Equatable {
  const SpiritLevelState({this.pitch = 0.0, this.roll = 0.0, this.status, this.isHeld});
  final double pitch;
  final double roll;
  final LevelStatus? status;
  final bool isHeld;

  @override
  List<Object?> get props => [pitch, roll]; // ← MISSING status and isHeld!
}

// ✅ REQUIRED — every field in props
@override
List<Object?> get props => [pitch, roll, status, isHeld, showPercent,
    isSensorAvailable, errorMessage, mode];
```

---

## SECTION 2: LOCALIZATION ANTI-PATTERNS

### L10N SIN 1: Missing Arabic Key
```json
// ❌ BANNED — key exists in English but not in Arabic
// app_en.arb
{ "spiritLevelButtonCalibrate": "Calibrate" }

// app_ar.arb  ← missing this key entirely
// Result: app crashes or shows key name in Arabic mode

// ✅ REQUIRED — every key in en must exist in ar
// app_ar.arb
{ "spiritLevelButtonCalibrate": "معايرة" }
```

### L10N SIN 2: Concatenated Localized Strings
```dart
// ❌ BANNED — breaks in Arabic where word order differs
Text('${context.l10n.commonUnitDegrees}${state.angle.toStringAsFixed(2)}')
Text('${value} ${context.l10n.commonUnitMm}')

// ✅ REQUIRED — use ARB placeholders for values that appear within strings
// app_en.arb: "spiritLevelAngleDisplay": "{angle}°"
// app_ar.arb: "spiritLevelAngleDisplay": "{angle}°"
// In widget: Text(context.l10n.spiritLevelAngleDisplay(angle: formattedAngle))
```

### L10N SIN 3: Hardcoded Number Formatting
```dart
// ❌ BANNED — not locale-aware
Text('${angle.toStringAsFixed(2)}°')
Text(value.toString())

// ✅ REQUIRED — use intl NumberFormat with locale
final formatter = NumberFormat.decimalPatternDigits(
  locale: Localizations.localeOf(context).toString(),
  decimalDigits: 2,
);
Text(formatter.format(angle))
```

---

## SECTION 3: SECURITY & SAFETY

### SECURITY SIN 1: Cleartext Traffic
```xml
<!-- ❌ BANNED in AndroidManifest.xml -->
android:usesCleartextTraffic="true"

<!-- ✅ REQUIRED -->
android:usesCleartextTraffic="false"
```

### SECURITY SIN 2: Storing Sensitive Data in SharedPreferences as Plain Text
The only data stored is: calibration offsets, UI preferences, pro status flag.
None of this is sensitive. But DO NOT store:
- Device IDs
- Any string that could identify the user
- Anything received from a network call (there should be none)

### SECURITY SIN 3: Internet Permission Without Justification
```xml
<!-- ❌ BANNED if not needed -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- ✅ REQUIRED: only add if in_app_purchase billing requires it,
     with a comment explaining WHY -->
<!-- Required for Google Play Billing (in_app_purchase package) -->
<uses-permission android:name="android.permission.INTERNET" />
```

---

## SECTION 4: PERFORMANCE CHECKLIST

Run this before every phase completion:

```
□ All CustomPainter.shouldRepaint() implementations are precise (not always-true)
□ RepaintBoundary wraps every CustomPainter widget
□ No Paint() objects created inside paint() method
□ All sensor streams use SensorInterval.ui
□ All StreamSubscriptions are cancelled in close()/dispose()
□ No setState() called inside StreamSubscription callback in a StatefulWidget
□ All stateless widgets that CAN be const ARE const
□ No print() statements (only debugPrint inside kDebugMode)
□ Queue<double> used for seismograph history (not unbounded List)
□ Compass low-pass filter applied (alpha 0.2) before emitting state
□ Grain texture cached once at startup (not regenerated per frame)
```

---

## SECTION 5: FINAL DELIVERY CHECKLIST

Before marking any phase as complete, verify ALL of these:

```
LOCALIZATION
□ flutter gen-l10n produces zero errors
□ app_ar.arb has exactly the same number of keys as app_en.arb
□ No hardcoded user-visible strings in lib/features/ (grep check)
□ RTL layout verified for all screens in this phase
□ Number formatting uses intl package, not .toString()

CODE QUALITY
□ flutter analyze → zero issues
□ flutter test → all tests pass
□ No TODO/FIXME/HACK comments
□ No magic numbers in widget files
□ No magic colors in widget files
□ All Equatable props lists are complete

SENSORS
□ All StreamSubscriptions stored in nullable variables
□ All StreamSubscriptions cancelled in close()
□ SensorInterval.ui used everywhere
□ Gimbal lock handled for applicable tools

ARCHITECTURE
□ No business logic in StatefulWidget
□ All Cubits injected via GoRouter (not global BlocProvider)
□ No direct SharedPreferences.getInstance() calls outside PreferencesService
□ No package imports not in the approved list

UI/UX
□ No Material buttons/cards in tool screens
□ Ads hidden for Pro users
□ WakeLock acquired on tool open, released on dispose
□ Back navigation works correctly on every screen
□ No placeholder widgets (Container(), SizedBox() as placeholders)

ANDROID
□ usesCleartextTraffic="false"
□ All required sensor features declared as android:required="false"
□ minSdkVersion=23
□ R8 minification enabled in release builds
```

---

## SECTION 6: WHAT A GOOD RESPONSE LOOKS LIKE

When you (the agent) complete a task, your response should follow this format:

```
## Completed: [Phase X.Y — Task Name]

### Files created/modified:
- `lib/path/to/file.dart` — [one-line description]
- `lib/l10n/app_en.arb` — added X new keys
- `lib/l10n/app_ar.arb` — added X new keys (Arabic translations)
- `test/unit/path/test_file.dart` — [what is tested]

### Key decisions made:
- [Any non-obvious choice and why]

### Anti-pattern checks passed:
- ✅ No hardcoded colors
- ✅ No hardcoded strings
- ✅ shouldRepaint precise
- ✅ Sensor cleanup confirmed
- ✅ RTL tested

### Next: Ready for Phase X.Z — [task name]
```

A response that does NOT include the files check and anti-pattern verification is incomplete.
