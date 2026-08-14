import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_controller.dart';
import '../../app/mapping/map_tile_source.dart';
import '../../app/mapping/map_viewport_controller.dart';
import '../../domain/models/tracked_aircraft.dart';
import '../aircraft_detail/aircraft_detail_sheet.dart';

class AircraftMapView extends StatefulWidget {
  const AircraftMapView({
    required this.controller,
    required this.viewportController,
    required this.tileSource,
    this.showTiles = true,
    this.mapController,
    super.key,
  });

  final AppController controller;
  final MapViewportController viewportController;
  final MapTileSource tileSource;
  final bool showTiles;
  final MapController? mapController;

  @override
  State<AircraftMapView> createState() => _AircraftMapViewState();
}

class _AircraftMapViewState extends State<AircraftMapView>
    with AutomaticKeepAliveClientMixin {
  late final MapController _mapController =
      widget.mapController ?? MapController();
  late double _zoom = widget.viewportController.viewport.zoom;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final viewport = widget.viewportController.viewport;
    return ColoredBox(
      color: const Color(0xFF07150D),
      child: FlutterMap(
        key: const Key('aircraftGeographicMap'),
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(viewport.latitude, viewport.longitude),
          initialZoom: viewport.zoom,
          minZoom: 3,
          maxZoom: 19,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.doubleTapZoom |
                InteractiveFlag.flingAnimation,
          ),
          onPositionChanged: (camera, _) {
            widget.viewportController.update(MapViewport(
              latitude: camera.center.latitude,
              longitude: camera.center.longitude,
              zoom: camera.zoom,
            ));
            if ((_zoom >= 9) != (camera.zoom >= 9)) {
              setState(() => _zoom = camera.zoom);
            } else {
              _zoom = camera.zoom;
            }
          },
        ),
        children: [
          if (widget.showTiles)
            TileLayer(
              urlTemplate: widget.tileSource.urlTemplate,
              userAgentPackageName: widget.tileSource.userAgentPackageName,
              maxNativeZoom: widget.tileSource.maximumNativeZoom,
              tileBuilder: darkModeTileBuilder,
            ),
          MarkerLayer(
            markers: buildAircraftMapMarkers(
              context: context,
              aircraft: widget.controller.visibleAircraft,
              selectedIcao24: widget.controller.selectedIcao24,
              showLabels: _zoom >= 9,
              onTap: _selectAircraft,
            ),
          ),
          RichAttributionWidget(
            popupBackgroundColor: const Color(0xEE09150E),
            showFlutterMapAttribution: false,
            attributions: [
              TextSourceAttribution(
                widget.tileSource.attributionText,
                onTap: () => unawaited(launchUrl(
                  widget.tileSource.attributionUri,
                  mode: LaunchMode.externalApplication,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectAircraft(TrackedAircraft aircraft) {
    widget.controller.select(aircraft.state.icao24);
    showAircraftDetail(context, aircraft, widget.controller);
  }
}

List<Marker> buildAircraftMapMarkers({
  required BuildContext context,
  required List<TrackedAircraft> aircraft,
  required String? selectedIcao24,
  required bool showLabels,
  required ValueChanged<TrackedAircraft> onTap,
}) =>
    aircraft.map((item) {
      final selected = item.state.icao24 == selectedIcao24;
      return Marker(
        key: ValueKey('mapMarker-${item.state.icao24}'),
        point: LatLng(item.state.latitude, item.state.longitude),
        width: selected || showLabels ? 112 : 48,
        height: selected || showLabels ? 62 : 48,
        child: AircraftMapMarker(
          aircraft: item,
          selected: selected,
          showLabel: selected || showLabels,
          onTap: () => onTap(item),
        ),
      );
    }).toList(growable: false);

class AircraftMapMarker extends StatelessWidget {
  const AircraftMapMarker({
    required this.aircraft,
    required this.selected,
    required this.showLabel,
    required this.onTap,
    super.key,
  });

  final TrackedAircraft aircraft;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final markerColor = selected
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: '${aircraft.primaryIdentifier} aircraft marker',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: aircraft.state.trackDegrees * math.pi / 180,
              child: Container(
                key: ValueKey('mapMarkerIcon-${aircraft.state.icao24}'),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xE609150E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: markerColor,
                    width: selected ? 3 : 1.5,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: markerColor, blurRadius: 9)]
                      : null,
                ),
                child: Icon(Icons.navigation, color: markerColor, size: 18),
              ),
            ),
            if (showLabel)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xE609150E),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  aircraft.primaryIdentifier,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: markerColor,
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
