import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/metal_panel.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/core/widgets/levo_banner.dart';
import 'package:levo/l10n/l10n_extension.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_cubit.dart';

/// Interactive 3-step Wizard to calibrate the Spirit Level.
/// Utilizes a 180° rotation technique to compute true sensor zero references.
class CalibrationWizard extends StatefulWidget {
  const CalibrationWizard({
    super.key,
    required this.cubit,
  });

  final SpiritLevelCubit cubit;

  @override
  State<CalibrationWizard> createState() => _CalibrationWizardState();
}

class _CalibrationWizardState extends State<CalibrationWizard> {
  int _step = 1; // 1 = Capture A, 2 = Capture B, 3 = Calculate/Done
  bool _isCapturing = false;
  int _capturedCount = 0;
  
  // Accumulated raw angles for averaging
  double _pitchSum = 0.0;
  double _rollSum = 0.0;

  // Captured points
  double? _pitchA;
  double? _rollA;
  double? _pitchB;
  double? _rollB;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  void _startCapture(VoidCallback onDone) {
    _accelSub?.cancel();
    setState(() {
      _isCapturing = true;
      _capturedCount = 0;
      _pitchSum = 0.0;
      _rollSum = 0.0;
    });

    // Capture 20 samples to filter out hand tremors and stabilize readings
    const int targetSamplesCount = 20;

    _accelSub = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      final double rawPitch = math.atan2(
            -event.x,
            math.sqrt(event.y * event.y + event.z * event.z),
          ) *
          (180.0 / math.pi);

      final double rawRoll = math.atan2(event.y, event.z) * (180.0 / math.pi);

      _pitchSum += rawPitch;
      _rollSum += rawRoll;
      _capturedCount++;

      if (_capturedCount >= targetSamplesCount) {
        _accelSub?.cancel();
        setState(() {
          _isCapturing = false;
        });
        onDone();
      }
    }, onError: (_) {
      _accelSub?.cancel();
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        LevoBanner.show(
          context,
          message: "Error reading sensors",
          type: LevoBannerType.error,
        );
      }
    });
  }

  void _onCaptureA() {
    _startCapture(() {
      _pitchA = _pitchSum / _capturedCount;
      _rollA = _rollSum / _capturedCount;
      setState(() {
        _step = 2;
      });
    });
  }

  void _onCaptureB() {
    _startCapture(() {
      _pitchB = _pitchSum / _capturedCount;
      _rollB = _rollSum / _capturedCount;

      // Calculate calibration offsets
      final double finalOffsetPitch = (_pitchA! + _pitchB!) / 2.0;
      final double finalOffsetRoll = (_rollA! + _rollB!) / 2.0;

      // Save calibration parameters to cubit (Preferences)
      widget.cubit.saveCalibration(finalOffsetPitch, finalOffsetRoll);

      setState(() {
        _step = 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAr = Directionality.of(context) == TextDirection.rtl;

    return MetalPanel(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.calibrationWizardTitle,
                style: AppTypography.kTitleL,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.kChromeLight),
                onPressed: () {
                  _accelSub?.cancel();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),
          // Illustration / Step view area
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.kSurfaceInset,
              borderRadius: BorderRadius.circular(AppDimensions.radiusDisplay),
              border: Border.all(color: AppColors.kDivider),
            ),
            child: Center(
              child: _buildStepIcon(),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          // Text Instructions
          Text(
            _getStepInstructions(l10n),
            style: AppTypography.kBody.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space24),
          // Progress Loader / Button Row
          if (_isCapturing) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.kYellow),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_step < 3)
                  TextButton(
                    onPressed: () {
                      _accelSub?.cancel();
                      Navigator.pop(context);
                    },
                    child: Text(
                      isAr ? "إلغاء" : "Cancel",
                      style: const TextStyle(color: AppColors.kChromeLight),
                    ),
                  ),
                const SizedBox(width: AppDimensions.space12),
                _buildActionButton(l10n),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIcon() {
    switch (_step) {
      case 1:
        return const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.phone_android, size: 64, color: AppColors.kChromeMid),
            Positioned(
              bottom: 20,
              child: Icon(Icons.arrow_downward, size: 24, color: AppColors.kYellow),
            ),
          ],
        );
      case 2:
        return const Icon(Icons.sync, size: 64, color: AppColors.kYellow);
      case 3:
      default:
        return const Icon(Icons.check_circle_outline, size: 64, color: AppColors.kLevelGreen);
    }
  }

  String _getStepInstructions(AppLocalizations l10n) {
    switch (_step) {
      case 1:
        return l10n.calibrationWizardStep1;
      case 2:
        return l10n.calibrationWizardStep2;
      case 3:
      default:
        return l10n.calibrationWizardStep3;
    }
  }

  Widget _buildActionButton(AppLocalizations l10n) {
    switch (_step) {
      case 1:
        return TactileButton(
          onPressed: _onCaptureA,
          text: l10n.calibrationWizardCaptureA,
          icon: const Icon(Icons.camera_alt),
        );
      case 2:
        return TactileButton(
          onPressed: _onCaptureB,
          text: l10n.calibrationWizardCaptureB,
          icon: const Icon(Icons.camera_alt),
        );
      case 3:
      default:
        return TactileButton(
          onPressed: () => Navigator.pop(context),
          text: l10n.calibrationWizardButtonFinish,
          icon: const Icon(Icons.check),
        );
    }
  }
}
