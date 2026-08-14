import 'airport.dart';

enum FlightVerificationState { verified, unresolved, unverified }

class Flight {
  const Flight({
    required this.operationalCallsign,
    this.commercialFlightNumber,
    this.airlineIataCode,
    this.airlineIcaoCode,
    this.airlineName,
    this.origin,
    this.destination,
    this.scheduledDeparture,
    this.scheduledArrival,
    this.estimatedDeparture,
    this.estimatedArrival,
    this.actualDeparture,
    this.actualArrival,
    this.status,
    this.aircraftRegistration,
    this.aircraftIcao24,
    this.aircraftType,
    this.source,
    this.verificationState = FlightVerificationState.unresolved,
  });

  final String operationalCallsign;
  final String? commercialFlightNumber;
  final String? airlineIataCode;
  final String? airlineIcaoCode;
  final String? airlineName;
  final Airport? origin;
  final Airport? destination;
  final DateTime? scheduledDeparture;
  final DateTime? scheduledArrival;
  final DateTime? estimatedDeparture;
  final DateTime? estimatedArrival;
  final DateTime? actualDeparture;
  final DateTime? actualArrival;
  final String? status;
  final String? aircraftRegistration;
  final String? aircraftIcao24;
  final String? aircraftType;
  final String? source;
  final FlightVerificationState verificationState;

  bool get isCommercialIdentityVerified =>
      verificationState == FlightVerificationState.verified &&
      commercialFlightNumber?.trim().isNotEmpty == true;

  String get primaryIdentifier {
    if (isCommercialIdentityVerified) return commercialFlightNumber!.trim();
    if (operationalCallsign.trim().isNotEmpty) {
      return operationalCallsign.trim();
    }
    if (aircraftRegistration?.trim().isNotEmpty == true) {
      return aircraftRegistration!.trim();
    }
    return aircraftIcao24?.toUpperCase() ?? 'Unknown flight';
  }
}
