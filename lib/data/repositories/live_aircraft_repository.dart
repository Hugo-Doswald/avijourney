import '../../domain/models/aircraft_identity.dart';
import '../../domain/models/flight_route.dart';
import '../../domain/models/flight.dart';
import '../../domain/models/tracked_aircraft.dart';
import '../../domain/providers/aircraft_enrichment_provider.dart';
import '../../domain/providers/aircraft_position_provider.dart';
import '../../domain/providers/flight_identity_provider.dart';
import '../../domain/repositories/aircraft_repository.dart';

class LiveAircraftRepository implements AircraftRepository {
  LiveAircraftRepository({
    required AircraftPositionProvider positions,
    required AircraftEnrichmentProvider enrichment,
    FlightIdentityProvider flightIdentity = const NoOpFlightIdentityProvider(),
  })  : _positions = positions,
        _enrichment = enrichment,
        _flightIdentity = flightIdentity;

  final AircraftPositionProvider _positions;
  final AircraftEnrichmentProvider _enrichment;
  final FlightIdentityProvider _flightIdentity;

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
      Flight? flight;
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
        try {
          flight =
              await _flightIdentity.resolveVerifiedIdentity(state.callsign);
        } catch (_) {
          flight = null;
        }
      }
      flight ??= Flight(
        operationalCallsign: state.callsign,
        origin: route?.origin,
        destination: route?.destination,
        aircraftRegistration: identity?.registration,
        aircraftIcao24: state.icao24,
        aircraftType: identity?.model ?? identity?.typeCode,
        source: route?.source,
      );
      return TrackedAircraft(
          state: state, identity: identity, route: route, flight: flight);
    }));
  }
}
