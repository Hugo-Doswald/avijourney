import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/domain/models/aircraft_state.dart';
import 'package:avijourney/domain/models/flight.dart';
import 'package:avijourney/domain/models/tracked_aircraft.dart';
import 'package:avijourney/domain/repositories/aircraft_repository.dart';
import 'package:avijourney/features/flight_detail/flight_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class EmptyFlightRepository implements AircraftRepository {
  @override
  Future<List<TrackedAircraft>> loadNearby({
    required double centerLatitude,
    required double centerLongitude,
    required double radiusNauticalMiles,
  }) async =>
      const [];
}

void main() {
  testWidgets('Flight Detail renders verified fields and links live aircraft',
      (tester) async {
    final controller = AppController(repository: EmptyFlightRepository());
    addTearDown(controller.dispose);
    var mapOpened = false;
    final tracked = TrackedAircraft(
      state: AircraftState(
        icao24: 'abc123',
        callsign: 'BAW283',
        latitude: 51,
        longitude: 0,
        altitudeFeet: 10000,
        groundSpeedKnots: 200,
        trackDegrees: 90,
        verticalRateFeetPerMinute: 0,
        observedAt: DateTime.utc(2026),
      ),
      flight: const Flight(
        operationalCallsign: 'BAW283',
        commercialFlightNumber: 'BA283',
        airlineName: 'British Airways',
        status: 'Scheduled',
        source: 'Mock verified schedule',
        verificationState: FlightVerificationState.verified,
      ),
    );
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FlightDetailView(
          aircraft: tracked,
          controller: controller,
          onShowOnMap: () => mapOpened = true,
        ),
      ),
    ));

    expect(find.text('BA283'), findsNWidgets(2));
    expect(find.text('British Airways'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Mock verified schedule'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Mock verified schedule'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('showAircraftOnMap')), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('showAircraftOnMap')));
    expect(controller.selectedIcao24, 'abc123');
    expect(mapOpened, isTrue);
  });
}
