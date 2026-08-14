import 'dart:convert';

import 'package:avijourney/data/opensky/opensky_aircraft_position_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

List<Object?> stateRow({
  Object? icao24 = '40621d',
  Object? callsign = 'BAW12  ',
  Object? longitude = -0.5,
  Object? latitude = 51.5,
}) =>
    [
      icao24,
      callsign,
      'United Kingdom',
      1700000000,
      1700000001,
      longitude,
      latitude,
      3048.0,
      false,
      128.6,
      91.0,
      -3.2,
      null,
      3100.0,
      '1234',
      false,
      0,
    ];

void main() {
  test('parses valid rows, converts units, and skips malformed/null positions',
      () {
    final body = jsonEncode({
      'time': 1700000002,
      'states': [
        stateRow(),
        stateRow(icao24: 'broken', latitude: null),
        ['too', 'short'],
        'not a row',
      ],
    });

    final aircraft = OpenSkyAircraftPositionProvider.parseResponse(body);

    expect(aircraft, hasLength(1));
    expect(aircraft.single.icao24, '40621d');
    expect(aircraft.single.callsign, 'BAW12');
    expect(aircraft.single.altitudeFeet, closeTo(10000, 1));
    expect(aircraft.single.groundSpeedKnots, closeTo(250, 1));
    expect(aircraft.single.verticalRateFeetPerMinute, closeTo(-630, 2));
  });

  test('builds a geographically bounded OpenSky request for radar range',
      () async {
    Uri? requested;
    final client = MockClient((request) async {
      requested = request.url;
      return http.Response('{"time":1700000002,"states":[]}', 200);
    });
    final provider = OpenSkyAircraftPositionProvider(client: client);

    await provider.fetchAircraft(
      centerLatitude: 51,
      centerLongitude: -1,
      radiusNauticalMiles: 60,
    );

    expect(requested!.path, '/api/states/all');
    expect(
        double.parse(requested!.queryParameters['lamin']!), closeTo(50, .001));
    expect(
        double.parse(requested!.queryParameters['lamax']!), closeTo(52, .001));
    expect(double.parse(requested!.queryParameters['lomin']!), lessThan(-2.5));
    expect(double.parse(requested!.queryParameters['lomax']!), greaterThan(.5));
  });
}
