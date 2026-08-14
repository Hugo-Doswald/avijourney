import '../models/flight_route.dart';

abstract interface class FlightIdentityProvider {
  Future<FlightRoute?> resolveVerifiedIdentity(String callsign);
}

class NoOpFlightIdentityProvider implements FlightIdentityProvider {
  const NoOpFlightIdentityProvider();

  @override
  Future<FlightRoute?> resolveVerifiedIdentity(String callsign) async => null;
}
