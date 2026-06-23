/// Animation durations and physics constants for Levo.
class AppAnimations {
  AppAnimations._();

  // Animation Durations
  static const Duration screenTransition = Duration(milliseconds: 280);
  static const Duration buttonPress = Duration(milliseconds: 80);
  static const Duration buttonRelease = Duration(milliseconds: 150);
  static const Duration levelGlowPulse = Duration(milliseconds: 400);
  static const Duration compassNeedle = Duration(milliseconds: 200);
  static const Duration dialNeedle = Duration(milliseconds: 150);
  static const Duration levelStatusColor = Duration(milliseconds: 300);
  static const Duration bannerDismiss = Duration(seconds: 3);
  static const Duration sensorCheckTimeout = Duration(milliseconds: 500);

  // Bubble level snap animation
  static const Duration bubbleSnap = Duration(milliseconds: 250);

  // Onboarding screen
  static const Duration onboardingPageSlide = Duration(milliseconds: 300);
  static const Duration onboardingDotResize = Duration(milliseconds: 200);

  // Metal detector radar pulse rates (mapped to alert levels)
  static const Duration metalDetectorPulseDefault = Duration(milliseconds: 1200);
  static const Duration metalDetectorPulseNone = Duration(milliseconds: 1500);
  static const Duration metalDetectorPulseWeak = Duration(milliseconds: 1200);
  static const Duration metalDetectorPulseMedium = Duration(milliseconds: 600);
  static const Duration metalDetectorPulseStrong = Duration(milliseconds: 250);
  static const Duration metalDetectorPulseCritical = Duration(milliseconds: 85);

  // Compass interference indicator auto-reset
  static const Duration interferenceIndicator = Duration(seconds: 3);
  static const Duration locationTimeout = Duration(seconds: 4);

  // Home screen blinking LED loading indicator
  static const Duration blinkingLed = Duration(milliseconds: 1000);

  // Drum picker scroll snap
  static const Duration drumPickerSnap = Duration(milliseconds: 200);

  // Sound meter segment animation
  static const Duration soundMeterSegment = Duration(milliseconds: 60);

  // Popup modal durations
  static const Duration popupDismiss = Duration(seconds: 2);
  static const Duration popupSlide = Duration(milliseconds: 250);
  static const Duration popupTransition = Duration(milliseconds: 220);

  // Spring Physics for Spirit Level Bubble
  static const double bubbleStiffness = 120.0;
  static const double bubbleDamping = 18.0;
}

