import '../../domain/models/airport.dart';
import '../../domain/models/flight_route.dart';
import '../../domain/providers/aircraft_enrichment_provider.dart';

class MockAircraftEnrichmentProvider implements AircraftEnrichmentProvider {
  const MockAircraftEnrichmentProvider();

  static const _identities = <String, AircraftIdentity>{
    '40621D': AircraftIdentity(
        icao24: '40621D',
        registration: 'G-EUYA',
        typeCode: 'A320',
        model: 'Airbus A320-232',
        operatorName: 'British Airways'),
    '4CA123': AircraftIdentity(
        icao24: '4CA123',
        registration: 'EI-DEI',
        typeCode: 'A320',
        model: 'Airbus A320-214',
        operatorName: 'Aer Lingus'),
    '400F2B': AircraftIdentity(
        icao24: '400F2B',
        registration: 'G-LGNN',
        typeCode: 'E145',
        model: 'Embraer ERJ-145',
        operatorName: 'Loganair'),
  };

  static const _routes = <String, FlightRoute>{
    'BAW12': FlightRoute(
        callsign: 'BAW12',
        origin: Airport(icao: 'EGLL', iata: 'LHR', name: 'London Heathrow'),
        destination: Airport(icao: 'EGTE', iata: 'EXT', name: 'Exeter Airport'),
        source: 'Milestone 1 mock fixture'),
    'EIN4KL': FlightRoute(
        callsign: 'EIN4KL',
        origin: Airport(icao: 'EIDW', iata: 'DUB', name: 'Dublin Airport'),
        destination:
            Airport(icao: 'EGLL', iata: 'LHR', name: 'London Heathrow'),
        source: 'Milestone 1 mock fixture'),
  };

  @override
  Future<AircraftIdentity?> resolveAircraft(String icao24) async =>
      _identities[icao24];

  @override
  Future<Airport?> resolveAirport(String code) async {
    for (final route in _routes.values) {
      if (route.origin?.displayCode == code) return route.origin;
      if (route.destination?.displayCode == code) return route.destination;
    }
    return null;
  }

  @override
  Future<FlightRoute?> resolveRoute(String callsign) async => _routes[callsign];
}
