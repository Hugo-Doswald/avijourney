import 'aircraft_identity.dart';
import 'aircraft_state.dart';
import 'flight_route.dart';
import 'flight.dart';

class TrackedAircraft {
  const TrackedAircraft({
    required this.state,
    this.identity,
    this.route,
    this.flight,
    this.trail = const <AircraftPosition>[],
  });

  final AircraftState state;
  final AircraftIdentity? identity;
  final FlightRoute? route;
  final Flight? flight;
  final List<AircraftPosition> trail;

  String get primaryIdentifier {
    final routeIdentifier =
        flight?.primaryIdentifier.trim() ?? route?.primaryIdentifier.trim();
    if (routeIdentifier != null && routeIdentifier.isNotEmpty) {
      return routeIdentifier;
    }
    if (state.callsign.trim().isNotEmpty) return state.callsign.trim();
    final registration = identity?.registration?.trim();
    if (registration != null && registration.isNotEmpty) return registration;
    return state.icao24.toUpperCase();
  }
}

class AircraftPosition {
  const AircraftPosition({
    required this.latitude,
    required this.longitude,
    required this.observedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime observedAt;
}
