import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutitude/altitude_service.dart';
import 'package:flutter_test/flutter_test.dart';

AltitudeReading r({double? accuracy}) => AltitudeReading(
  meters: 10,
  accuracyMeters: accuracy,
  timestamp: DateTime(2026),
);

void main() {
  test('non-finite altitude maps to altitudeUnavailable', () {
    for (final v in [double.nan, double.infinity]) {
      expect(
        statusFromMeasurement(altitudeMeters: v, timestamp: DateTime(2026)),
        isA<AltitudeUnavailable>(),
      );
    }
  });

  test('accuracy over 50 ft flags reducedAccuracy', () {
    expect(r(accuracy: 15).reducedAccuracy, isFalse); // ~49.2 ft
    expect(r(accuracy: 16).reducedAccuracy, isTrue); // ~52.5 ft
    expect(r().reducedAccuracy, isFalse);
  });

  test('invalid accuracy values are dropped', () {
    final s = statusFromMeasurement(
      altitudeMeters: 5,
      accuracyMeters: -1,
      timestamp: DateTime(2026),
    ) as Available;
    expect(s.reading.accuracyMeters, isNull);
  });

  test('no valid altitude for 30 s switches available to waiting', () {
    fakeAsync((async) {
      final source = StreamController<LocationStatus>();
      final seen = <LocationStatus>[];
      withStaleness(source.stream).listen(seen.add);

      source.add(Available(r()));
      async.elapse(const Duration(seconds: 29));
      async.flushMicrotasks();
      expect(seen.last, isA<Available>());

      async.elapse(const Duration(seconds: 2));
      expect(seen.last, isA<Waiting>());
    });
  });

  test('a fresh valid reading resets the staleness timer', () {
    fakeAsync((async) {
      final source = StreamController<LocationStatus>();
      final seen = <LocationStatus>[];
      withStaleness(source.stream).listen(seen.add);

      source.add(Available(r()));
      async.elapse(const Duration(seconds: 20));
      source.add(Available(r()));
      async.elapse(const Duration(seconds: 20));
      expect(seen.last, isA<Available>());
    });
  });

  test('altitudeUnavailable passes through and does not arm the timer', () {
    fakeAsync((async) {
      final source = StreamController<LocationStatus>();
      final seen = <LocationStatus>[];
      withStaleness(source.stream).listen(seen.add);

      source.add(const AltitudeUnavailable());
      async.elapse(const Duration(seconds: 60));
      expect(seen.single, isA<AltitudeUnavailable>());
    });
  });
}
