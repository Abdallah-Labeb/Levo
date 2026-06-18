import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/features/settings/bloc/settings_state.dart';

/// Manages loading, updating, and saving user configuration settings and in-app purchases.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required PreferencesService prefs})
    : _prefs = prefs,
      super(
        SettingsState(
          locale: prefs.languageCode != null
              ? Locale(prefs.languageCode!)
              : null,
          keepScreenOn: prefs.keepScreenOn,
          isPro: prefs.isPro,
          rulerDefaultUnit: prefs.rulerDefaultUnit,
          converterDefaultCategory: prefs.converterDefaultCategory,
        ),
      ) {
    _initIap();
    _loadPackageInfo();
  }

  final PreferencesService _prefs;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  void _initIap() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onError: (_) {
        // Safe fail in airplane/offline mode
      },
    );
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == 'levo_lifetime_pro') {
          setPro(true);
        }
        if (purchase.pendingCompletePurchase) {
          InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

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

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      emit(
        state.copyWith(
          appVersion: info.version,
          buildNumber: info.buildNumber,
        ),
      );
    } catch (_) {
      emit(state.copyWith(appVersion: '1.0.0', buildNumber: '1'));
    }
  }

  Future<void> setRulerDefaultUnit(String unit) async {
    await _prefs.setRulerDefaultUnit(unit);
    emit(state.copyWith(rulerDefaultUnit: unit));
  }

  Future<void> setConverterDefaultCategory(String category) async {
    await _prefs.setConverterDefaultCategory(category);
    emit(state.copyWith(converterDefaultCategory: category));
  }

  /// Triggers standard in-app purchase flow for lifetime Pro tier.
  /// Falls back to direct unlock in offline or simulation environments.
  Future<void> upgradeToPro() async {
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        // Fallback for offline/airplane mode/simulators
        await setPro(true);
        return;
      }

      const Set<String> kIds = <String>{'levo_lifetime_pro'};
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails(kIds);

      if (response.notFoundIDs.contains('levo_lifetime_pro') ||
          response.productDetails.isEmpty) {
        // Fallback if product ID not active in Play/App store console yet
        await setPro(true);
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (_) {
      // General safety fallback
      await setPro(true);
    }
  }

  /// Restores previous premium purchase details.
  Future<void> restorePurchases() async {
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (available) {
        await InAppPurchase.instance.restorePurchases();
      }
    } catch (_) {
      // Safe fail
    }
  }

  @override
  Future<void> close() async {
    await _purchaseSubscription?.cancel();
    return super.close();
  }
}
