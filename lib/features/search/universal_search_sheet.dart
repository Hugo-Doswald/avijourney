import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../domain/models/airline.dart';
import '../../domain/models/airport.dart';
import '../../domain/models/followed_item.dart';
import '../../domain/models/search_result.dart';
import '../../domain/models/tracked_aircraft.dart';
import '../aircraft_detail/aircraft_detail_sheet.dart';
import '../flight_detail/flight_detail_sheet.dart';

Future<void> showUniversalSearch(
  BuildContext context,
  AppController controller, {
  required VoidCallback onShowOnMap,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: .92,
        child: _UniversalSearchSheet(
          controller: controller,
          onShowOnMap: onShowOnMap,
        ),
      ),
    );

class _UniversalSearchSheet extends StatefulWidget {
  const _UniversalSearchSheet(
      {required this.controller, required this.onShowOnMap});
  final AppController controller;
  final VoidCallback onShowOnMap;

  @override
  State<_UniversalSearchSheet> createState() => _UniversalSearchSheetState();
}

class _UniversalSearchSheetState extends State<_UniversalSearchSheet> {
  final _query = TextEditingController();
  List<SearchResult> _results = const [];

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _submit([String? value]) => setState(() {
        _results = widget.controller.search(value ?? _query.text);
      });

  @override
  Widget build(BuildContext context) {
    final grouped = <SearchResultType, List<SearchResult>>{};
    for (final result in _results) {
      grouped.putIfAbsent(result.type, () => []).add(result);
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              key: const Key('universalSearchField'),
              controller: _query,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'Flight, aircraft, airline, route or airport',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                    tooltip: 'Search',
                    onPressed: _submit,
                    icon: const Icon(Icons.arrow_forward)),
              ),
            ),
          ),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close)),
        ]),
      ),
      Expanded(
        child: _results.isEmpty
            ? const Center(child: Text('Submit one search across AviJourney'))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  for (final type in SearchResultType.values)
                    if (grouped[type]?.isNotEmpty == true) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 4),
                        child: Text(_heading(type),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2)),
                      ),
                      ...grouped[type]!.map(_tile),
                    ],
                ],
              ),
      ),
    ]);
  }

  Widget _tile(SearchResult result) {
    final followed = _followed(result);
    return Card(
      child: ListTile(
        title: Text(result.title),
        subtitle: Text('${result.subtitle}\n${result.matchReason}'),
        isThreeLine: true,
        trailing: IconButton(
          tooltip: followed != null && widget.controller.isFollowing(followed)
              ? 'Unfollow'
              : 'Follow',
          onPressed: followed == null
              ? null
              : () =>
                  setState(() => widget.controller.toggleFollowed(followed)),
          icon: Icon(followed != null && widget.controller.isFollowing(followed)
              ? Icons.bookmark
              : Icons.bookmark_border),
        ),
        onTap: () {
          final tracked = result.value;
          if (tracked is TrackedAircraft) {
            if (result.type == SearchResultType.flight) {
              showFlightDetail(context, tracked, widget.controller,
                  onShowOnMap: widget.onShowOnMap);
            } else {
              widget.controller.select(tracked.state.icao24);
              showAircraftDetail(context, tracked, widget.controller);
            }
          }
        },
      ),
    );
  }

  FollowedItem? _followed(SearchResult result) {
    final type = switch (result.type) {
      SearchResultType.aircraft => FollowedItemType.aircraft,
      SearchResultType.flight => FollowedItemType.flight,
      SearchResultType.airline => FollowedItemType.airline,
      SearchResultType.route => FollowedItemType.route,
      SearchResultType.airport => FollowedItemType.airport,
    };
    final value = result.value;
    final identifier = value is Airline
        ? value.identifier
        : value is Airport
            ? value.icao
            : result.identifier;
    return FollowedItem(
        type: type,
        identifier: identifier,
        label: result.title,
        subtitle: result.subtitle);
  }

  String _heading(SearchResultType type) => switch (type) {
        SearchResultType.flight => 'FLIGHTS',
        SearchResultType.aircraft => 'AIRCRAFT',
        SearchResultType.airline => 'AIRLINES',
        SearchResultType.route => 'ROUTES',
        SearchResultType.airport => 'AIRPORTS',
      };
}
