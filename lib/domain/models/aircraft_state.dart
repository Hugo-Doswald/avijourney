class AircraftState {
  const AircraftState({
    required this.icao24,
    required this.callsign,
    required this.latitude,
    required this.longitude,
    required this.altitudeFeet,
    required this.groundSpeedKnots,
    required this.trackDegrees,
    required this.verticalRateFeetPerMinute,
    this.squawk,
    this.onGround = false,
    required this.observedAt,
  });

  final String icao24;
  final String callsign;
  final double latitude;
  final double longitude;
  final double altitudeFeet;
  final double groundSpeedKnots;
  final double trackDegrees;
  final double verticalRateFeetPerMinute;
  final String? squawk;
  final bool onGround;
  final DateTime observedAt;
}
