import '../models/airport.dart';
import '../models/aircraft_identity.dart';
import '../models/flight_route.dart';

abstract interface class AircraftEnrichmentProvider {
  Future<AircraftIdentity?> resolveAircraft(String icao24);

  Future<FlightRoute?> resolveRoute(String callsign);

  Future<Airport?> resolveAirport(String code);
}
