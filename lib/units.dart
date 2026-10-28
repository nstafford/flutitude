const double feetPerMeter = 3.28084;

double metersToFeet(double meters) => meters * feetPerMeter;

/// Rounds to whole feet, e.g. 1234.4 -> "1,234 ft". Negative values are valid.
String formatFeet(double feet) {
  final rounded = feet.round();
  final digits = rounded.abs().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  // Avoid "-0" for tiny negative values.
  final sign = rounded < 0 ? '-' : '';
  return '$sign$grouped ft';
}

String formatMetersAsFeet(double meters) => formatFeet(metersToFeet(meters));
