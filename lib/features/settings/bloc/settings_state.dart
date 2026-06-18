import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State representation for Levo application settings.
class SettingsState extends Equatable {
  const SettingsState({
    this.locale,
    required this.keepScreenOn,
    required this.isPro,
    this.rulerDefaultUnit = 'mm',
    this.converterDefaultCategory = 'length',
    this.appVersion = '',
    this.buildNumber = '',
  });

  /// The active app locale (null defaults to system locale).
  final Locale? locale;

  /// Whether the screen should stay on (WakeLock).
  final bool keepScreenOn;

  /// Whether the user has unlocked Premium (Pro) features.
  final bool isPro;

  /// Default unit for the ruler.
  final String rulerDefaultUnit;

  /// Default category for the unit converter.
  final String converterDefaultCategory;

  /// Stored app version.
  final String appVersion;

  /// Stored build number.
  final String buildNumber;

  @override
  List<Object?> get props => [
    locale,
    keepScreenOn,
    isPro,
    rulerDefaultUnit,
    converterDefaultCategory,
    appVersion,
    buildNumber,
  ];

  SettingsState copyWith({
    Locale? locale,
    bool? keepScreenOn,
    bool? isPro,
    String? rulerDefaultUnit,
    String? converterDefaultCategory,
    String? appVersion,
    String? buildNumber,
    bool clearLocale = false,
  }) {
    return SettingsState(
      locale: clearLocale ? null : (locale ?? this.locale),
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      isPro: isPro ?? this.isPro,
      rulerDefaultUnit: rulerDefaultUnit ?? this.rulerDefaultUnit,
      converterDefaultCategory:
          converterDefaultCategory ?? this.converterDefaultCategory,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }
}
