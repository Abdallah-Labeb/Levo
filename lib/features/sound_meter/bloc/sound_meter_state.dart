import 'package:equatable/equatable.dart';

/// State representation of the Sound Level Meter.
class SoundMeterState extends Equatable {
  const SoundMeterState({
    this.currentDb = 0.0,
    this.peakDb = 0.0,
    this.averageDb = 0.0,
    this.minDb = double.infinity, // infinity = no reading yet
    this.isSensorAvailable = true,
    this.errorMessage,
    this.permissionGranted = false,
  });

  final double currentDb;
  final double peakDb;
  final double averageDb;
  final double minDb;
  final bool isSensorAvailable;
  final String? errorMessage;
  final bool permissionGranted;

  @override
  List<Object?> get props => [
    currentDb,
    peakDb,
    averageDb,
    minDb,
    isSensorAvailable,
    errorMessage,
    permissionGranted,
  ];

  SoundMeterState copyWith({
    double? currentDb,
    double? peakDb,
    double? averageDb,
    double? minDb,
    bool? isSensorAvailable,
    String? errorMessage,
    bool? permissionGranted,
  }) {
    return SoundMeterState(
      currentDb: currentDb ?? this.currentDb,
      peakDb: peakDb ?? this.peakDb,
      averageDb: averageDb ?? this.averageDb,
      minDb: minDb ?? this.minDb,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionGranted: permissionGranted ?? this.permissionGranted,
    );
  }
}
