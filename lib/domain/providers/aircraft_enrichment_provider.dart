import '../models/airport.dart';
import '../models/flight_route.dart';

class AircraftIdentity {
  const AircraftIdentity({
    required this.icao24,
    this.registration,
    this.typeCode,
    this.model,
    this.operatorName,
  });

  final String icao24;
  final String? registration;
  final String? typeCode;
  final String? model;
  final String? operatorName;
}

abstract interface class AircraftEnrichmentProvider {
  Future<AircraftIdentity?> resolveAircraft(String icao24);

  Future<FlightRoute?> resolveRoute(String callsign);

  Future<Airport?> resolveAirport(String code);
}
