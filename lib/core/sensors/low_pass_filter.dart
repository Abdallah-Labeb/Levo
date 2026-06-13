/// Exponential moving average (EMA) low-pass filter.
/// alpha close to 1.0 = raw/fast. alpha close to 0.0 = smooth/slow.
class LowPassFilter {
  LowPassFilter({required double alpha}) : _alpha = alpha.clamp(0.0, 1.0);

  double _alpha;
  double _value = 0.0;
  bool _initialized = false;

  /// Update [alpha] when user changes viscosity setting.
  set alpha(double value) => _alpha = value.clamp(0.0, 1.0);

  /// Get the current alpha value.
  double get alpha => _alpha;

  /// Filters a [newValue] through the exponential moving average.
  double filter(double newValue) {
    if (!_initialized) {
      _value = newValue;
      _initialized = true;
      return _value;
    }
    _value = _alpha * newValue + (1.0 - _alpha) * _value;
    return _value;
  }

  /// Resets the filter baseline.
  void reset() {
    _initialized = false;
    _value = 0.0;
  }
}
