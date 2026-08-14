import '../models/tracked_aircraft.dart';

abstract interface class AircraftRepository {
  Future<List<TrackedAircraft>> loadNearby({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  });
}
