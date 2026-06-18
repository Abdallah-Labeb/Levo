import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:levo/core/storage/preferences_service.dart';
import 'package:levo/core/sensors/sensor_availability_service.dart';
import 'package:levo/core/ads/ad_service.dart';

import 'package:levo/core/permissions/permission_service.dart';

import 'package:levo/features/settings/bloc/settings_cubit.dart';
import 'package:levo/features/home/bloc/sensor_availability_cubit.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_cubit.dart';
import 'package:levo/features/compass/bloc/compass_cubit.dart';
import 'package:levo/features/ruler/bloc/ruler_cubit.dart';
import 'package:levo/features/protractor/bloc/protractor_cubit.dart';
import 'package:levo/features/sound_meter/bloc/sound_meter_cubit.dart';
import 'package:levo/features/vibration_meter/bloc/vibration_meter_cubit.dart';
import 'package:levo/features/light_meter/bloc/light_meter_cubit.dart';
import 'package:levo/features/metal_detector/bloc/metal_detector_cubit.dart';
import 'package:levo/features/clinometer/bloc/clinometer_cubit.dart';
import 'package:levo/features/unit_converter/bloc/unit_converter_cubit.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Configures dependency injection containers for Levo.
Future<void> setupDependencies() async {
  // SharedPreferences Instance
  final sharedPreferences = await SharedPreferences.getInstance();

  // Core Services
  getIt.registerSingleton<PreferencesService>(
    PreferencesService(sharedPreferences),
  );

  getIt.registerSingleton<SensorAvailabilityService>(
    SensorAvailabilityService(),
  );

  getIt.registerSingleton<AdService>(AdService(getIt<PreferencesService>()));

  getIt.registerLazySingleton<PermissionService>(
    () => const PermissionService(),
  );

  // Feature Cubits
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(prefs: getIt<PreferencesService>()),
  );


  getIt.registerFactory<SensorAvailabilityCubit>(
    () => SensorAvailabilityCubit(
      sensorService: getIt<SensorAvailabilityService>(),
    ),
  );

  getIt.registerFactory<SpiritLevelCubit>(
    () => SpiritLevelCubit(prefs: getIt<PreferencesService>()),
  );

  getIt.registerFactory<CompassCubit>(
    () => CompassCubit(prefs: getIt<PreferencesService>()),
  );

  getIt.registerFactory<RulerCubit>(
    () => RulerCubit(prefs: getIt<PreferencesService>()),
  );

  getIt.registerFactory<ProtractorCubit>(
    () => ProtractorCubit(prefs: getIt<PreferencesService>()),
  );

  getIt.registerFactory<SoundMeterCubit>(() => SoundMeterCubit());

  getIt.registerFactory<VibrationMeterCubit>(() => VibrationMeterCubit());

  getIt.registerFactory<LightMeterCubit>(() => LightMeterCubit());

  getIt.registerFactory<MetalDetectorCubit>(() => MetalDetectorCubit());

  getIt.registerFactory<ClinometerCubit>(
    () => ClinometerCubit(prefs: getIt<PreferencesService>()),
  );

  getIt.registerFactory<UnitConverterCubit>(
    () => UnitConverterCubit(prefs: getIt<PreferencesService>()),
  );
}
