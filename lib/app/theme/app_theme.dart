import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:levo/app/theme/app_colors.dart';

/// Application theme definitions for Levo.
class AppTheme {
  AppTheme._();

  /// Dark theme definition for Levo's skeuomorphic layout.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.kBackground,
      primaryColor: AppColors.kYellow,
      dividerColor: AppColors.kDivider,
      fontFamily: 'Inter',
      useMaterial3: true,

      // Status bar & navigation bar styling
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.kBackground,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      // Override default text selection colors for input fields
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.kYellow,
        selectionColor: AppColors.kYellowDarker,
        selectionHandleColor: AppColors.kYellow,
      ),

      // Tooltips configuration
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.kSurfaceElevated,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: AppColors.kBorderHighlight),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.kTextPrimary,
          fontSize: 12.0,
        ),
      ),
    );
  }
}
