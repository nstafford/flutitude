import 'dart:async';

import 'units.dart';

const double reducedAccuracyThresholdFeet = 50;
const Duration stalenessTimeout = Duration(seconds: 30);

class AltitudeReading {
  const AltitudeReading({
    required this.meters,
    this.accuracyMeters,
    required this.timestamp,
  });

  final double meters;
  final double? accuracyMeters;
  final DateTime timestamp;

  bool get reducedAccuracy =>
      accuracyMeters != null &&
      metersToFeet(accuracyMeters!) > reducedAccuracyThresholdFeet;
}

sealed class LocationStatus {
  const LocationStatus();
}

class Waiting extends LocationStatus {
  const Waiting();
}

class Available extends LocationStatus {
  const Available(this.reading);
  final AltitudeReading reading;
}

class AltitudeUnavailable extends LocationStatus {
  const AltitudeUnavailable();
}

class PermissionDenied extends LocationStatus {
  const PermissionDenied({required this.permanent});
  final bool permanent;
}

class ServicesDisabled extends LocationStatus {
  const ServicesDisabled();
}

abstract class AltitudeService {
  /// Emits the current status immediately, then on every change.
  /// Each call starts a fresh check of services and permission.
  Stream<LocationStatus> watch();

  Future<void> openSettings();

  void dispose();
}

/// Maps a raw position measurement to a status; non-finite altitude is unavailable.
LocationStatus statusFromMeasurement({
  required double altitudeMeters,
  double? accuracyMeters,
  required DateTime timestamp,
}) {
  if (!altitudeMeters.isFinite) return const AltitudeUnavailable();
  final accuracy =
      (accuracyMeters != null && accuracyMeters.isFinite && accuracyMeters > 0)
      ? accuracyMeters
      : null;
  return Available(
    AltitudeReading(
      meters: altitudeMeters,
      accuracyMeters: accuracy,
      timestamp: timestamp,
    ),
  );
}

/// Emits [Waiting] when an [Available] status has not been refreshed by a
/// valid-altitude update within [timeout]. Other statuses pass through.
Stream<LocationStatus> withStaleness(
  Stream<LocationStatus> source, {
  Duration timeout = stalenessTimeout,
}) {
  late StreamController<LocationStatus> controller;
  StreamSubscription<LocationStatus>? sub;
  Timer? timer;

  controller = StreamController<LocationStatus>(
    onListen: () {
      sub = source.listen(
        (status) {
          timer?.cancel();
          timer = null;
          controller.add(status);
          if (status is Available) {
            timer = Timer(timeout, () => controller.add(const Waiting()));
          }
        },
        onError: controller.addError,
        onDone: () {
          // Keep the timer alive so a stalled last reading still expires.
          if (timer == null) controller.close();
        },
      );
    },
    onCancel: () {
      timer?.cancel();
      return sub?.cancel();
    },
  );
  return controller.stream;
}
