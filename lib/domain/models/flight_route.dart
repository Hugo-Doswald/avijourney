import 'airport.dart';

class FlightRoute {
  const FlightRoute({
    required this.callsign,
    this.commercialFlightNumber,
    this.origin,
    this.destination,
    this.source,
    this.verified = false,
  });

  final String callsign;
  final String? commercialFlightNumber;
  final Airport? origin;
  final Airport? destination;
  final String? source;
  final bool verified;

  String get primaryIdentifier {
    final commercial = commercialFlightNumber;
    if (verified && commercial != null && commercial.isNotEmpty) {
      return commercial;
    }
    return callsign;
  }
}
