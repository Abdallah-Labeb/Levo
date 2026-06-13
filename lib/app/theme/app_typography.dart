import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';

/// Typography styles for Levo skeuomorphic UI.
class AppTypography {
  AppTypography._();

  // Digital Displays (ShareTechMono)
  static const kDisplayXL = TextStyle(
    fontFamily: 'ShareTechMono',
    fontSize: 56,
    color: AppColors.kDisplayGreen,
    letterSpacing: 3,
  );

  static const kDisplayL = TextStyle(
    fontFamily: 'ShareTechMono',
    fontSize: 40,
    color: AppColors.kDisplayGreen,
    letterSpacing: 2,
  );

  static const kDisplayM = TextStyle(
    fontFamily: 'ShareTechMono',
    fontSize: 28,
    color: AppColors.kDisplayGreen,
    letterSpacing: 1.5,
  );

  static final kDisplayS = TextStyle(
    fontFamily: 'ShareTechMono',
    fontSize: 18,
    color: AppColors.kDisplayGreenDim.withAlpha(230),
    letterSpacing: 1,
  );

  // Labels (Bebas Neue)
  static const kTitleXL = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 26,
    color: AppColors.kTextPrimary,
    letterSpacing: 4,
  );

  static const kTitleL = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 18,
    color: AppColors.kTextPrimary,
    letterSpacing: 2.5,
  );

  static const kSectionHeader = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 13,
    color: AppColors.kTextSecondary,
    letterSpacing: 3,
  );

  static const kUnitLabel = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 22,
    color: AppColors.kTextSecondary,
    letterSpacing: 1.5,
  );

  // Body & General Interface (Inter)
  static const kBody = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextPrimary,
  );

  static const kBodySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextSecondary,
  );

  static const kCaption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.kTextSecondary,
    letterSpacing: 1.2,
  );

  static const kButton = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.kTextPrimary,
    letterSpacing: 0.5,
  );
}
