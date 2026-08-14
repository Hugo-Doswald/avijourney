import 'airport.dart';

class FlightRoute {
  const FlightRoute({
    required this.callsign,
    this.origin,
    this.destination,
    this.source,
  });

  final String callsign;
  final Airport? origin;
  final Airport? destination;
  final String? source;
  String get primaryIdentifier => callsign;
}
