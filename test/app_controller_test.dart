import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/data/mock/mock_aircraft_provider.dart';
import 'package:avijourney/data/mock/mock_enrichment_provider.dart';
import 'package:avijourney/data/repositories/mock_aircraft_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller loads mock aircraft and supports selection and range',
      () async {
    final controller = AppController(
        repository: MockAircraftRepository(
            positions: const MockAircraftPositionProvider(),
            enrichment: const MockAircraftEnrichmentProvider()));
    await controller.initialize();
    expect(controller.feedStatus, FeedStatus.live);
    expect(controller.aircraft, isNotEmpty);
    controller.select(controller.aircraft.first.state.icao24);
    expect(controller.selectedIcao24, controller.aircraft.first.state.icao24);
    controller.setRadarRange(80);
    expect(controller.settings.radarRangeNm, 80);
  });
}
