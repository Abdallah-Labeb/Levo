import 'package:flutter_test/flutter_test.dart';
import 'package:levo/features/vibration_meter/bloc/vibration_meter_cubit.dart';
import 'package:levo/features/vibration_meter/bloc/vibration_meter_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late VibrationMeterCubit cubit;

  setUp(() {
    cubit = VibrationMeterCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('VibrationMeterCubit Unit Tests', () {
    test('Initial state reflects defaults', () {
      expect(cubit.state.samples, isEmpty);
      expect(cubit.state.peak, 0.0);
      expect(cubit.state.baseline, 0.0);
      expect(cubit.state.isSensorAvailable, true);
      expect(cubit.state.errorMessage, isNull);
    });

    test('reset clears state values to defaults', () {
      final customCubit = TestVibrationMeterCubit();
      customCubit.emitState(
        const VibrationMeterState(
          samples: [0.1, 0.2, 0.3],
          peak: 0.3,
          baseline: 0.05,
        ),
      );

      customCubit.reset();
      expect(customCubit.state.samples, isEmpty);
      expect(customCubit.state.peak, 0.0);
      expect(customCubit.state.baseline, 0.0);
      customCubit.close();
    });

    test('calibrateBaseline averages last 15 samples and updates baseline', () {
      final customCubit = TestVibrationMeterCubit();
      final samples = List.generate(
        20,
        (index) => (index + 1) * 0.1,
      ); // 0.1 to 2.0
      // last 15 samples: 0.6 to 2.0. Average of 0.6 to 2.0 is (0.6 + 2.0)/2 = 1.3
      customCubit.emitState(
        VibrationMeterState(samples: samples, peak: 1.5, baseline: 0.5),
      );

      customCubit.calibrateBaseline();

      // New baseline should be oldBaseline + averageOffset = 0.5 + 1.3 = 1.8
      expect(customCubit.state.baseline, closeTo(1.8, 0.0001));
      // Peak should be reset to 0.0
      expect(customCubit.state.peak, 0.0);

      customCubit.close();
    });

    test('calibrateBaseline does nothing if samples are empty', () {
      cubit.calibrateBaseline();
      expect(cubit.state.baseline, 0.0);
    });
  });
}

/// A testable subclass of VibrationMeterCubit to allow emitting custom states for unit testing.
class TestVibrationMeterCubit extends VibrationMeterCubit {
  void emitState(VibrationMeterState state) => emit(state);
}
