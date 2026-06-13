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

  // Spring Physics for Spirit Level Bubble
  static const double bubbleStiffness = 120.0;
  static const double bubbleDamping = 18.0;
}
