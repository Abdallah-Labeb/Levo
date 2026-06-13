import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:levo/features/light_meter/bloc/light_meter_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LightMeterCubit cubit;
  bool isCameraPermissionGranted = false;

  setUp(() {
    // Mock PermissionHandler platform channel
    const MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'checkPermissionStatus') {
        return isCameraPermissionGranted ? 1 : 0; // Granted or Denied
      }
      if (methodCall.method == 'requestPermissions') {
        return {
          1: isCameraPermissionGranted ? 1 : 0, // Camera (1)
        };
      }
      return null;
    });

    cubit = LightMeterCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('LightMeterCubit Unit Tests', () {
    test('Initial state reflects default values', () {
      expect(cubit.state.lux, 0.0);
      expect(cubit.state.exposureValue, 0.0);
      expect(cubit.state.scene, isEmpty);
      expect(cubit.state.isCameraFallback, false);
      expect(cubit.state.isSensorAvailable, true);
      expect(cubit.state.cameraPermissionGranted, false);
      expect(cubit.state.isCameraInitialized, false);
      expect(cubit.state.errorMessage, isNull);
    });

    test(
      'checkCameraPermission returns false when permission denied',
      () async {
        isCameraPermissionGranted = false;
        await cubit.checkCameraPermission();
        expect(cubit.state.cameraPermissionGranted, false);
        expect(cubit.state.isCameraInitialized, false);
      },
    );

    test('requestCameraPermission requests permissions correctly', () async {
      isCameraPermissionGranted = true;
      await cubit.requestCameraPermission();
      expect(cubit.state.cameraPermissionGranted, true);
    });
  });
}
