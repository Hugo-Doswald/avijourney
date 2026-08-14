import '../../domain/models/aircraft_state.dart';
import '../../domain/providers/aircraft_position_provider.dart';

class MockAircraftPositionProvider implements AircraftPositionProvider {
  const MockAircraftPositionProvider();

  @override
  Future<List<AircraftState>> fetchAircraft({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async {
    final now = DateTime.now();
    return <AircraftState>[
      AircraftState(
          icao24: '40621D',
          callsign: 'BAW12',
          latitude: centerLatitude + 0.08,
          longitude: centerLongitude - 0.12,
          altitudeFeet: 12400,
          groundSpeedKnots: 286,
          trackDegrees: 132,
          verticalRateFeetPerMinute: -640,
          squawk: '5123',
          observedAt: now),
      AircraftState(
          icao24: '4CA123',
          callsign: 'EIN4KL',
          latitude: centerLatitude - 0.14,
          longitude: centerLongitude + 0.09,
          altitudeFeet: 18400,
          groundSpeedKnots: 342,
          trackDegrees: 48,
          verticalRateFeetPerMinute: 1100,
          squawk: '2201',
          observedAt: now),
      AircraftState(
          icao24: '400F2B',
          callsign: 'LOG82P',
          latitude: centerLatitude + 0.22,
          longitude: centerLongitude + 0.25,
          altitudeFeet: 7600,
          groundSpeedKnots: 214,
          trackDegrees: 276,
          verticalRateFeetPerMinute: 0,
          squawk: '7012',
          observedAt: now),
      AircraftState(
          icao24: '407A05',
          callsign: '',
          latitude: centerLatitude - 0.28,
          longitude: centerLongitude - 0.18,
          altitudeFeet: 30200,
          groundSpeedKnots: 418,
          trackDegrees: 10,
          observedAt: now,
          verticalRateFeetPerMinute: 320),
    ];
  }
}
