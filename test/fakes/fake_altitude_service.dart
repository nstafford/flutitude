import 'dart:async';

import 'package:flutitude/altitude_service.dart';

class FakeAltitudeService implements AltitudeService {
  FakeAltitudeService([this.initial = const Waiting()]);

  final LocationStatus initial;
  int watchCount = 0;
  int openSettingsCount = 0;
  StreamController<LocationStatus>? _controller;

  void emit(LocationStatus status) => _controller?.add(status);

  @override
  Stream<LocationStatus> watch() {
    watchCount++;
    _controller?.close();
    final controller = StreamController<LocationStatus>();
    _controller = controller;
    controller.onListen = () => controller.add(initial);
    return controller.stream;
  }

  @override
  Future<void> openSettings() async => openSettingsCount++;

  @override
  void dispose() => _controller?.close();
}
