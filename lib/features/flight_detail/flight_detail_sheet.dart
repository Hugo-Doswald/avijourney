import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../domain/models/followed_item.dart';
import '../../domain/models/tracked_aircraft.dart';

Future<void> showFlightDetail(
  BuildContext context,
  TrackedAircraft aircraft,
  AppController controller, {
  required VoidCallback onShowOnMap,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .88,
        child: FlightDetailView(
          aircraft: aircraft,
          controller: controller,
          onShowOnMap: onShowOnMap,
        ),
      ),
    );

class FlightDetailView extends StatelessWidget {
  const FlightDetailView({
    required this.aircraft,
    required this.controller,
    required this.onShowOnMap,
    super.key,
  });

  final TrackedAircraft aircraft;
  final AppController controller;
  final VoidCallback onShowOnMap;

  @override
  Widget build(BuildContext context) {
    final flight = aircraft.flight;
    final route = aircraft.route;
    final origin = flight?.origin ?? route?.origin;
    final destination = flight?.destination ?? route?.destination;
    final item = FollowedItem(
      type: FollowedItemType.flight,
      identifier: flight?.primaryIdentifier ?? aircraft.state.callsign,
      label: flight?.primaryIdentifier ?? aircraft.state.callsign,
      subtitle: origin != null && destination != null
          ? '${origin.displayCode} → ${destination.displayCode}'
          : null,
    );
    String time(DateTime? value) =>
        value?.toLocal().toString() ?? 'Unavailable';
    return ListView(padding: const EdgeInsets.all(24), children: [
      Row(children: [
        Expanded(
          child: Text(flight?.primaryIdentifier ?? aircraft.state.callsign,
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        IconButton(
          tooltip: controller.isFollowing(item)
              ? 'Unfollow flight'
              : 'Follow flight',
          onPressed: () => controller.toggleFollowed(item),
          icon: Icon(controller.isFollowing(item)
              ? Icons.notifications_active
              : Icons.notifications_none),
        ),
        IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.close)),
      ]),
      Text(flight?.isCommercialIdentityVerified == true
          ? 'VERIFIED COMMERCIAL FLIGHT'
          : 'OPERATIONAL CALLSIGN · COMMERCIAL NUMBER UNRESOLVED'),
      const SizedBox(height: 16),
      _FlightSection(title: 'IDENTITY', rows: {
        'Commercial number': flight?.isCommercialIdentityVerified == true
            ? flight!.commercialFlightNumber!
            : 'Unresolved',
        'Airline': flight?.airlineName ?? 'Unavailable',
        'Callsign': flight?.operationalCallsign ?? aircraft.state.callsign,
        'Status': flight?.status ?? 'Unavailable',
      }),
      _FlightSection(title: 'ROUTE & SCHEDULE', rows: {
        'Origin': origin == null
            ? 'Unavailable'
            : '${origin.displayCode} · ${origin.name}',
        'Destination': destination == null
            ? 'Unavailable'
            : '${destination.displayCode} · ${destination.name}',
        'Scheduled departure': time(flight?.scheduledDeparture),
        'Scheduled arrival': time(flight?.scheduledArrival),
        'Estimated departure': time(flight?.estimatedDeparture),
        'Estimated arrival': time(flight?.estimatedArrival),
        'Actual departure': time(flight?.actualDeparture),
        'Actual arrival': time(flight?.actualArrival),
      }),
      _FlightSection(title: 'AIRCRAFT & PROVENANCE', rows: {
        'Registration': flight?.aircraftRegistration ??
            aircraft.identity?.registration ??
            'Unavailable',
        'Type': flight?.aircraftType ??
            aircraft.identity?.model ??
            aircraft.identity?.typeCode ??
            'Unavailable',
        'ICAO24': aircraft.state.icao24.toUpperCase(),
        'Source':
            flight?.source ?? route?.source ?? 'No verified flight source',
      }),
      FilledButton.icon(
        key: const Key('showAircraftOnMap'),
        onPressed: () {
          controller.select(aircraft.state.icao24);
          Navigator.maybePop(context);
          onShowOnMap();
        },
        icon: const Icon(Icons.map_outlined),
        label: const Text('Show aircraft on map'),
      ),
    ]);
  }
}

class _FlightSection extends StatelessWidget {
  const _FlightSection({required this.title, required this.rows});
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
                            width: 140,
                            child: Text(entry.key,
                                style: Theme.of(context).textTheme.bodySmall)),
                        Expanded(child: Text(entry.value)),
                      ]),
                )),
          ]),
        ),
      );
}
