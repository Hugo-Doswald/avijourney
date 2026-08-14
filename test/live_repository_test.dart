import 'package:avijourney/data/repositories/live_aircraft_repository.dart';
import 'package:avijourney/domain/models/aircraft_identity.dart';
import 'package:avijourney/domain/models/aircraft_state.dart';
import 'package:avijourney/domain/models/airport.dart';
import 'package:avijourney/domain/models/flight_route.dart';
import 'package:avijourney/domain/providers/aircraft_enrichment_provider.dart';
import 'package:avijourney/domain/providers/aircraft_position_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class OneAircraftProvider implements AircraftPositionProvider {
  @override
  Future<List<AircraftState>> fetchAircraft({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async =>
      [
        AircraftState(
          icao24: 'abc123',
          callsign: 'BAW7LC',
          latitude: centerLatitude,
          longitude: centerLongitude,
          altitudeFeet: 10000,
          groundSpeedKnots: 250,
          trackDegrees: 90,
          verticalRateFeetPerMinute: 0,
          observedAt: DateTime.utc(2026),
        ),
      ];
}

class FailingEnrichment implements AircraftEnrichmentProvider {
  @override
  Future<AircraftIdentity?> resolveAircraft(String icao24) =>
      throw StateError('HexDB offline');

  @override
  Future<Airport?> resolveAirport(String code) =>
      throw StateError('HexDB offline');

  @override
  Future<FlightRoute?> resolveRoute(String callsign) =>
      throw StateError('HexDB offline');
}

void main() {
  test('HexDB failure never removes otherwise valid live aircraft', () async {
    final repository = LiveAircraftRepository(
      positions: OneAircraftProvider(),
      enrichment: FailingEnrichment(),
    );

    final result = await repository.loadNearby(
      centerLatitude: 51,
      centerLongitude: -1,
      radiusNauticalMiles: 20,
    );

    expect(result, hasLength(1));
    expect(result.single.primaryIdentifier, 'BAW7LC');
    expect(result.single.identity, isNull);
    expect(result.single.route, isNull);
  });
}
