import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'altitude_service.dart';

/// The only file that imports `geolocator`. Location values are never logged or stored.
class GeolocatorAltitudeService implements AltitudeService {
  @override
  Stream<LocationStatus> watch() => withStaleness(_raw());

  Stream<LocationStatus> _raw() async* {
    yield const Waiting();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        yield const ServicesDisabled();
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        yield const PermissionDenied(permanent: true);
        return;
      }
      if (permission == LocationPermission.denied) {
        yield const PermissionDenied(permanent: false);
        return;
      }
      await for (final p in Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      )) {
        yield statusFromMeasurement(
          altitudeMeters: p.altitude,
          accuracyMeters: p.altitudeAccuracy,
          timestamp: p.timestamp,
        );
      }
    } on LocationServiceDisabledException {
      yield const ServicesDisabled();
    } on PermissionDeniedException {
      yield const PermissionDenied(permanent: false);
    }
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();

  @override
  void dispose() {}
}
