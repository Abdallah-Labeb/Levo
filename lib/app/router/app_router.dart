import 'package:go_router/go_router.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/core/storage/preferences_service.dart';

// Import all screens
import 'package:levo/features/home/view/home_screen.dart';
import 'package:levo/features/onboarding/view/onboarding_screen.dart';
import 'package:levo/features/settings/view/settings_screen.dart';
import 'package:levo/features/spirit_level/view/spirit_level_screen.dart';
import 'package:levo/features/compass/view/compass_screen.dart';
import 'package:levo/features/ruler/view/ruler_screen.dart';
import 'package:levo/features/protractor/view/protractor_screen.dart';
import 'package:levo/features/sound_meter/view/sound_meter_screen.dart';
import 'package:levo/features/vibration_meter/view/vibration_meter_screen.dart';
import 'package:levo/features/light_meter/view/light_meter_screen.dart';
import 'package:levo/features/metal_detector/view/metal_detector_screen.dart';
import 'package:levo/features/unit_converter/view/unit_converter_screen.dart';
import 'package:levo/features/clinometer/view/clinometer_screen.dart';

/// App router configuration managing navigation paths and onboarding redirection.
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final prefs = getIt<PreferencesService>();
    final onboardingDone = prefs.onboardingComplete;
    final isGoingToOnboarding = state.matchedLocation == '/onboarding';

    if (!onboardingDone && !isGoingToOnboarding) {
      return '/onboarding';
    }
    if (onboardingDone && isGoingToOnboarding) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/spirit-level',
      builder: (context, state) => const SpiritLevelScreen(),
    ),
    GoRoute(
      path: '/compass',
      builder: (context, state) => const CompassScreen(),
    ),
    GoRoute(
      path: '/ruler',
      builder: (context, state) => const RulerScreen(),
    ),
    GoRoute(
      path: '/protractor',
      builder: (context, state) => const ProtractorScreen(),
    ),
    GoRoute(
      path: '/sound-meter',
      builder: (context, state) => const SoundMeterScreen(),
    ),
    GoRoute(
      path: '/vibration-meter',
      builder: (context, state) => const VibrationMeterScreen(),
    ),
    GoRoute(
      path: '/light-meter',
      builder: (context, state) => const LightMeterScreen(),
    ),
    GoRoute(
      path: '/metal-detector',
      builder: (context, state) => const MetalDetectorScreen(),
    ),
    GoRoute(
      path: '/unit-converter',
      builder: (context, state) => const UnitConverterScreen(),
    ),
    GoRoute(
      path: '/clinometer',
      builder: (context, state) => const ClinometerScreen(),
    ),
  ],
);
