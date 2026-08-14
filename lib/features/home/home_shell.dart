import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/mapping/map_tile_source.dart';
import '../../app/mapping/map_viewport_controller.dart';
import '../cards/aircraft_cards_view.dart';
import '../filters/settings_sheet.dart';
import '../map/aircraft_map_view.dart';
import '../radar/radar_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.controller,
    required this.mapViewportController,
    required this.mapTileSource,
    this.showMapTiles = true,
    super.key,
  });

  final AppController controller;
  final MapViewportController mapViewportController;
  final MapTileSource mapTileSource;
  final bool showMapTiles;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.radar), label: 'Radar'),
    NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
    NavigationDestination(
        icon: Icon(Icons.view_agenda_outlined), label: 'Cards'),
    NavigationDestination(
        icon: Icon(Icons.bookmark_border),
        selectedIcon: Icon(Icons.bookmark),
        label: 'Saved'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final pages = <Widget>[
          RadarView(controller: widget.controller),
          AircraftMapView(
            controller: widget.controller,
            viewportController: widget.mapViewportController,
            tileSource: widget.mapTileSource,
            showTiles: widget.showMapTiles,
          ),
          AircraftCardsView(controller: widget.controller),
          AircraftCardsView(controller: widget.controller, savedOnly: true),
        ];
        final wide = MediaQuery.sizeOf(context).width >= 700;
        final content = IndexedStack(index: _index, children: pages);
        return Scaffold(
          appBar: AppBar(
            title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AVIJOURNEY',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, letterSpacing: 1.8)),
                  Text('V0.3.0 · MILESTONE 1',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.2)),
                ]),
            actions: [
              _StatusBadge(status: widget.controller.feedStatus),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                      child: Text(
                          '${widget.controller.visibleAircraft.length} visible'))),
              IconButton(
                  tooltip: 'Filters and settings',
                  onPressed: () =>
                      showSettingsSheet(context, widget.controller),
                  icon: const Icon(Icons.tune)),
            ],
          ),
          body: SafeArea(
            child: wide
                ? Row(children: [
                    NavigationRail(
                        selectedIndex: _index,
                        onDestinationSelected: (value) =>
                            setState(() => _index = value),
                        labelType: NavigationRailLabelType.all,
                        destinations: _destinations
                            .map((item) => NavigationRailDestination(
                                icon: item.icon,
                                selectedIcon: item.selectedIcon,
                                label: Text(item.label)))
                            .toList()),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ])
                : content,
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (value) =>
                      setState(() => _index = value),
                  destinations: _destinations),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final FeedStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      FeedStatus.connecting => 'CONNECTING',
      FeedStatus.live => 'MOCK LIVE',
      FeedStatus.cached => 'CACHED',
      FeedStatus.offline => 'OFFLINE',
      FeedStatus.rateLimited => 'RATE LIMITED',
      FeedStatus.error => 'FEED ERROR',
    };
    return Center(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.circular(20)),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold))));
  }
}
