import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/models/app_settings.dart';
import '../domain/models/tracked_aircraft.dart';
import '../domain/models/tracking_center.dart';
import '../domain/repositories/aircraft_repository.dart';

enum FeedStatus { connecting, live, cached, offline, rateLimited, error }

class AppController extends ChangeNotifier {
  AppController({
    required AircraftRepository repository,
    TrackingCenter trackingCenter = TrackingCenter.heathrow,
  })  : _repository = repository,
        _trackingCenter = trackingCenter;

  final AircraftRepository _repository;
  TrackingCenter _trackingCenter;
  List<TrackedAircraft> _aircraft = const [];
  AppSettings _settings = const AppSettings();
  FeedStatus _feedStatus = FeedStatus.connecting;
  String? _selectedIcao24;
  final Set<String> _saved = <String>{};
  Timer? _refreshTimer;
  Future<void>? _activeRefresh;
  Duration? _scheduledRefreshInterval;
  bool _isActive = true;

  List<TrackedAircraft> get aircraft => List.unmodifiable(_aircraft);
  AppSettings get settings => _settings;
  TrackingCenter get trackingCenter => _trackingCenter;
  FeedStatus get feedStatus => _feedStatus;
  String? get selectedIcao24 => _selectedIcao24;
  Set<String> get saved => Set.unmodifiable(_saved);
  Duration? get scheduledRefreshInterval => _scheduledRefreshInterval;
  bool get isRefreshScheduled => _refreshTimer?.isActive ?? false;

  List<TrackedAircraft> get visibleAircraft => _aircraft.where((aircraft) {
        final altitude = aircraft.state.altitudeFeet;
        return altitude >= _settings.minimumAltitudeFeet &&
            altitude <= _settings.maximumAltitudeFeet &&
            (!_settings.savedOnly || _saved.contains(aircraft.state.icao24));
      }).toList(growable: false);

  Future<void> initialize() async {
    await refresh();
    _scheduleRefresh();
  }

  Future<void> refresh() {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) return activeRefresh;
    final operation = _performRefresh();
    _activeRefresh = operation;
    return operation.whenComplete(() {
      if (identical(_activeRefresh, operation)) _activeRefresh = null;
    });
  }

  Future<void> _performRefresh() async {
    try {
      final result = await _repository.loadNearby(
        centerLatitude: _trackingCenter.latitude,
        centerLongitude: _trackingCenter.longitude,
        radiusNauticalMiles: _settings.radarRangeNm.toDouble(),
      );
      _aircraft = _mergeObservedHistory(result);
      _feedStatus = FeedStatus.live;
    } catch (_) {
      _feedStatus = _aircraft.isEmpty ? FeedStatus.error : FeedStatus.cached;
    }
    notifyListeners();
  }

  List<TrackedAircraft> _mergeObservedHistory(List<TrackedAircraft> incoming) {
    final previousByIcao = {
      for (final item in _aircraft) item.state.icao24: item,
    };
    return incoming.map((item) {
      final previousTrail =
          previousByIcao[item.state.icao24]?.trail ?? const [];
      final currentPosition = AircraftPosition(
        latitude: item.state.latitude,
        longitude: item.state.longitude,
        observedAt: item.state.observedAt,
      );
      final alreadyObserved = previousTrail.isNotEmpty &&
          previousTrail.last.observedAt == currentPosition.observedAt;
      final trail = alreadyObserved
          ? previousTrail
          : <AircraftPosition>[...previousTrail, currentPosition];
      return TrackedAircraft(
        state: item.state,
        identity: item.identity,
        route: item.route,
        trail: trail.length <= 30 ? trail : trail.sublist(trail.length - 30),
      );
    }).toList(growable: false);
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _scheduledRefreshInterval = null;
    if (!_isActive) return;
    _scheduledRefreshInterval = _settings.refreshInterval;
    _refreshTimer = Timer.periodic(_settings.refreshInterval, (_) => refresh());
  }

  Future<void> setTrackingCenter(TrackingCenter center) async {
    _trackingCenter = center;
    notifyListeners();
    await _refreshAfterCurrent();
  }

  void select(String? icao24) {
    _selectedIcao24 = icao24;
    notifyListeners();
  }

  Future<void> setRadarRange(int range) async {
    if (range == _settings.radarRangeNm) return;
    _settings = _settings.copyWith(radarRangeNm: range);
    notifyListeners();
    await _refreshAfterCurrent();
  }

  void updateSettings(AppSettings settings) {
    final refreshIntervalChanged =
        settings.refreshInterval != _settings.refreshInterval;
    final radarRangeChanged = settings.radarRangeNm != _settings.radarRangeNm;
    _settings = settings;
    if (refreshIntervalChanged) _scheduleRefresh();
    notifyListeners();
    if (radarRangeChanged) unawaited(_refreshAfterCurrent());
  }

  Future<void> _refreshAfterCurrent() async {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) await activeRefresh;
    await refresh();
  }

  void pause() {
    _isActive = false;
    _scheduleRefresh();
  }

  Future<void> resume() async {
    if (_isActive) return;
    _isActive = true;
    await refresh();
    _scheduleRefresh();
  }

  void toggleSaved(String icao24) {
    if (!_saved.add(icao24)) _saved.remove(icao24);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
