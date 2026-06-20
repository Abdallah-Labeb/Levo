import 'package:flutter_test/flutter_test.dart';
import 'package:levo/features/protractor/bloc/protractor_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProtractorCubit cubit;

  setUp(() {
    cubit = ProtractorCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('ProtractorCubit Unit Tests', () {
    test('Initial state loading', () {
      expect(cubit.state.angleA, 0.0);
      expect(cubit.state.angleB, 45.0);
      expect(cubit.state.centerPercentX, 0.5);
      expect(cubit.state.centerPercentY, 0.5);
      expect(cubit.state.measuredAngle, 45.0);
    });

    test('updateAngleA and updateAngleB snap values to whole degrees', () {
      cubit.updateAngleA(11.2);
      expect(cubit.state.angleA, 11.0);

      cubit.updateAngleB(42.6);
      expect(cubit.state.angleB, 43.0);
    });

    test('updateCenter updates custom vertex coords', () {
      cubit.updateCenter(0.2, 0.8);
      expect(cubit.state.centerPercentX, 0.2);
      expect(cubit.state.centerPercentY, 0.8);
    });

    test('reset restores default angles and center', () {
      cubit.updateAngleA(99.4);
      cubit.updateCenter(0.1, 0.1);
      expect(cubit.state.angleA, 99.0);

      cubit.reset();
      expect(cubit.state.angleA, 0.0);
      expect(cubit.state.angleB, 45.0);
      expect(cubit.state.centerPercentX, 0.5);
      expect(cubit.state.centerPercentY, 0.5);
    });
  });
}
