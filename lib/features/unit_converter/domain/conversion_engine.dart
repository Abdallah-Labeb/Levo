/// Represents the category of unit conversions.
enum UnitCategory {
  length,
  area,
  volume,
  mass,
  speed,
  pressure,
  angle,
}

/// A pure-logic conversion engine containing unit multiplier factors and category definitions.
class ConversionEngine {
  // Conversion factors relative to base SI unit for each category.
  // Base units: Length (m), Area (m²), Volume (l), Mass (kg), Speed (m/s), Pressure (Pa), Angle (deg).
  
  static const Map<UnitCategory, Map<String, double>> conversionFactors = {
    UnitCategory.length: {
      'mm': 0.001,
      'cm': 0.01,
      'm': 1.0,
      'km': 1000.0,
      'in': 0.0254,
      'ft': 0.3048,
      'yd': 0.9144,
      'mi': 1609.344,
    },
    UnitCategory.area: {
      'mm²': 1e-6,
      'cm²': 1e-4,
      'm²': 1.0,
      'ha': 10000.0,
      'in²': 0.00064516,
      'ft²': 0.09290304,
      'ac': 4046.8564224,
    },
    UnitCategory.volume: {
      'ml': 0.001,
      'l': 1.0,
      'm³': 1000.0,
      'cup': 0.2365882365,
      'pt': 0.473176473,
      'qt': 0.946352946,
      'gal': 3.785411784,
      'fl_oz': 0.02957352956,
    },
    UnitCategory.mass: {
      'mg': 1e-6,
      'g': 0.001,
      'kg': 1.0,
      't': 1000.0,
      'oz': 0.028349523125,
      'lb': 0.45359237,
    },
    UnitCategory.speed: {
      'm/s': 1.0,
      'km/h': 0.2777777778,
      'mph': 0.44704,
      'knots': 0.5144444444,
    },
    UnitCategory.pressure: {
      'Pa': 1.0,
      'kPa': 1000.0,
      'bar': 100000.0,
      'psi': 6894.757293168,
      'atm': 101325.0,
    },
    UnitCategory.angle: {
      'deg': 1.0,
      'rad': 57.295779513, // 180 / pi
      'grad': 0.9,         // 360 / 400
    },
  };

  /// Converts a value from one unit to another in a specific category.
  static double convert({
    required UnitCategory category,
    required String fromUnit,
    required String toUnit,
    required double value,
  }) {
    final factors = conversionFactors[category];
    if (factors == null) return value;

    final fromFactor = factors[fromUnit];
    final toFactor = factors[toUnit];

    if (fromFactor == null || toFactor == null) return value;

    // Convert value to base unit first, then to target unit
    final double valueInBase = value * fromFactor;
    return valueInBase / toFactor;
  }

  /// Returns list of supported unit strings for a category.
  static List<String> getUnitsForCategory(UnitCategory category) {
    return conversionFactors[category]?.keys.toList() ?? [];
  }
}
