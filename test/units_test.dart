import 'package:flutitude/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('converts meters to feet', () {
    expect(metersToFeet(100), closeTo(328.084, 1e-9));
    expect(metersToFeet(0), 0);
  });

  test('rounds to whole feet', () {
    expect(formatFeet(1234.4), '1,234 ft');
    expect(formatFeet(1234.6), '1,235 ft');
  });

  test('uses thousands separators', () {
    expect(formatFeet(1234567), '1,234,567 ft');
    expect(formatFeet(999), '999 ft');
  });

  test('handles negative and zero', () {
    expect(formatFeet(-282.2), '-282 ft');
    expect(formatFeet(-1500), '-1,500 ft');
    expect(formatFeet(0), '0 ft');
    expect(formatFeet(-0.2), '0 ft');
  });

  test('formats meters as feet', () {
    expect(formatMetersAsFeet(100), '328 ft');
  });
}
