import 'package:equatable/equatable.dart';

/// Sub-modes of the Spirit Level.
enum SpiritLevelMode { flat2d, edge1d, plumb }

/// Proximity status of being level.
enum LevelStatus { level, close, off }

/// State representation of the Spirit Level tool.
class SpiritLevelState extends Equatable {
  const SpiritLevelState({
    this.pitch = 0.0,
    this.roll = 0.0,
    this.status = LevelStatus.off,
    this.mode = SpiritLevelMode.flat2d,
    this.isHeld = false,
    this.showPercent = false,
    this.isSensorAvailable = true,
    this.errorMessage,
    this.soundOn = true,
    this.hapticOn = true,
  });

  final double pitch;
  final double roll;
  final LevelStatus status;
  final SpiritLevelMode mode;
  final bool isHeld;
  final bool showPercent;
  final bool isSensorAvailable;
  final String? errorMessage;
  final bool soundOn;
  final bool hapticOn;

  @override
  List<Object?> get props => [
        pitch,
        roll,
        status,
        mode,
        isHeld,
        showPercent,
        isSensorAvailable,
        errorMessage,
        soundOn,
        hapticOn,
      ];

  SpiritLevelState copyWith({
    double? pitch,
    double? roll,
    LevelStatus? status,
    SpiritLevelMode? mode,
    bool? isHeld,
    bool? showPercent,
    bool? isSensorAvailable,
    String? errorMessage,
    bool? soundOn,
    bool? hapticOn,
  }) {
    return SpiritLevelState(
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      isHeld: isHeld ?? this.isHeld,
      showPercent: showPercent ?? this.showPercent,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      soundOn: soundOn ?? this.soundOn,
      hapticOn: hapticOn ?? this.hapticOn,
    );
  }
}
