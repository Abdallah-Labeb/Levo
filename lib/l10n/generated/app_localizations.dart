import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Levo'**
  String get appName;

  /// No description provided for @homeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Levo'**
  String get homeScreenTitle;

  /// No description provided for @homeScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Measurement Toolkit'**
  String get homeScreenSubtitle;

  /// No description provided for @spiritLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Spirit Level'**
  String get spiritLevelTitle;

  /// No description provided for @spiritLevelDesc.
  ///
  /// In en, this message translates to:
  /// **'2D/1D bubble level'**
  String get spiritLevelDesc;

  /// No description provided for @compassTitle.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compassTitle;

  /// No description provided for @compassDesc.
  ///
  /// In en, this message translates to:
  /// **'Tilt-compensated magnetic compass'**
  String get compassDesc;

  /// No description provided for @rulerTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Ruler'**
  String get rulerTitle;

  /// No description provided for @rulerDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure objects using your screen scale'**
  String get rulerDesc;

  /// No description provided for @protractorTitle.
  ///
  /// In en, this message translates to:
  /// **'Protractor'**
  String get protractorTitle;

  /// No description provided for @protractorDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure angles drawn on screen'**
  String get protractorDesc;

  /// No description provided for @protractorLabelAngle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get protractorLabelAngle;

  /// No description provided for @protractorLabelSlopeGrade.
  ///
  /// In en, this message translates to:
  /// **'Slope Grade'**
  String get protractorLabelSlopeGrade;

  /// No description provided for @soundMeterTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound Level Meter'**
  String get soundMeterTitle;

  /// No description provided for @soundMeterDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure ambient noise in decibels'**
  String get soundMeterDesc;

  /// No description provided for @vibrationMeterTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibration Meter'**
  String get vibrationMeterTitle;

  /// No description provided for @vibrationMeterDesc.
  ///
  /// In en, this message translates to:
  /// **'Plot real-time vibration seismograph'**
  String get vibrationMeterDesc;

  /// No description provided for @lightMeterTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Meter'**
  String get lightMeterTitle;

  /// No description provided for @lightMeterDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure illuminance in Lux'**
  String get lightMeterDesc;

  /// No description provided for @lightMeterSceneDark.
  ///
  /// In en, this message translates to:
  /// **'Pitch Black / Night'**
  String get lightMeterSceneDark;

  /// No description provided for @lightMeterSceneDim.
  ///
  /// In en, this message translates to:
  /// **'Dim Indoors / Living Room'**
  String get lightMeterSceneDim;

  /// No description provided for @lightMeterSceneNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Indoors / Office'**
  String get lightMeterSceneNormal;

  /// No description provided for @lightMeterSceneBright.
  ///
  /// In en, this message translates to:
  /// **'Bright Indoors / Overcast Day'**
  String get lightMeterSceneBright;

  /// No description provided for @lightMeterSceneSunlight.
  ///
  /// In en, this message translates to:
  /// **'Direct Sunlight'**
  String get lightMeterSceneSunlight;

  /// No description provided for @metalDetectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Metal Detector'**
  String get metalDetectorTitle;

  /// No description provided for @metalDetectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Detect magnetic field strength'**
  String get metalDetectorDesc;

  /// No description provided for @unitConverterTitle.
  ///
  /// In en, this message translates to:
  /// **'Unit Converter'**
  String get unitConverterTitle;

  /// No description provided for @unitConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert construction-related units'**
  String get unitConverterDesc;

  /// No description provided for @unitCategoryLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get unitCategoryLength;

  /// No description provided for @unitCategoryArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get unitCategoryArea;

  /// No description provided for @unitCategoryVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get unitCategoryVolume;

  /// No description provided for @unitCategoryMass.
  ///
  /// In en, this message translates to:
  /// **'Mass'**
  String get unitCategoryMass;

  /// No description provided for @unitCategorySpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get unitCategorySpeed;

  /// No description provided for @unitCategoryPressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get unitCategoryPressure;

  /// No description provided for @unitCategoryAngle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get unitCategoryAngle;

  /// No description provided for @clinometerTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinometer'**
  String get clinometerTitle;

  /// No description provided for @clinometerDesc.
  ///
  /// In en, this message translates to:
  /// **'Measure slope angle and grade'**
  String get clinometerDesc;

  /// No description provided for @spiritLevelModeFlat.
  ///
  /// In en, this message translates to:
  /// **'2D Surface'**
  String get spiritLevelModeFlat;

  /// No description provided for @spiritLevelModeEdge.
  ///
  /// In en, this message translates to:
  /// **'1D Edge'**
  String get spiritLevelModeEdge;

  /// No description provided for @spiritLevelButtonCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get spiritLevelButtonCalibrate;

  /// No description provided for @spiritLevelButtonHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get spiritLevelButtonHold;

  /// No description provided for @spiritLevelButtonRelease.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get spiritLevelButtonRelease;

  /// No description provided for @spiritLevelButtonSetRef.
  ///
  /// In en, this message translates to:
  /// **'Set Reference'**
  String get spiritLevelButtonSetRef;

  /// No description provided for @spiritLevelLabelHeld.
  ///
  /// In en, this message translates to:
  /// **'HOLD'**
  String get spiritLevelLabelHeld;

  /// No description provided for @spiritLevelErrorNoSensor.
  ///
  /// In en, this message translates to:
  /// **'Accelerometer not available on this device'**
  String get spiritLevelErrorNoSensor;

  /// No description provided for @spiritLevelGimbalLockHint.
  ///
  /// In en, this message translates to:
  /// **'Rotate device to avoid gimbal lock'**
  String get spiritLevelGimbalLockHint;

  /// No description provided for @calibrationWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Calibration'**
  String get calibrationWizardTitle;

  /// No description provided for @calibrationWizardStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Lay device flat on a stable surface (face up) and tap Capture A.'**
  String get calibrationWizardStep1;

  /// No description provided for @calibrationWizardStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Rotate the device 180° horizontally on the same spot and tap Capture B.'**
  String get calibrationWizardStep2;

  /// No description provided for @calibrationWizardStep3.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Calculating calibration offset. Tap Finish to save.'**
  String get calibrationWizardStep3;

  /// No description provided for @calibrationWizardCaptureA.
  ///
  /// In en, this message translates to:
  /// **'Capture A'**
  String get calibrationWizardCaptureA;

  /// No description provided for @calibrationWizardCaptureB.
  ///
  /// In en, this message translates to:
  /// **'Capture B'**
  String get calibrationWizardCaptureB;

  /// No description provided for @calibrationWizardButtonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get calibrationWizardButtonFinish;

  /// No description provided for @calibrationWizardSuccess.
  ///
  /// In en, this message translates to:
  /// **'Calibration successful!'**
  String get calibrationWizardSuccess;

  /// No description provided for @calibrationWizardReset.
  ///
  /// In en, this message translates to:
  /// **'Reset Calibration'**
  String get calibrationWizardReset;

  /// No description provided for @commonUnitDegrees.
  ///
  /// In en, this message translates to:
  /// **'°'**
  String get commonUnitDegrees;

  /// No description provided for @commonUnitPercent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get commonUnitPercent;

  /// No description provided for @commonUnitMm.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get commonUnitMm;

  /// No description provided for @commonUnitCm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get commonUnitCm;

  /// No description provided for @commonUnitInch.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get commonUnitInch;

  /// No description provided for @commonUnitLux.
  ///
  /// In en, this message translates to:
  /// **'lx'**
  String get commonUnitLux;

  /// No description provided for @commonUnitFootCandle.
  ///
  /// In en, this message translates to:
  /// **'fc'**
  String get commonUnitFootCandle;

  /// No description provided for @commonUnitDecibel.
  ///
  /// In en, this message translates to:
  /// **'dB'**
  String get commonUnitDecibel;

  /// No description provided for @commonUnitMicrotesla.
  ///
  /// In en, this message translates to:
  /// **'µT'**
  String get commonUnitMicrotesla;

  /// No description provided for @commonUnitMetersPerSecSq.
  ///
  /// In en, this message translates to:
  /// **'m/s²'**
  String get commonUnitMetersPerSecSq;

  /// No description provided for @commonButtonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonButtonReset;

  /// No description provided for @commonButtonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonButtonCopy;

  /// No description provided for @commonButtonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonButtonClose;

  /// No description provided for @commonButtonOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get commonButtonOpenSettings;

  /// No description provided for @commonButtonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonButtonOpen;

  /// No description provided for @sensorErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Sensor Unavailable'**
  String get sensorErrorTitle;

  /// No description provided for @sensorErrorBody.
  ///
  /// In en, this message translates to:
  /// **'{sensorName} is not available on this device.'**
  String sensorErrorBody(String sensorName);

  /// No description provided for @permissionMicTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone Access'**
  String get permissionMicTitle;

  /// No description provided for @permissionMicBody.
  ///
  /// In en, this message translates to:
  /// **'Needed to measure sound levels'**
  String get permissionMicBody;

  /// No description provided for @permissionLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location Access'**
  String get permissionLocationTitle;

  /// No description provided for @permissionLocationBody.
  ///
  /// In en, this message translates to:
  /// **'Used once to compute magnetic declination for true north'**
  String get permissionLocationBody;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Access'**
  String get permissionCameraTitle;

  /// No description provided for @permissionCameraBody.
  ///
  /// In en, this message translates to:
  /// **'Used to estimate ambient light when sensor unavailable'**
  String get permissionCameraBody;

  /// No description provided for @permissionDeniedPermanentlyBody.
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. Open app settings to grant it.'**
  String get permissionDeniedPermanentlyBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsSectionDefaults.
  ///
  /// In en, this message translates to:
  /// **'Measurement Defaults'**
  String get settingsSectionDefaults;

  /// No description provided for @settingsSectionSensor.
  ///
  /// In en, this message translates to:
  /// **'Sensor & Calibration'**
  String get settingsSectionSensor;

  /// No description provided for @settingsSectionDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsSectionDisplay;

  /// No description provided for @settingsSectionPro.
  ///
  /// In en, this message translates to:
  /// **'Pro & Ads'**
  String get settingsSectionPro;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light (Coming Soon)'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System (Coming Soon)'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsKeepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep Screen On'**
  String get settingsKeepScreenOn;

  /// No description provided for @settingsProStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free — Ads Enabled'**
  String get settingsProStatusFree;

  /// No description provided for @settingsProStatusPro.
  ///
  /// In en, this message translates to:
  /// **'Pro — No Ads'**
  String get settingsProStatusPro;

  /// No description provided for @settingsProUpgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads — \$2.99'**
  String get settingsProUpgradeButton;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'10 Professional Tools'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'One app. Always offline.'**
  String get onboardingPage1Subtitle;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Industrial Feel'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Real precision, real materials.'**
  String get onboardingPage2Subtitle;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Calibrate for Accuracy'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the level and ruler once — they stay calibrated.'**
  String get onboardingPage3Subtitle;

  /// No description provided for @onboardingButtonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingButtonNext;

  /// No description provided for @onboardingButtonFinish.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingButtonFinish;

  /// No description provided for @compassAccuracyLow.
  ///
  /// In en, this message translates to:
  /// **'Low accuracy — calibrate sensor'**
  String get compassAccuracyLow;

  /// No description provided for @compassAccuracyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium accuracy'**
  String get compassAccuracyMedium;

  /// No description provided for @compassAccuracyHigh.
  ///
  /// In en, this message translates to:
  /// **'High accuracy'**
  String get compassAccuracyHigh;

  /// No description provided for @compassCalibrationHint.
  ///
  /// In en, this message translates to:
  /// **'Wave your phone in a figure-8 pattern'**
  String get compassCalibrationHint;

  /// No description provided for @compassInterferenceWarning.
  ///
  /// In en, this message translates to:
  /// **'Magnetic interference detected'**
  String get compassInterferenceWarning;

  /// No description provided for @compassLocked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get compassLocked;

  /// No description provided for @compassTrueNorthLabel.
  ///
  /// In en, this message translates to:
  /// **'True North'**
  String get compassTrueNorthLabel;

  /// No description provided for @compassDeclinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Declination'**
  String get compassDeclinationLabel;

  /// No description provided for @rulerUncalibratedWarning.
  ///
  /// In en, this message translates to:
  /// **'Ruler not calibrated — readings may be inaccurate'**
  String get rulerUncalibratedWarning;

  /// No description provided for @rulerCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Ruler'**
  String get rulerCalibrationTitle;

  /// No description provided for @rulerPresetCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card (85.6 mm)'**
  String get rulerPresetCreditCard;

  /// No description provided for @rulerPresetA4Width.
  ///
  /// In en, this message translates to:
  /// **'A4 Width (210 mm)'**
  String get rulerPresetA4Width;

  /// No description provided for @rulerPresetA4Height.
  ///
  /// In en, this message translates to:
  /// **'A4 Height (297 mm)'**
  String get rulerPresetA4Height;

  /// No description provided for @rulerPresetIdCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card (54 mm)'**
  String get rulerPresetIdCard;

  /// No description provided for @rulerPresetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom size'**
  String get rulerPresetCustom;

  /// No description provided for @rulerMarkerA.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get rulerMarkerA;

  /// No description provided for @rulerMarkerB.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get rulerMarkerB;

  /// No description provided for @metalDetectorWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Important Notice'**
  String get metalDetectorWarningTitle;

  /// No description provided for @metalDetectorFirstLaunchWarning.
  ///
  /// In en, this message translates to:
  /// **'Results may be affected by nearby electronics, speaker magnets, or metal tables.'**
  String get metalDetectorFirstLaunchWarning;

  /// No description provided for @metalDetectorRecalibrate.
  ///
  /// In en, this message translates to:
  /// **'Recalibrate'**
  String get metalDetectorRecalibrate;

  /// No description provided for @metalDetectorDetectionNone.
  ///
  /// In en, this message translates to:
  /// **'No metal detected'**
  String get metalDetectorDetectionNone;

  /// No description provided for @metalDetectorDetectionWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak signal'**
  String get metalDetectorDetectionWeak;

  /// No description provided for @metalDetectorDetectionMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium signal'**
  String get metalDetectorDetectionMedium;

  /// No description provided for @metalDetectorDetectionStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong signal'**
  String get metalDetectorDetectionStrong;

  /// No description provided for @metalDetectorDetectionVeryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very strong signal'**
  String get metalDetectorDetectionVeryStrong;

  /// No description provided for @soundMeterPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get soundMeterPeak;

  /// No description provided for @soundMeterAverage.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get soundMeterAverage;

  /// No description provided for @soundMeterMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get soundMeterMin;

  /// No description provided for @soundMeterZoneSilence.
  ///
  /// In en, this message translates to:
  /// **'Silence'**
  String get soundMeterZoneSilence;

  /// No description provided for @soundMeterZoneWhisper.
  ///
  /// In en, this message translates to:
  /// **'Whisper'**
  String get soundMeterZoneWhisper;

  /// No description provided for @soundMeterZoneConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get soundMeterZoneConversation;

  /// No description provided for @soundMeterZoneTraffic.
  ///
  /// In en, this message translates to:
  /// **'Traffic'**
  String get soundMeterZoneTraffic;

  /// No description provided for @soundMeterZoneLoud.
  ///
  /// In en, this message translates to:
  /// **'Loud'**
  String get soundMeterZoneLoud;

  /// No description provided for @soundMeterZoneDangerous.
  ///
  /// In en, this message translates to:
  /// **'Dangerous'**
  String get soundMeterZoneDangerous;

  /// No description provided for @soundMeterZoneJet.
  ///
  /// In en, this message translates to:
  /// **'Jet / Extreme'**
  String get soundMeterZoneJet;

  /// No description provided for @clinometerDirectionLeft.
  ///
  /// In en, this message translates to:
  /// **'Left side higher'**
  String get clinometerDirectionLeft;

  /// No description provided for @clinometerDirectionRight.
  ///
  /// In en, this message translates to:
  /// **'Right side higher'**
  String get clinometerDirectionRight;

  /// No description provided for @clinometerDirectionLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get clinometerDirectionLevel;

  /// No description provided for @clinometerGradeFlat.
  ///
  /// In en, this message translates to:
  /// **'Flat / Level'**
  String get clinometerGradeFlat;

  /// No description provided for @clinometerGradeDrainage.
  ///
  /// In en, this message translates to:
  /// **'Minimum drainage slope'**
  String get clinometerGradeDrainage;

  /// No description provided for @clinometerGradePedRamp.
  ///
  /// In en, this message translates to:
  /// **'Gentle pedestrian ramp'**
  String get clinometerGradePedRamp;

  /// No description provided for @clinometerGradeAda.
  ///
  /// In en, this message translates to:
  /// **'ADA/DDA max ramp'**
  String get clinometerGradeAda;

  /// No description provided for @clinometerGradeSteepRamp.
  ///
  /// In en, this message translates to:
  /// **'Steep ramp'**
  String get clinometerGradeSteepRamp;

  /// No description provided for @clinometerGradeSteepRoad.
  ///
  /// In en, this message translates to:
  /// **'Very steep road'**
  String get clinometerGradeSteepRoad;

  /// No description provided for @vibrationMeterPeak.
  ///
  /// In en, this message translates to:
  /// **'Peak Acceleration'**
  String get vibrationMeterPeak;

  /// No description provided for @vibrationMeterBaseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get vibrationMeterBaseline;

  /// No description provided for @vibrationMeterButtonCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrate Zero'**
  String get vibrationMeterButtonCalibrate;

  /// No description provided for @homeScreenInitializingSensors.
  ///
  /// In en, this message translates to:
  /// **'Initializing sensors...'**
  String get homeScreenInitializingSensors;

  /// No description provided for @sensorNameAccelerometer.
  ///
  /// In en, this message translates to:
  /// **'Accelerometer Sensor'**
  String get sensorNameAccelerometer;

  /// No description provided for @sensorNameMagnetometerGps.
  ///
  /// In en, this message translates to:
  /// **'Magnetometer & GPS'**
  String get sensorNameMagnetometerGps;

  /// No description provided for @sensorNameCalibratedDisplay.
  ///
  /// In en, this message translates to:
  /// **'Calibrated Display'**
  String get sensorNameCalibratedDisplay;

  /// No description provided for @sensorNameTouchInput.
  ///
  /// In en, this message translates to:
  /// **'Touch Input Scale'**
  String get sensorNameTouchInput;

  /// No description provided for @sensorNameMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Hardware Microphone'**
  String get sensorNameMicrophone;

  /// No description provided for @sensorNameLightCamera.
  ///
  /// In en, this message translates to:
  /// **'Light Sensor or Camera'**
  String get sensorNameLightCamera;

  /// No description provided for @sensorNameMagnetometer.
  ///
  /// In en, this message translates to:
  /// **'Magnetometer Sensor'**
  String get sensorNameMagnetometer;

  /// No description provided for @sensorNameConversionSolver.
  ///
  /// In en, this message translates to:
  /// **'Conversion Solver'**
  String get sensorNameConversionSolver;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get commonAllow;

  /// No description provided for @commonGrantAccess.
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get commonGrantAccess;

  /// No description provided for @permissionPermanentlyDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Blocked'**
  String get permissionPermanentlyDeniedTitle;

  /// No description provided for @permissionMicBodyDialog.
  ///
  /// In en, this message translates to:
  /// **'Levo needs access to your microphone to measure ambient noise levels in decibels.'**
  String get permissionMicBodyDialog;

  /// No description provided for @permissionMicDeniedPermanentlyBody.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission has been permanently denied. Please enable it in system settings to use the Sound Level Meter.'**
  String get permissionMicDeniedPermanentlyBody;

  /// No description provided for @permissionLocationBodyDialog.
  ///
  /// In en, this message translates to:
  /// **'Levo needs access to your location once to compute the local magnetic declination for true north.'**
  String get permissionLocationBodyDialog;

  /// No description provided for @permissionLocationDeniedPermanentlyBody.
  ///
  /// In en, this message translates to:
  /// **'Location permission has been permanently denied. Please enable it in system settings to compute True North offsets.'**
  String get permissionLocationDeniedPermanentlyBody;

  /// No description provided for @permissionCameraBodyDialog.
  ///
  /// In en, this message translates to:
  /// **'Levo needs access to your camera to estimate ambient light when the physical light sensor is unavailable.'**
  String get permissionCameraBodyDialog;

  /// No description provided for @permissionCameraDeniedPermanentlyBody.
  ///
  /// In en, this message translates to:
  /// **'Camera permission has been permanently denied. Please enable it in system settings to use light estimation.'**
  String get permissionCameraDeniedPermanentlyBody;

  /// No description provided for @rulerCalibrationBody.
  ///
  /// In en, this message translates to:
  /// **'Place a credit card or sheet edges between Handles A & B, then choose a preset below to calibrate.'**
  String get rulerCalibrationBody;

  /// No description provided for @rulerCalibrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ruler calibrated successfully'**
  String get rulerCalibrationSuccess;

  /// No description provided for @protractorButtonSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap (15°)'**
  String get protractorButtonSnap;

  /// No description provided for @protractorButtonReflex.
  ///
  /// In en, this message translates to:
  /// **'Reflex Angle'**
  String get protractorButtonReflex;

  /// No description provided for @spiritLevelLabelPitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get spiritLevelLabelPitch;

  /// No description provided for @spiritLevelLabelRoll.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get spiritLevelLabelRoll;

  /// No description provided for @spiritLevelLabelDeviation.
  ///
  /// In en, this message translates to:
  /// **'Deviation'**
  String get spiritLevelLabelDeviation;

  /// No description provided for @compassLabelHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get compassLabelHeading;

  /// No description provided for @compassLabelCardinal.
  ///
  /// In en, this message translates to:
  /// **'Cardinal'**
  String get compassLabelCardinal;

  /// No description provided for @compassLabelLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get compassLabelLock;

  /// No description provided for @compassLabelUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get compassLabelUnlock;

  /// No description provided for @settingsThemeDarkOnly.
  ///
  /// In en, this message translates to:
  /// **'(Dark only)'**
  String get settingsThemeDarkOnly;

  /// No description provided for @settingsResetCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Calibration'**
  String get settingsResetCalibrationTitle;

  /// No description provided for @settingsResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetButton;

  /// No description provided for @settingsSpiritLevelOffsets.
  ///
  /// In en, this message translates to:
  /// **'Spirit Level Offsets'**
  String get settingsSpiritLevelOffsets;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @compassDirections.
  ///
  /// In en, this message translates to:
  /// **'N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW'**
  String get compassDirections;

  /// No description provided for @settingsRulerCalibrationScale.
  ///
  /// In en, this message translates to:
  /// **'Ruler Calibration Scale'**
  String get settingsRulerCalibrationScale;

  /// No description provided for @settingsResetAllCalibration.
  ///
  /// In en, this message translates to:
  /// **'Reset All Calibration Data'**
  String get settingsResetAllCalibration;

  /// No description provided for @settingsOpenSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get settingsOpenSourceLicenses;

  /// No description provided for @settingsResetCalibrationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all stored calibration data?'**
  String get settingsResetCalibrationConfirm;

  /// No description provided for @settingsResetCalibrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Calibration data reset successfully'**
  String get settingsResetCalibrationSuccess;

  /// No description provided for @protractorVertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get protractorVertical;

  /// No description provided for @commonCopySuccess.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get commonCopySuccess;

  /// No description provided for @unitConverterLabelFrom.
  ///
  /// In en, this message translates to:
  /// **'CONVERT FROM'**
  String get unitConverterLabelFrom;

  /// No description provided for @unitConverterLabelTo.
  ///
  /// In en, this message translates to:
  /// **'CONVERT TO'**
  String get unitConverterLabelTo;

  /// No description provided for @unitConverterFromUnit.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get unitConverterFromUnit;

  /// No description provided for @unitConverterToUnit.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get unitConverterToUnit;

  /// No description provided for @settingsDefaultRulerUnit.
  ///
  /// In en, this message translates to:
  /// **'Default Ruler Unit'**
  String get settingsDefaultRulerUnit;

  /// No description provided for @settingsDefaultConverterCategory.
  ///
  /// In en, this message translates to:
  /// **'Default Converter Category'**
  String get settingsDefaultConverterCategory;

  /// No description provided for @spiritLevelViscosityLabel.
  ///
  /// In en, this message translates to:
  /// **'Viscosity (Damping)'**
  String get spiritLevelViscosityLabel;

  /// No description provided for @settingsSpiritLevelOffsetsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Pitch: {pitch}° | Roll: {roll}°'**
  String settingsSpiritLevelOffsetsDisplay(Object pitch, Object roll);

  /// No description provided for @settingsRulerCalibrationScaleDisplay.
  ///
  /// In en, this message translates to:
  /// **'Scale: {scale}x'**
  String settingsRulerCalibrationScaleDisplay(Object scale);

  /// No description provided for @settingsAppVersionBuildDisplay.
  ///
  /// In en, this message translates to:
  /// **'{version} (Build {build})'**
  String settingsAppVersionBuildDisplay(Object build, Object version);

  /// No description provided for @calibrationWizardSensorError.
  ///
  /// In en, this message translates to:
  /// **'Error reading sensors'**
  String get calibrationWizardSensorError;

  /// No description provided for @metalDetectorLabelMagneticDelta.
  ///
  /// In en, this message translates to:
  /// **'MAGNETIC DELTA'**
  String get metalDetectorLabelMagneticDelta;

  /// No description provided for @metalDetectorLabelAmbientBaseline.
  ///
  /// In en, this message translates to:
  /// **'AMBIENT BASELINE'**
  String get metalDetectorLabelAmbientBaseline;

  /// No description provided for @metalDetectorLabelSensitivity.
  ///
  /// In en, this message translates to:
  /// **'SENSITIVITY'**
  String get metalDetectorLabelSensitivity;

  /// No description provided for @metalDetectorSoundOn.
  ///
  /// In en, this message translates to:
  /// **'SOUND ON'**
  String get metalDetectorSoundOn;

  /// No description provided for @metalDetectorSoundMuted.
  ///
  /// In en, this message translates to:
  /// **'SOUND MUTED'**
  String get metalDetectorSoundMuted;

  /// No description provided for @metalDetectorHapticOn.
  ///
  /// In en, this message translates to:
  /// **'HAPTIC ON'**
  String get metalDetectorHapticOn;

  /// No description provided for @metalDetectorHapticMuted.
  ///
  /// In en, this message translates to:
  /// **'HAPTIC MUTED'**
  String get metalDetectorHapticMuted;

  /// No description provided for @metalDetectorSensitivityValue.
  ///
  /// In en, this message translates to:
  /// **'{value}x'**
  String metalDetectorSensitivityValue(String value);

  /// No description provided for @soundMeterLabelSpl.
  ///
  /// In en, this message translates to:
  /// **'SPL'**
  String get soundMeterLabelSpl;

  /// No description provided for @lightMeterLabelLuxDial.
  ///
  /// In en, this message translates to:
  /// **'LUX'**
  String get lightMeterLabelLuxDial;

  /// No description provided for @lightMeterUnitEv.
  ///
  /// In en, this message translates to:
  /// **'EV'**
  String get lightMeterUnitEv;

  /// No description provided for @lightMeterMaxDialLabel.
  ///
  /// In en, this message translates to:
  /// **'10K+'**
  String get lightMeterMaxDialLabel;

  /// No description provided for @lightMeterLabelEv100.
  ///
  /// In en, this message translates to:
  /// **'EXPOSURE VALUE (EV100)'**
  String get lightMeterLabelEv100;

  /// No description provided for @lightMeterLabelCameraViewport.
  ///
  /// In en, this message translates to:
  /// **'CAMERA VIEWPORT'**
  String get lightMeterLabelCameraViewport;

  /// No description provided for @lightMeterLabelHardwareSensor.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE SENSOR'**
  String get lightMeterLabelHardwareSensor;

  /// No description provided for @clinometerLabelSlopeAngle.
  ///
  /// In en, this message translates to:
  /// **'SLOPE ANGLE'**
  String get clinometerLabelSlopeAngle;

  /// No description provided for @clinometerLabelSlopeGrade.
  ///
  /// In en, this message translates to:
  /// **'SLOPE GRADE'**
  String get clinometerLabelSlopeGrade;

  /// No description provided for @rulerCalibrationReset.
  ///
  /// In en, this message translates to:
  /// **'Calibration reset'**
  String get rulerCalibrationReset;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
