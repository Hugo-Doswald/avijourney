import '../../domain/models/tracked_aircraft.dart';
import '../../domain/models/aircraft_identity.dart';
import '../../domain/models/flight_route.dart';
import '../../domain/providers/aircraft_enrichment_provider.dart';
import '../../domain/providers/aircraft_position_provider.dart';
import '../../domain/repositories/aircraft_repository.dart';

class MockAircraftRepository implements AircraftRepository {
  MockAircraftRepository({
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
      final results = await Future.wait<Object?>([
        _enrichment.resolveAircraft(state.icao24),
        state.callsign.isEmpty
            ? Future<Object?>.value()
            : _enrichment.resolveRoute(state.callsign),
      ]);
      return TrackedAircraft(
        state: state,
        identity: results[0] as AircraftIdentity?,
        route: results[1] as FlightRoute?,
      );
    }));
  }
}
