import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/domain/models/aircraft_state.dart';
import 'package:avijourney/domain/models/app_settings.dart';
import 'package:avijourney/domain/models/tracked_aircraft.dart';
import 'package:avijourney/domain/models/tracking_center.dart';
import 'package:avijourney/domain/repositories/aircraft_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingRepository implements AircraftRepository {
  final List<({double latitude, double longitude, double range})> requests = [];
  var observation = 0;

  @override
  Future<List<TrackedAircraft>> loadNearby({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async {
    requests.add((
      latitude: centerLatitude,
      longitude: centerLongitude,
      range: radiusNauticalMiles,
    ));
    observation++;
    return [
      TrackedAircraft(
        state: AircraftState(
          icao24: 'ABC123',
          callsign: 'TEST1',
          latitude: centerLatitude + observation / 1000,
          longitude: centerLongitude,
          altitudeFeet: 10000,
          groundSpeedKnots: 250,
          trackDegrees: 90,
          verticalRateFeetPerMinute: 0,
          observedAt: DateTime.utc(2026, 1, 1, 0, observation),
        ),
      ),
    ];
  }
}

void main() {
  test('tracking centre is injected and used for acquisition', () async {
    final repository = RecordingRepository();
    const centre = TrackingCenter(
      latitude: 55.95,
      longitude: -3.37,
      label: 'Edinburgh',
    );
    final controller =
        AppController(repository: repository, trackingCenter: centre);
    addTearDown(controller.dispose);

    await controller.initialize();

    expect(controller.trackingCenter, same(centre));
    expect(repository.requests.single.latitude, centre.latitude);
    expect(repository.requests.single.longitude, centre.longitude);
  });

  test('range change refreshes acquisition with the new range', () async {
    final repository = RecordingRepository();
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    await controller.setRadarRange(80);

    expect(controller.settings.radarRangeNm, 80);
    expect(repository.requests, hasLength(2));
    expect(repository.requests.last.range, 80);
  });

  test('refresh interval change reschedules the central timer', () async {
    final controller = AppController(repository: RecordingRepository());
    addTearDown(controller.dispose);
    await controller.initialize();
    expect(controller.scheduledRefreshInterval, const Duration(seconds: 60));

    controller.updateSettings(controller.settings
        .copyWith(refreshInterval: const Duration(minutes: 2)));

    expect(controller.scheduledRefreshInterval, const Duration(minutes: 2));
    expect(controller.isRefreshScheduled, isTrue);
    controller.pause();
    expect(controller.isRefreshScheduled, isFalse);
  });

  test('refresh preserves only acquired observations as trail history',
      () async {
    final controller = AppController(repository: RecordingRepository());
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.refresh();

    expect(controller.aircraft.single.trail, hasLength(2));
    expect(controller.aircraft.single.trail.first.latitude,
        isNot(controller.aircraft.single.trail.last.latitude));
  });

  test('settings updates retain non-refresh values', () {
    final controller = AppController(repository: RecordingRepository());
    addTearDown(controller.dispose);
    controller.updateSettings(const AppSettings(showLabels: false));
    expect(controller.settings.showLabels, isFalse);
  });
}
