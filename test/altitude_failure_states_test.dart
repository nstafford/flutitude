import 'package:flutitude/altitude_screen.dart';
import 'package:flutitude/altitude_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_altitude_service.dart';

Future<FakeAltitudeService> pumpWith(
  WidgetTester tester,
  LocationStatus status,
) async {
  final service = FakeAltitudeService(status);
  await tester.pumpWidget(MaterialApp(home: AltitudeScreen(service: service)));
  await tester.pump();
  return service;
}

void expectNoAltitude() {
  expect(find.textContaining(' ft'), findsNothing);
}

void main() {
  testWidgets('waiting', (tester) async {
    await pumpWith(tester, const Waiting());
    expect(find.text('Waiting for GPS…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expectNoAltitude();
  });

  testWidgets('altitude unavailable', (tester) async {
    await pumpWith(tester, const AltitudeUnavailable());
    expect(find.text('Altitude unavailable'), findsOneWidget);
    expectNoAltitude();
  });

  testWidgets('services disabled', (tester) async {
    await pumpWith(tester, const ServicesDisabled());
    expect(
      find.textContaining('Location Services are turned off'),
      findsOneWidget,
    );
    expectNoAltitude();
  });

  testWidgets('permission denied without settings button', (tester) async {
    await pumpWith(tester, const PermissionDenied(permanent: false));
    expect(find.textContaining('needs location permission'), findsOneWidget);
    expect(find.text('Open Settings'), findsNothing);
    expectNoAltitude();
  });

  testWidgets('permanently denied shows Open Settings', (tester) async {
    final service = await pumpWith(
      tester,
      const PermissionDenied(permanent: true),
    );
    expect(find.text('Open Settings'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(service.openSettingsCount, 1);
    expectNoAltitude();
  });

  testWidgets('reduced accuracy still shows altitude with indicator', (
    tester,
  ) async {
    await pumpWith(
      tester,
      Available(
        AltitudeReading(
          meters: 100,
          accuracyMeters: 30,
          timestamp: DateTime(2026),
        ),
      ),
    );
    expect(find.text('328 ft'), findsOneWidget);
    expect(find.text('Low accuracy'), findsOneWidget);
  });

  testWidgets('resume re-subscribes and recovers from failure', (tester) async {
    final service = await pumpWith(tester, const ServicesDisabled());
    expect(service.watchCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(service.watchCount, 2);

    service.emit(
      Available(AltitudeReading(meters: 100, timestamp: DateTime(2026))),
    );
    await tester.pump();
    expect(find.text('328 ft'), findsOneWidget);
  });
}
