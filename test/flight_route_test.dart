import 'package:avijourney/domain/models/flight_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route identity remains its operational callsign', () {
    const route = FlightRoute(
      callsign: 'BAW7LC',
    );

    expect(route.primaryIdentifier, 'BAW7LC');
  });
}
