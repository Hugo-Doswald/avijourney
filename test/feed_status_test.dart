import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/core/errors/provider_exception.dart';
import 'package:avijourney/domain/models/aircraft_state.dart';
import 'package:avijourney/domain/models/tracked_aircraft.dart';
import 'package:avijourney/domain/repositories/aircraft_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class SequencedRepository implements AircraftRepository {
  Object? nextError;

  @override
  Future<List<TrackedAircraft>> loadNearby({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async {
    final error = nextError;
    if (error != null) throw error;
    return [
      TrackedAircraft(
        state: AircraftState(
          icao24: 'abc123',
          callsign: 'TEST',
          latitude: centerLatitude,
          longitude: centerLongitude,
          altitudeFeet: 1000,
          groundSpeedKnots: 100,
          trackDegrees: 0,
          verticalRateFeetPerMinute: 0,
          observedAt: DateTime.utc(2026),
        ),
      ),
    ];
  }
}

void main() {
  test('temporary failures preserve the last valid snapshot and expose status',
      () async {
    final repository = SequencedRepository();
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);

    await controller.refresh();
    expect(controller.feedStatus, FeedStatus.live);
    final snapshot = controller.aircraft.single;

    repository.nextError = const ProviderException(
        ProviderErrorType.networkUnavailable, 'offline');
    await controller.refresh();
    expect(controller.feedStatus, FeedStatus.offline);
    expect(controller.aircraft.single.state.icao24, snapshot.state.icao24);

    repository.nextError =
        const ProviderException(ProviderErrorType.rateLimited, 'limited');
    await controller.refresh();
    expect(controller.feedStatus, FeedStatus.rateLimited);

    repository.nextError = StateError('provider error');
    await controller.refresh();
    expect(controller.feedStatus, FeedStatus.cached);
    expect(controller.aircraft, hasLength(1));
  });
}
