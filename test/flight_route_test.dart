import 'package:avijourney/domain/models/flight_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unverified commercial number never replaces callsign', () {
    const route = FlightRoute(
      callsign: 'BAW7LC',
      commercialFlightNumber: 'BA783',
      verified: false,
    );

    expect(route.primaryIdentifier, 'BAW7LC');
  });

  test('verified commercial number may become primary identifier', () {
    const route = FlightRoute(
      callsign: 'BAW7LC',
      commercialFlightNumber: 'BA783',
      verified: true,
    );

    expect(route.primaryIdentifier, 'BA783');
  });
}
