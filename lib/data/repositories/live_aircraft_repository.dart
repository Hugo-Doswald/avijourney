import '../../domain/models/aircraft_identity.dart';
import '../../domain/models/flight_route.dart';
import '../../domain/models/tracked_aircraft.dart';
import '../../domain/providers/aircraft_enrichment_provider.dart';
import '../../domain/providers/aircraft_position_provider.dart';
import '../../domain/repositories/aircraft_repository.dart';

class LiveAircraftRepository implements AircraftRepository {
  LiveAircraftRepository({
    required AircraftPositionProvider positions,
    required AircraftEnrichmentProvider enrichment,
  })  : _positions = positions,
        _enrichment = enrichment;

  final AircraftPositionProvider _positions;
  final AircraftEnrichmentProvider _enrichment;

  @override
  Future<List<TrackedAircraft>> loadNearby({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async {
    final states = await _positions.fetchAircraft(
      centerLatitude: centerLatitude,
      centerLongitude: centerLongitude,
      radiusNauticalMiles: radiusNauticalMiles,
    );
    return Future.wait(states.map((state) async {
      AircraftIdentity? identity;
      FlightRoute? route;
      try {
        identity = await _enrichment.resolveAircraft(state.icao24);
      } catch (_) {
        identity = null;
      }
      if (state.callsign.isNotEmpty) {
        try {
          route = await _enrichment.resolveRoute(state.callsign);
        } catch (_) {
          route = null;
        }
      }
      return TrackedAircraft(state: state, identity: identity, route: route);
    }));
  }
}
