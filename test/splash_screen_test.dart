import 'package:flutitude/altitude_screen.dart';
import 'package:flutitude/altitude_service.dart';
import 'package:flutitude/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_altitude_service.dart';

void main() {
  testWidgets('splash shows image then replaces itself after 2 seconds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: SplashScreen(service: FakeAltitudeService())),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(AltitudeScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.byType(AltitudeScreen), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AltitudeScreen), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
  });

  test('FakeAltitudeService is an AltitudeService', () {
    expect(FakeAltitudeService(), isA<AltitudeService>());
  });
}
