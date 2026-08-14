import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/domain/models/tracked_aircraft.dart';
import 'package:avijourney/domain/repositories/aircraft_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FailingRepository implements AircraftRepository {
  @override
  Future<List<TrackedAircraft>> loadNearby(
          {required double centerLatitude,
          required double centerLongitude,
          required double radiusNauticalMiles}) =>
      throw StateError('offline');
}

void main() {
  test('provider failure becomes visible state instead of throwing', () async {
    final controller = AppController(repository: FailingRepository());
    await controller.initialize();
    expect(controller.feedStatus, FeedStatus.error);
    expect(controller.aircraft, isEmpty);
  });
}
