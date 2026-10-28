import 'package:flutitude/altitude_screen.dart';
import 'package:flutitude/altitude_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_altitude_service.dart';

AltitudeReading reading(double meters, {double? accuracy}) => AltitudeReading(
  meters: meters,
  accuracyMeters: accuracy,
  timestamp: DateTime(2026),
);

void main() {
  testWidgets('shows whole-feet altitude and accuracy, then updates', (
    tester,
  ) async {
    final service = FakeAltitudeService(Available(reading(1000, accuracy: 3)));
    await tester.pumpWidget(
      MaterialApp(home: AltitudeScreen(service: service)),
    );
    await tester.pump();
    expect(find.text('3,281 ft'), findsOneWidget);
    expect(find.text('± 10 ft'), findsOneWidget);
    expect(find.text('Low accuracy'), findsNothing);

    service.emit(Available(reading(1001)));
    await tester.pump();
    expect(find.text('3,284 ft'), findsOneWidget);
    expect(find.textContaining('±'), findsNothing);
  });
}
