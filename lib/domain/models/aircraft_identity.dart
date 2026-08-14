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
