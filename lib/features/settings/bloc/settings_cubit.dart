import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/settings/bloc/settings_state.dart';

/// Manages loading, updating, and saving user configuration settings.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required PreferencesService prefs,
  })  : _prefs = prefs,
        super(SettingsState(
          locale: prefs.languageCode != null ? Locale(prefs.languageCode!) : null,
          keepScreenOn: prefs.keepScreenOn,
          isPro: prefs.isPro,
        ));

  final PreferencesService _prefs;

  /// Toggles whether the device screen should stay on during measurements.
  Future<void> toggleKeepScreenOn(bool value) async {
    await _prefs.setKeepScreenOn(value);
    emit(state.copyWith(keepScreenOn: value));
  }

  /// Sets the application UI language locale (English, Arabic, or System).
  Future<void> setLocale(Locale? locale) async {
    await _prefs.setLanguageCode(locale?.languageCode);
    if (locale == null) {
      emit(state.copyWith(clearLocale: true));
    } else {
      emit(state.copyWith(locale: locale));
    }
  }

  /// Updates user Premium (Pro) purchase status and saves locally.
  Future<void> setPro(bool value) async {
    await _prefs.setIsPro(value);
    emit(state.copyWith(isPro: value));
  }
}
