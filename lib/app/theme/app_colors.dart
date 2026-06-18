import 'package:flutter/material.dart';

/// Design system colors for Levo skeuomorphic UI.
class AppColors {
  AppColors._();

  // Background & Surface Hierarchy
  static const kBackground = Color(0xFF111111);
  static const kSurface = Color(0xFF1C1C1C);
  static const kSurfaceElevated = Color(0xFF242424);
  static const kSurfaceInset = Color(0xFF0A0A0A);
  static const kDivider = Color(0xFF2A2A2A);

  // Chrome & Brushed Aluminum Tones
  static const kChromeLight = Color(0xFFCCCCCC);
  static const kChromeMid = Color(0xFF888888);
  static const kChromeDark = Color(0xFF444444);
  static const kChromeDarker = Color(0xFF2A2A2A);

  // Panel Border Highlights
  static const kBorderHighlight = Color(0xFF3A3A3A);
  static const kBorderShadow = Color(0xFF141414);

  // Brand Accents
  static const kYellow = Color(0xFFF5C22B);
  static const kYellowDark = Color(0xFFCC9F1C);
  static const kYellowDarker = Color(0xFF8A6A12);
  static const kOrange = Color(0xFFFF6B35);
  static const kOrangeDark = Color(0xFFCC4E1E);

  // Semantic & Status Colors
  static const kLevelGreen = Color(0xFF4EBA74);
  static const kLevelGreenDim = Color(0xFF1A3A28);
  static const kLevelGreenGlow = Color(0x334EBA74);
  static const kWarningYellow = Color(0xFFFFCC00);
  static const kWarningYellowDim = Color(0xFF3A3000);
  static const kDangerRed = Color(0xFFE84545);
  static const kDangerRedDim = Color(0xFF3A1010);
  static const kDangerRedGlow = Color(0x33E84545);

  // Compass Accents
  static const kCompassNorth = Color(0xFFE84545);
  static const kCompassBlue = Color(0xFF3B9EEB);
  static const kCompassBlueDim = Color(0xFF0A1A2A);

  // LED Displays
  static const kDisplayGreen = Color(0xFF00FF41);
  static const kDisplayGreenDim = Color(0xFF003310);
  static const kDisplayGreenGlow = Color(0x4400FF41);
  static const kDisplayAmber = Color(0xFFFF8C00);
  static const kDisplayAmberDim = Color(0xFF2A1500);
  static const kDisplayBg = Color(0xFF050505);
  static const kDisplayGreenBorder = Color(0xFF003310);
  static const kDisplayGreenDimFaded = Color(0xE6003310);


  // Typography Colors
  static const kTextPrimary = Color(0xFFEEEEEE);
  static const kTextSecondary = Color(0xFFFFFFFF);
  static const kTextTertiary = Color(0xFF555555);
  static const kTextOnYellow = Color(0xFF1A1A1A);
  static const kTextOnGreen = Color(0xFF0A2010);
  static const kBlack = Color(0xFF000000);

  // Shadows
  static const kShadowDark = Color(0x73000000); // Colors.black45 equivalent
  static const kShadowMedium = Color(0x61000000); // Colors.black38 equivalent

  // Gradients
  static const kGradientBrushedAluminum = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF282828), Color(0xFF1A1A1A)],
  );

  static const kGradientBrushedHorizontal = LinearGradient(
    colors: [Color(0xFF3A3A3A), Color(0xFF6E6E6E), Color(0xFF3A3A3A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const kGradientYellowCasing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5C22B), Color(0xFFC0910F)],
  );

  static const kGradientChromeSweep = SweepGradient(
    colors: [
      Color(0xFF2A2A2A),
      Color(0xFF6A6A6A),
      Color(0xFFCCCCCC),
      Color(0xFF6A6A6A),
      Color(0xFF2A2A2A),
    ],
    stops: [0.0, 0.2, 0.5, 0.8, 1.0],
  );

  static const kGradientButtonNormal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF303030), Color(0xFF252525)],
  );

  static const kGradientButtonPressed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF222222), Color(0xFF2D2D2D)],
  );

  static const kGradientButtonActive = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5C22B), Color(0xFFC0910F)],
  );

  // Instrument Specific Skeuomorphic Colors
  static const kCathodeBg = Color(0xFF070B07);
  static const kCathodeGrid = Color(0xFF132B13);
  static const kPaperBg = Color(0xFFF3EFE3);
  static const kPaperGrid = Color(0xFFE0D9C8);
  static const kDraftingLine = Color(0xFF6E6759);
  static const kDraftingText = Color(0xFF4A443B);

  static const kPlumbBobBrassHighlight = Color(0xFFFFF0B3);
  static const kPlumbBobBrassMid = Color(0xFFDFB831);
  static const kPlumbBobBrassDark = Color(0xFF7A610B);
  static const kPlumbBobCollar = Color(0xFF665108);

  static const kCompassFaceStart = Color(0xFF222222);
  static const kCompassFaceMid = Color(0xFF141414);
  static const kCompassFaceEnd = Color(0xFF0C0C0C);
  static const kCompassNeedleHighlight = Color(0xFFFF8B8B);
  static const kCompassNeedleShadow = Color(0xFF7D1616);
  static const kCompassPivotHighlight = Color(0xFFFFEA9F);
  static const kCompassPivotMid = Color(0xFFCCA214);
  static const kCompassPivotShadow = Color(0xFF6B5102);
  static const kCompassPinCap = Color(0xFFE0DDC5);
  static const kCompassGroove = Color(0xFF0F0F0F);
}
