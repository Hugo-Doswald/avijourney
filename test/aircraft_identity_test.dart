import 'package:avijourney/domain/models/aircraft_identity.dart';
import 'package:avijourney/domain/models/aircraft_state.dart';
import 'package:avijourney/domain/models/tracked_aircraft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tracked aircraft consumes the domain AircraftIdentity model', () {
    const identity = AircraftIdentity(
      icao24: 'ABC123',
      registration: 'G-TEST',
    );
    final tracked = TrackedAircraft(
      state: AircraftState(
        icao24: 'ABC123',
        callsign: '',
        latitude: 0,
        longitude: 0,
        altitudeFeet: 0,
        groundSpeedKnots: 0,
        trackDegrees: 0,
        verticalRateFeetPerMinute: 0,
        observedAt: DateTime.utc(2026),
      ),
      identity: identity,
    );

    expect(tracked.identity, same(identity));
    expect(tracked.primaryIdentifier, 'G-TEST');
  });
}
