// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Levo';

  @override
  String get homeScreenTitle => 'Levo';

  @override
  String get homeScreenSubtitle => 'Professional Measurement Toolkit';

  @override
  String get spiritLevelTitle => 'Spirit Level';

  @override
  String get spiritLevelDesc => '2D/1D bubble level';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassDesc => 'Tilt-compensated magnetic compass';

  @override
  String get rulerTitle => 'Digital Ruler';

  @override
  String get rulerDesc => 'Measure objects using your screen scale';

  @override
  String get protractorTitle => 'Protractor';

  @override
  String get protractorDesc => 'Measure angles drawn on screen';

  @override
  String get protractorLabelAngle => 'Angle';

  @override
  String get protractorLabelSlopeGrade => 'Slope Grade';

  @override
  String get soundMeterTitle => 'Sound Level Meter';

  @override
  String get soundMeterDesc => 'Measure ambient noise in decibels';

  @override
  String get vibrationMeterTitle => 'Vibration Meter';

  @override
  String get vibrationMeterDesc => 'Plot real-time vibration seismograph';

  @override
  String get lightMeterTitle => 'Light Meter';

  @override
  String get lightMeterDesc => 'Measure illuminance in Lux';

  @override
  String get lightMeterSceneDark => 'Pitch Black / Night';

  @override
  String get lightMeterSceneDim => 'Dim Indoors / Living Room';

  @override
  String get lightMeterSceneNormal => 'Normal Indoors / Office';

  @override
  String get lightMeterSceneBright => 'Bright Indoors / Overcast Day';

  @override
  String get lightMeterSceneSunlight => 'Direct Sunlight';

  @override
  String get metalDetectorTitle => 'Metal Detector';

  @override
  String get metalDetectorDesc => 'Detect magnetic field strength';

  @override
  String get unitConverterTitle => 'Unit Converter';

  @override
  String get unitConverterDesc => 'Convert construction-related units';

  @override
  String get unitCategoryLength => 'Length';

  @override
  String get unitCategoryArea => 'Area';

  @override
  String get unitCategoryVolume => 'Volume';

  @override
  String get unitCategoryMass => 'Mass';

  @override
  String get unitCategorySpeed => 'Speed';

  @override
  String get unitCategoryPressure => 'Pressure';

  @override
  String get unitCategoryAngle => 'Angle';

  @override
  String get clinometerTitle => 'Clinometer';

  @override
  String get clinometerDesc => 'Measure slope angle and grade';

  @override
  String get spiritLevelModeFlat => '2D Surface';

  @override
  String get spiritLevelModeEdge => '1D Edge';

  @override
  String get spiritLevelButtonCalibrate => 'Calibrate';

  @override
  String get spiritLevelButtonHold => 'Hold';

  @override
  String get spiritLevelButtonRelease => 'Release';

  @override
  String get spiritLevelButtonSetRef => 'Set Reference';

  @override
  String get spiritLevelLabelHeld => 'HOLD';

  @override
  String get spiritLevelErrorNoSensor =>
      'Accelerometer not available on this device';

  @override
  String get spiritLevelGimbalLockHint => 'Rotate device to avoid gimbal lock';

  @override
  String get calibrationWizardTitle => 'Level Calibration';

  @override
  String get calibrationWizardStep1 =>
      'Step 1: Lay device flat on a stable surface (face up) and tap Capture A.';

  @override
  String get calibrationWizardStep2 =>
      'Step 2: Rotate the device 180° horizontally on the same spot and tap Capture B.';

  @override
  String get calibrationWizardStep3 =>
      'Step 3: Calculating calibration offset. Tap Finish to save.';

  @override
  String get calibrationWizardCaptureA => 'Capture A';

  @override
  String get calibrationWizardCaptureB => 'Capture B';

  @override
  String get calibrationWizardButtonFinish => 'Finish';

  @override
  String get calibrationWizardSuccess => 'Calibration successful!';

  @override
  String get calibrationWizardReset => 'Reset Calibration';

  @override
  String get commonUnitDegrees => '°';

  @override
  String get commonUnitPercent => '%';

  @override
  String get commonUnitMm => 'mm';

  @override
  String get commonUnitCm => 'cm';

  @override
  String get commonUnitInch => 'in';

  @override
  String get commonUnitLux => 'lx';

  @override
  String get commonUnitFootCandle => 'fc';

  @override
  String get commonUnitDecibel => 'dB';

  @override
  String get commonUnitMicrotesla => 'µT';

  @override
  String get commonUnitMetersPerSecSq => 'm/s²';

  @override
  String get commonButtonReset => 'Reset';

  @override
  String get commonButtonCopy => 'Copy';

  @override
  String get commonButtonClose => 'Close';

  @override
  String get commonButtonOpenSettings => 'Open Settings';

  @override
  String get commonButtonOpen => 'Open';

  @override
  String get sensorErrorTitle => 'Sensor Unavailable';

  @override
  String sensorErrorBody(String sensorName) {
    return '$sensorName is not available on this device.';
  }

  @override
  String get permissionMicTitle => 'Microphone Access';

  @override
  String get permissionMicBody => 'Needed to measure sound levels';

  @override
  String get permissionLocationTitle => 'Location Access';

  @override
  String get permissionLocationBody =>
      'Used once to compute magnetic declination for true north';

  @override
  String get permissionCameraTitle => 'Camera Access';

  @override
  String get permissionCameraBody =>
      'Used to estimate ambient light when sensor unavailable';

  @override
  String get permissionDeniedPermanentlyBody =>
      'Permission permanently denied. Open app settings to grant it.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsSectionDefaults => 'Measurement Defaults';

  @override
  String get settingsSectionSensor => 'Sensor & Calibration';

  @override
  String get settingsSectionDisplay => 'Display';

  @override
  String get settingsSectionPro => 'Pro & Ads';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light (Coming Soon)';

  @override
  String get settingsThemeSystem => 'System (Coming Soon)';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageSystem => 'System Default';

  @override
  String get settingsKeepScreenOn => 'Keep Screen On';

  @override
  String get settingsProStatusFree => 'Free — Ads Enabled';

  @override
  String get settingsProStatusPro => 'Pro — No Ads';

  @override
  String get settingsProUpgradeButton => 'Remove Ads — \$2.99';

  @override
  String get onboardingPage1Title => '10 Professional Tools';

  @override
  String get onboardingPage1Subtitle => 'One app. Always offline.';

  @override
  String get onboardingPage2Title => 'Industrial Feel';

  @override
  String get onboardingPage2Subtitle => 'Real precision, real materials.';

  @override
  String get onboardingPage3Title => 'Calibrate for Accuracy';

  @override
  String get onboardingPage3Subtitle =>
      'Set up the level and ruler once — they stay calibrated.';

  @override
  String get onboardingButtonNext => 'Next';

  @override
  String get onboardingButtonFinish => 'Get Started';

  @override
  String get compassAccuracyLow => 'Low accuracy — calibrate sensor';

  @override
  String get compassAccuracyMedium => 'Medium accuracy';

  @override
  String get compassAccuracyHigh => 'High accuracy';

  @override
  String get compassCalibrationHint => 'Wave your phone in a figure-8 pattern';

  @override
  String get compassInterferenceWarning => 'Magnetic interference detected';

  @override
  String get compassLocked => 'LOCKED';

  @override
  String get compassTrueNorthLabel => 'True North';

  @override
  String get compassDeclinationLabel => 'Declination';

  @override
  String get rulerUncalibratedWarning =>
      'Ruler not calibrated — readings may be inaccurate';

  @override
  String get rulerCalibrationTitle => 'Calibrate Ruler';

  @override
  String get rulerPresetCreditCard => 'Credit Card (85.6 mm)';

  @override
  String get rulerPresetA4Width => 'A4 Width (210 mm)';

  @override
  String get rulerPresetA4Height => 'A4 Height (297 mm)';

  @override
  String get rulerPresetIdCard => 'ID Card (54 mm)';

  @override
  String get rulerPresetCustom => 'Custom size';

  @override
  String get rulerMarkerA => 'A';

  @override
  String get rulerMarkerB => 'B';

  @override
  String get metalDetectorWarningTitle => 'Important Notice';

  @override
  String get metalDetectorFirstLaunchWarning =>
      'Results may be affected by nearby electronics, speaker magnets, or metal tables.';

  @override
  String get metalDetectorRecalibrate => 'Recalibrate';

  @override
  String get metalDetectorDetectionNone => 'No metal detected';

  @override
  String get metalDetectorDetectionWeak => 'Weak signal';

  @override
  String get metalDetectorDetectionMedium => 'Medium signal';

  @override
  String get metalDetectorDetectionStrong => 'Strong signal';

  @override
  String get metalDetectorDetectionVeryStrong => 'Very strong signal';

  @override
  String get soundMeterPeak => 'Peak';

  @override
  String get soundMeterAverage => 'Avg';

  @override
  String get soundMeterMin => 'Min';

  @override
  String get soundMeterZoneSilence => 'Silence';

  @override
  String get soundMeterZoneWhisper => 'Whisper';

  @override
  String get soundMeterZoneConversation => 'Conversation';

  @override
  String get soundMeterZoneTraffic => 'Traffic';

  @override
  String get soundMeterZoneLoud => 'Loud';

  @override
  String get soundMeterZoneDangerous => 'Dangerous';

  @override
  String get soundMeterZoneJet => 'Jet / Extreme';

  @override
  String get clinometerDirectionLeft => 'Left side higher';

  @override
  String get clinometerDirectionRight => 'Right side higher';

  @override
  String get clinometerDirectionLevel => 'Level';

  @override
  String get clinometerGradeFlat => 'Flat / Level';

  @override
  String get clinometerGradeDrainage => 'Minimum drainage slope';

  @override
  String get clinometerGradePedRamp => 'Gentle pedestrian ramp';

  @override
  String get clinometerGradeAda => 'ADA/DDA max ramp';

  @override
  String get clinometerGradeSteepRamp => 'Steep ramp';

  @override
  String get clinometerGradeSteepRoad => 'Very steep road';

  @override
  String get vibrationMeterPeak => 'Peak Acceleration';

  @override
  String get vibrationMeterBaseline => 'Baseline';

  @override
  String get vibrationMeterButtonCalibrate => 'Calibrate Zero';

  @override
  String get homeScreenInitializingSensors => 'Initializing sensors...';

  @override
  String get sensorNameAccelerometer => 'Accelerometer Sensor';

  @override
  String get sensorNameMagnetometerGps => 'Magnetometer & GPS';

  @override
  String get sensorNameCalibratedDisplay => 'Calibrated Display';

  @override
  String get sensorNameTouchInput => 'Touch Input Scale';

  @override
  String get sensorNameMicrophone => 'Hardware Microphone';

  @override
  String get sensorNameLightCamera => 'Light Sensor or Camera';

  @override
  String get sensorNameMagnetometer => 'Magnetometer Sensor';

  @override
  String get sensorNameConversionSolver => 'Conversion Solver';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAllow => 'Allow';

  @override
  String get commonGrantAccess => 'Grant Access';

  @override
  String get permissionPermanentlyDeniedTitle => 'Permission Blocked';

  @override
  String get permissionMicBodyDialog =>
      'Levo needs access to your microphone to measure ambient noise levels in decibels.';

  @override
  String get permissionMicDeniedPermanentlyBody =>
      'Microphone permission has been permanently denied. Please enable it in system settings to use the Sound Level Meter.';

  @override
  String get permissionLocationBodyDialog =>
      'Levo needs access to your location once to compute the local magnetic declination for true north.';

  @override
  String get permissionLocationDeniedPermanentlyBody =>
      'Location permission has been permanently denied. Please enable it in system settings to compute True North offsets.';

  @override
  String get permissionCameraBodyDialog =>
      'Levo needs access to your camera to estimate ambient light when the physical light sensor is unavailable.';

  @override
  String get permissionCameraDeniedPermanentlyBody =>
      'Camera permission has been permanently denied. Please enable it in system settings to use light estimation.';

  @override
  String get rulerCalibrationBody =>
      'Place a credit card or sheet edges between Handles A & B, then choose a preset below to calibrate.';

  @override
  String get rulerCalibrationSuccess => 'Ruler calibrated successfully';

  @override
  String get protractorButtonSnap => 'Snap (15°)';

  @override
  String get protractorButtonReflex => 'Reflex Angle';

  @override
  String get spiritLevelLabelPitch => 'Pitch';

  @override
  String get spiritLevelLabelRoll => 'Roll';

  @override
  String get spiritLevelLabelDeviation => 'Deviation';

  @override
  String get compassLabelHeading => 'Heading';

  @override
  String get compassLabelCardinal => 'Cardinal';

  @override
  String get compassLabelLock => 'Lock';

  @override
  String get compassLabelUnlock => 'Unlock';

  @override
  String get settingsThemeDarkOnly => '(Dark only)';

  @override
  String get settingsResetCalibrationTitle => 'Reset Calibration';

  @override
  String get settingsResetButton => 'Reset';

  @override
  String get settingsSpiritLevelOffsets => 'Spirit Level Offsets';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get compassDirections =>
      'N,NNE,NE,ENE,E,ESE,SE,SSE,S,SSW,SW,WSW,W,WNW,NW,NNW';

  @override
  String get settingsRulerCalibrationScale => 'Ruler Calibration Scale';

  @override
  String get settingsResetAllCalibration => 'Reset All Calibration Data';

  @override
  String get settingsOpenSourceLicenses => 'Open Source Licenses';

  @override
  String get settingsResetCalibrationConfirm =>
      'Are you sure you want to clear all stored calibration data?';

  @override
  String get settingsResetCalibrationSuccess =>
      'Calibration data reset successfully';

  @override
  String get protractorVertical => 'Vertical';

  @override
  String get commonCopySuccess => 'Copied to clipboard!';

  @override
  String get unitConverterLabelFrom => 'CONVERT FROM';

  @override
  String get unitConverterLabelTo => 'CONVERT TO';

  @override
  String get unitConverterFromUnit => 'From';

  @override
  String get unitConverterToUnit => 'To';

  @override
  String get settingsDefaultRulerUnit => 'Default Ruler Unit';

  @override
  String get settingsDefaultConverterCategory => 'Default Converter Category';

  @override
  String get spiritLevelViscosityLabel => 'Viscosity (Damping)';

  @override
  String settingsSpiritLevelOffsetsDisplay(Object pitch, Object roll) {
    return 'Pitch: $pitch° | Roll: $roll°';
  }

  @override
  String settingsRulerCalibrationScaleDisplay(Object scale) {
    return 'Scale: ${scale}x';
  }

  @override
  String settingsAppVersionBuildDisplay(Object build, Object version) {
    return '$version (Build $build)';
  }

  @override
  String get calibrationWizardSensorError => 'Error reading sensors';

  @override
  String get metalDetectorLabelMagneticDelta => 'MAGNETIC DELTA';

  @override
  String get metalDetectorLabelAmbientBaseline => 'AMBIENT BASELINE';

  @override
  String get metalDetectorLabelSensitivity => 'SENSITIVITY';

  @override
  String get metalDetectorSoundOn => 'SOUND ON';

  @override
  String get metalDetectorSoundMuted => 'SOUND MUTED';

  @override
  String get metalDetectorHapticOn => 'HAPTIC ON';

  @override
  String get metalDetectorHapticMuted => 'HAPTIC MUTED';

  @override
  String metalDetectorSensitivityValue(String value) {
    return '${value}x';
  }

  @override
  String get soundMeterLabelSpl => 'SPL';

  @override
  String get lightMeterLabelLuxDial => 'LUX';

  @override
  String get lightMeterUnitEv => 'EV';

  @override
  String get lightMeterMaxDialLabel => '10K+';

  @override
  String get lightMeterLabelEv100 => 'EXPOSURE VALUE (EV100)';

  @override
  String get lightMeterLabelCameraViewport => 'CAMERA VIEWPORT';

  @override
  String get lightMeterLabelHardwareSensor => 'HARDWARE SENSOR';

  @override
  String get clinometerLabelSlopeAngle => 'SLOPE ANGLE';

  @override
  String get clinometerLabelSlopeGrade => 'SLOPE GRADE';

  @override
  String get rulerCalibrationReset => 'Calibration reset';

  @override
  String get settingsSpiritLevelCalibrateTitle => 'Spirit Level Calibration';

  @override
  String get settingsSpiritLevelCalibrateDesc =>
      'Calibrates the internal accelerometer to define absolute flat (0.0°). This offsets slight hardware manufacturing variations.';

  @override
  String get settingsSpiritLevelCalibrateHow =>
      'How to Calibrate: Lay the device on a steady surface and tap \'Start\'. Rotate the device 180° on the same spot when prompted to capture the second reading.';

  @override
  String get settingsSpiritLevelCalibrateBtn => 'Start Calibration Wizard';

  @override
  String get settingsSpiritLevelResetBtn => 'Reset Spirit Level Calibration';

  @override
  String get settingsSpiritLevelResetSuccess =>
      'Spirit level calibration reset successfully';

  @override
  String get protractorModeManual => 'Manual';

  @override
  String get protractorModeCamera => 'Camera';

  @override
  String get protractorModeImage => 'Image';

  @override
  String get protractorButtonLock => 'Lock Handles';

  @override
  String get protractorButtonUnlock => 'Unlock Handles';

  @override
  String get protractorSnapInterval => 'Snap Interval';

  @override
  String get protractorCameraDenied =>
      'Camera access is required for live measurement background.';

  @override
  String get protractorSelectImage => 'Select Image';

  @override
  String get protractorRemoveImage => 'Remove Image';

  @override
  String get protractorVertexHint =>
      'Drag Center Peg to adjust vertex position';

  @override
  String get protractorArmA => 'Arm A';

  @override
  String get protractorArmB => 'Arm B';

  @override
  String get protractorPreciseAdjustment => 'Fine Tuning';

  @override
  String get clinometerHelpInstructions =>
      'Place device side edge or back flat on the slope';
}
