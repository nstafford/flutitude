import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'altitude_service.dart';
import 'geolocator_altitude_service.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(FlutitudeApp(service: GeolocatorAltitudeService()));
}

class FlutitudeApp extends StatelessWidget {
  const FlutitudeApp({super.key, required this.service});

  final AltitudeService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutitude',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: SplashScreen(service: service),
    );
  }
}
