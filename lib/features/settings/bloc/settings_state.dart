import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State representation for Levo application settings.
class SettingsState extends Equatable {
  const SettingsState({
    this.locale,
    required this.keepScreenOn,
    required this.isPro,
  });

  /// The active app locale (null defaults to system locale).
  final Locale? locale;

  /// Whether the screen should stay on (WakeLock).
  final bool keepScreenOn;

  /// Whether the user has unlocked Premium (Pro) features.
  final bool isPro;

  @override
  List<Object?> get props => [locale, keepScreenOn, isPro];

  SettingsState copyWith({
    Locale? locale,
    bool? keepScreenOn,
    bool? isPro,
    bool clearLocale = false,
  }) {
    return SettingsState(
      locale: clearLocale ? null : (locale ?? this.locale),
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      isPro: isPro ?? this.isPro,
    );
  }
}
