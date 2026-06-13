import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levo/app/di/injection.dart';
import 'package:levo/app/router/app_router.dart';
import 'package:levo/app/theme/app_theme.dart';
import 'package:levo/features/settings/bloc/settings_cubit.dart';
import 'package:levo/features/settings/bloc/settings_state.dart';
import 'package:levo/l10n/generated/app_localizations.dart';

import 'package:levo/core/widgets/noise_texture_helper.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator and core dependencies
  await setupDependencies();

  // Pregenerate skeuomorphic noise background shader
  await NoiseTextureHelper.pregenerateNoise();

  runApp(const LevoApp());
}

/// Root widget of the Levo application.
/// Injects the global [SettingsCubit] to dynamicize locale and WakeLock updates.
class LevoApp extends StatelessWidget {
  const LevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => getIt<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'Levo',
            routerConfig: appRouter,

            // Localization setups
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: settings.locale,

            // Themes and layout rules
            theme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
