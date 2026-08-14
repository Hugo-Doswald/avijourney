import 'package:avijourney/app/app.dart';
import 'package:avijourney/app/app_controller.dart';
import 'package:avijourney/app/mapping/map_viewport_controller.dart';
import 'package:avijourney/data/mapping/open_street_map_tile_source.dart';
import 'package:avijourney/data/mock/mock_aircraft_provider.dart';
import 'package:avijourney/data/mock/mock_enrichment_provider.dart';
import 'package:avijourney/data/repositories/mock_aircraft_repository.dart';
import 'package:avijourney/features/map/aircraft_map_view.dart';
import 'package:avijourney/domain/models/tracking_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

AppController createController() => AppController(
      repository: MockAircraftRepository(
        positions: const MockAircraftPositionProvider(),
        enrichment: const MockAircraftEnrichmentProvider(),
      ),
    );

void main() {
  testWidgets('map renders mock markers at aircraft geographic coordinates',
      (tester) async {
    final controller = createController();
    addTearDown(controller.dispose);
    await controller.refresh();
    final viewport = MapViewportController(
      MapViewport.around(controller.trackingCenter),
    );
    addTearDown(viewport.dispose);

    await tester.pumpWidget(MaterialApp(
      home: AircraftMapView(
        controller: controller,
        viewportController: viewport,
        tileSource: const OpenStreetMapTileSource(),
        showTiles: false,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('aircraftGeographicMap')), findsOneWidget);
    final markerLayer = tester
        .widgetList<MarkerLayer>(find.byType(MarkerLayer))
        .firstWhere((layer) =>
            layer.markers.length == controller.visibleAircraft.length);
    expect(markerLayer.markers, hasLength(controller.visibleAircraft.length));
    for (var index = 0; index < markerLayer.markers.length; index++) {
      expect(markerLayer.markers[index].point.latitude,
          controller.visibleAircraft[index].state.latitude);
      expect(markerLayer.markers[index].point.longitude,
          controller.visibleAircraft[index].state.longitude);
    }
  });

  testWidgets('tapping a marker selects it and exposes aircraft detail',
      (tester) async {
    final controller = createController();
    addTearDown(controller.dispose);
    await controller.refresh();
    final viewport = MapViewportController(
      MapViewport.around(controller.trackingCenter),
    );
    addTearDown(viewport.dispose);
    final target = controller.visibleAircraft.first;

    await tester.pumpWidget(MaterialApp(
      home: AircraftMapView(
        controller: controller,
        viewportController: viewport,
        tileSource: const OpenStreetMapTileSource(),
        showTiles: false,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate(
      (widget) =>
          widget is AircraftMapMarker &&
          widget.aircraft.state.icao24 == target.state.icao24,
    ));
    await tester.pumpAndSettle();

    expect(controller.selectedIcao24, target.state.icao24);
    expect(find.text('AIRCRAFT'), findsOneWidget);
  });

  testWidgets('selected aircraft marker exposes selected visual state',
      (tester) async {
    final controller = createController();
    addTearDown(controller.dispose);
    await controller.refresh();
    final target = controller.visibleAircraft.first;
    controller.select(target.state.icao24);
    final viewport = MapViewportController(
      MapViewport.around(controller.trackingCenter),
    );
    addTearDown(viewport.dispose);

    await tester.pumpWidget(MaterialApp(
      home: AircraftMapView(
        controller: controller,
        viewportController: viewport,
        tileSource: const OpenStreetMapTileSource(),
        showTiles: false,
      ),
    ));
    await tester.pumpAndSettle();

    final selectedMarker = tester.widget<AircraftMapMarker>(
      find.byWidgetPredicate(
        (widget) => widget is AircraftMapMarker && widget.selected,
      ),
    );
    expect(selectedMarker.aircraft.state.icao24, target.state.icao24);
  });

  testWidgets('map viewport survives navigation across all existing tabs',
      (tester) async {
    final viewport = MapViewportController(const MapViewport(
      latitude: 51.47,
      longitude: -0.4543,
      zoom: 9,
    ));
    addTearDown(viewport.dispose);
    await tester.pumpWidget(AviJourneyApp(
      mapViewportController: viewport,
      showMapTiles: false,
      useLiveData: false,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    await tester.drag(
        find.byKey(const Key('aircraftGeographicMap')), const Offset(80, 35));
    await tester.pumpAndSettle();
    final movedViewport = viewport.viewport;
    expect(movedViewport.latitude, isNot(51.47));

    for (final tab in ['Cards', 'Saved', 'Radar', 'Map']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
    }

    expect(viewport.viewport.latitude, movedViewport.latitude);
    expect(viewport.viewport.longitude, movedViewport.longitude);
    expect(viewport.viewport.zoom, movedViewport.zoom);
    expect(find.byKey(const Key('aircraftGeographicMap')), findsOneWidget);
  });

  testWidgets('long press selects a map tracking centre', (tester) async {
    final controller = createController();
    addTearDown(controller.dispose);
    await controller.refresh();
    final viewport = MapViewportController(
      MapViewport.around(controller.trackingCenter),
    );
    addTearDown(viewport.dispose);

    await tester.pumpWidget(MaterialApp(
      home: AircraftMapView(
        controller: controller,
        viewportController: viewport,
        tileSource: const OpenStreetMapTileSource(),
        showTiles: false,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('aircraftGeographicMap')));
    await tester.pump();

    expect(controller.trackingCenter.type, TrackingCenterType.map);
    expect(find.byKey(const Key('trackingCenterMarker')), findsOneWidget);
    expect(find.byKey(const Key('recenterMapButton')), findsOneWidget);
  });
}
