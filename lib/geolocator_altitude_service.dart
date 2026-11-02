import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'altitude_service.dart';

/// The only file that imports `geolocator`. Location values are never logged or stored.
class GeolocatorAltitudeService implements AltitudeService {
  StreamController<LocationStatus>? _controller;
  Timer? _timer;
  // Incremented on pause/new watch so results of in-flight fixes are dropped.
  int _generation = 0;

  @override
  Stream<LocationStatus> watch() {
    _close();
    final controller = StreamController<LocationStatus>();
    _controller = controller;
    controller.onListen = () => _start(controller);
    controller.onCancel = () {
      if (identical(_controller, controller)) _close();
    };
    return withStaleness(controller.stream);
  }

  @override
  void pause() {
    _generation++;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _start(StreamController<LocationStatus> controller) async {
    final generation = ++_generation;
    bool current() =>
        generation == _generation && identical(_controller, controller);

    controller.add(const Waiting());
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (current()) controller.add(const ServicesDisabled());
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!current()) return;
      if (permission == LocationPermission.deniedForever) {
        controller.add(const PermissionDenied(permanent: true));
        return;
      }
      if (permission == LocationPermission.denied) {
        controller.add(const PermissionDenied(permanent: false));
        return;
      }
    } catch (_) {
      if (current()) controller.add(const ServicesDisabled());
      return;
    }
    await _poll(controller, current);
  }

  /// Takes one fix, then schedules the next so GPS is idle between fixes.
  Future<void> _poll(
    StreamController<LocationStatus> controller,
    bool Function() current,
  ) async {
    if (!current()) return;
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: fixTimeout,
        ),
      );
      if (!current()) return;
      controller.add(
        statusFromMeasurement(
          altitudeMeters: p.altitude,
          accuracyMeters: p.altitudeAccuracy,
          timestamp: p.timestamp,
        ),
      );
    } on LocationServiceDisabledException {
      if (!current()) return;
      controller.add(const ServicesDisabled());
      return;
    } on PermissionDeniedException {
      if (!current()) return;
      controller.add(const PermissionDenied(permanent: false));
      return;
    } on TimeoutException {
      // No fix this cycle; staleness handling reports Waiting if it persists.
    } catch (_) {
      // Transient failure; try again next cycle.
    }
    if (!current()) return;
    _timer = Timer(fixInterval, () => _poll(controller, current));
  }

  void _close() {
    _generation++;
    _timer?.cancel();
    _timer = null;
    final controller = _controller;
    _controller = null;
    if (controller != null && !controller.isClosed) controller.close();
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();

  @override
  void dispose() => _close();
}
