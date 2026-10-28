import 'package:flutitude/altitude_service.dart';
import 'package:flutitude/units.dart';
import 'package:flutter/material.dart';

class AltitudeScreen extends StatefulWidget {
  const AltitudeScreen({super.key, required this.service});

  final AltitudeService service;

  @override
  State<AltitudeScreen> createState() => _AltitudeScreenState();
}

class _AltitudeScreenState extends State<AltitudeScreen>
    with WidgetsBindingObserver {
  late Stream<LocationStatus> _stream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stream = widget.service.watch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _stream = widget.service.watch());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutitude')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<LocationStatus>(
            stream: _stream,
            initialData: const Waiting(),
            builder: (context, snapshot) =>
                _content(context, snapshot.data ?? const Waiting()),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, LocationStatus status) {
    final theme = Theme.of(context);
    return switch (status) {
      Available(:final reading) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatMetersAsFeet(reading.meters),
            style: theme.textTheme.displayLarge,
            textAlign: TextAlign.center,
          ),
          if (reading.accuracyMeters != null)
            Text(
              '± ${formatMetersAsFeet(reading.accuracyMeters!)}',
              style: theme.textTheme.titleMedium,
            ),
          if (reading.reducedAccuracy)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Low accuracy',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
      Waiting() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Waiting for GPS…', style: theme.textTheme.titleLarge),
        ],
      ),
      AltitudeUnavailable() => Text(
        'Altitude unavailable',
        style: theme.textTheme.titleLarge,
      ),
      ServicesDisabled() => Text(
        'Location Services are turned off. Turn them on in Settings to see your altitude.',
        style: theme.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      PermissionDenied(:final permanent) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Flutitude needs location permission to show your altitude.',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (permanent) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: widget.service.openSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ],
      ),
    };
  }
}
