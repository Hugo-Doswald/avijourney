import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/app/persistence/app_preferences_store.dart';
import 'package:avijourney/data/local/static_airport_search_provider.dart';
import 'package:avijourney/domain/models/tracked_aircraft.dart';
import 'package:avijourney/domain/models/tracking_center.dart';
import 'package:avijourney/domain/providers/device_location_provider.dart';
import 'package:avijourney/domain/repositories/aircraft_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class EmptyRepository implements AircraftRepository {
  @override
  Future<List<TrackedAircraft>> loadNearby({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async =>
      const [];
}

class MemoryPreferencesStore implements AppPreferencesStore {
  PersistedAppState? state;

  @override
  Future<PersistedAppState?> load() async => state;

  @override
  Future<void> save(PersistedAppState state) async => this.state = state;
}

class FixedLocationProvider implements DeviceLocationProvider {
  const FixedLocationProvider(this.result);
  final DeviceLocationResult result;

  @override
  Future<DeviceLocationResult> getCurrentLocation() async => result;
}

void main() {
  test('tracking centre, settings, and saved aircraft persist across restart',
      () async {
    final store = MemoryPreferencesStore();
    final first = AppController(
      repository: EmptyRepository(),
      preferencesStore: store,
    );
    addTearDown(first.dispose);
    await first.refresh();
    await first.setTrackingCenter(const TrackingCenter(
      latitude: 55.95,
      longitude: -3.37,
      label: 'Edinburgh',
      type: TrackingCenterType.map,
    ));
    await first.setRadarRange(80);
    first.toggleSaved('abc123');
    await Future<void>.delayed(Duration.zero);

    final second = AppController(
      repository: EmptyRepository(),
      preferencesStore: store,
    );
    addTearDown(second.dispose);
    await second.initialize();
    second.pause();

    expect(second.trackingCenter.label, 'Edinburgh');
    expect(second.trackingCenter.type, TrackingCenterType.map);
    expect(second.settings.radarRangeNm, 80);
    expect(second.saved, contains('abc123'));
  });

  test('current-location permission failure leaves tracking centre unchanged',
      () async {
    final controller = AppController(
      repository: EmptyRepository(),
      deviceLocationProvider: const FixedLocationProvider(
        DeviceLocationResult.failure(DeviceLocationStatus.permissionDenied),
      ),
    );
    addTearDown(controller.dispose);

    final status = await controller.useCurrentLocation();

    expect(status, DeviceLocationStatus.permissionDenied);
    expect(controller.trackingCenter, TrackingCenter.heathrow);
    expect(controller.locationMessage, contains('denied'));
  });

  test('airport search and selection update the shared tracking centre',
      () async {
    final controller = AppController(
      repository: EmptyRepository(),
      airportSearchProvider: const StaticAirportSearchProvider(),
    );
    addTearDown(controller.dispose);

    final airports = controller.searchAirports('Manchester');
    await controller.chooseAirport(airports.single);

    expect(controller.trackingCenter.type, TrackingCenterType.airport);
    expect(controller.trackingCenter.label, contains('MAN'));
    expect(controller.trackingCenter.latitude, closeTo(53.3537, .0001));
  });
}
