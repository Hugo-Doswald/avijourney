import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../domain/models/tracked_aircraft.dart';

Future<void> showAircraftDetail(BuildContext context, TrackedAircraft aircraft,
        AppController controller) =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: .88,
            child:
                _AircraftDetail(aircraft: aircraft, controller: controller)));

class _AircraftDetail extends StatelessWidget {
  const _AircraftDetail({required this.aircraft, required this.controller});
  final TrackedAircraft aircraft;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final state = aircraft.state;
    final identity = aircraft.identity;
    final route = aircraft.route;
    return ListView(padding: const EdgeInsets.all(24), children: [
      Row(children: [
        Expanded(
            child: Text(aircraft.primaryIdentifier,
                style: Theme.of(context).textTheme.headlineMedium)),
        IconButton(
            onPressed: () => controller.toggleSaved(state.icao24),
            icon: Icon(controller.saved.contains(state.icao24)
                ? Icons.bookmark
                : Icons.bookmark_border)),
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close))
      ]),
      Text(state.callsign.isEmpty
          ? 'No callsign available'
          : 'Callsign ${state.callsign}'),
      const SizedBox(height: 20),
      _Section(title: 'AIRCRAFT', rows: {
        'Operator': identity?.operatorName ?? 'Unavailable',
        'Model / type': identity?.model ?? identity?.typeCode ?? 'Unavailable',
        'Registration': identity?.registration ?? 'Unavailable',
        'ICAO24': state.icao24.toUpperCase()
      }),
      _Section(title: 'ROUTE', rows: {
        'Origin': route?.origin == null
            ? 'Unavailable'
            : '${route!.origin!.displayCode} · ${route.origin!.name}',
        'Destination': route?.destination == null
            ? 'Unavailable'
            : '${route!.destination!.displayCode} · ${route.destination!.name}',
        'Provenance': route?.source ?? 'No verified route source'
      }),
      _Section(title: 'LIVE METRICS', rows: {
        'Altitude': '${state.altitudeFeet.round()} ft',
        'Ground speed': '${state.groundSpeedKnots.round()} kt',
        'Heading': '${state.trackDegrees.round()}°',
        'Vertical rate': '${state.verticalRateFeetPerMinute.round()} ft/min',
        'Squawk': state.squawk ?? 'Unavailable',
        'Position':
            '${state.latitude.toStringAsFixed(4)}, ${state.longitude.toStringAsFixed(4)}'
      }),
      _Section(title: 'OBSERVED HISTORY', rows: {
        'Trail points': '${aircraft.trail.length}',
        'Latest observation': state.observedAt.toLocal().toString()
      }),
    ]);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});
  final String title;
  final Map<String, String> rows;
  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Divider(),
            ...rows.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 120,
                          child: Text(entry.key,
                              style: Theme.of(context).textTheme.bodySmall)),
                      Expanded(child: Text(entry.value))
                    ])))
          ])));
}
