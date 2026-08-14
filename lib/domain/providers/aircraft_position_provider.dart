import '../models/aircraft_state.dart';

abstract interface class AircraftPositionProvider {
  Future<List<AircraftState>> fetchAircraft({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  });
}
