import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/errors/provider_exception.dart';
import '../domain/models/airport.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/tracked_aircraft.dart';
import '../domain/models/tracking_center.dart';
import '../domain/providers/airport_search_provider.dart';
import '../domain/providers/device_location_provider.dart';
import '../domain/repositories/aircraft_repository.dart';
import 'persistence/app_preferences_store.dart';

enum FeedStatus { connecting, live, cached, offline, rateLimited, error }

class AppController extends ChangeNotifier {
  AppController({
    required AircraftRepository repository,
    TrackingCenter trackingCenter = TrackingCenter.heathrow,
    AppPreferencesStore preferencesStore = const NoOpAppPreferencesStore(),
    DeviceLocationProvider? deviceLocationProvider,
    AirportSearchProvider? airportSearchProvider,
    this.feedName = 'OpenSky',
  })  : _repository = repository,
        _trackingCenter = trackingCenter,
        _preferencesStore = preferencesStore,
        _deviceLocationProvider = deviceLocationProvider,
        _airportSearchProvider = airportSearchProvider;

  static const minimumRefreshInterval = Duration(seconds: 30);
  final AircraftRepository _repository;
  final AppPreferencesStore _preferencesStore;
  final DeviceLocationProvider? _deviceLocationProvider;
  final AirportSearchProvider? _airportSearchProvider;
  final String feedName;
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
  bool _isChoosingCenterOnMap = false;
  String? _locationMessage;

  List<TrackedAircraft> get aircraft => List.unmodifiable(_aircraft);
  AppSettings get settings => _settings;
  TrackingCenter get trackingCenter => _trackingCenter;
  FeedStatus get feedStatus => _feedStatus;
  String? get selectedIcao24 => _selectedIcao24;
  Set<String> get saved => Set.unmodifiable(_saved);
  Duration? get scheduledRefreshInterval => _scheduledRefreshInterval;
  bool get isRefreshScheduled => _refreshTimer?.isActive ?? false;
  bool get isChoosingCenterOnMap => _isChoosingCenterOnMap;
  String? get locationMessage => _locationMessage;

  List<TrackedAircraft> get visibleAircraft => _aircraft.where((aircraft) {
        final altitude = aircraft.state.altitudeFeet;
        return altitude >= _settings.minimumAltitudeFeet &&
            altitude <= _settings.maximumAltitudeFeet &&
            (!_settings.savedOnly || _saved.contains(aircraft.state.icao24));
      }).toList(growable: false);

  Future<void> initialize() async {
    try {
      final persisted = await _preferencesStore.load();
      if (persisted != null) {
        _trackingCenter = persisted.trackingCenter;
        _settings = persisted.settings;
        _saved
          ..clear()
          ..addAll(persisted.savedAircraft);
        notifyListeners();
      }
    } catch (_) {
      // Local persistence failure must not prevent the app shell or live feed.
    }
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
    if (_aircraft.isEmpty) {
      _feedStatus = FeedStatus.connecting;
      notifyListeners();
    }
    try {
      final result = await _repository.loadNearby(
        centerLatitude: _trackingCenter.latitude,
        centerLongitude: _trackingCenter.longitude,
        radiusNauticalMiles: _settings.radarRangeNm.toDouble(),
      );
      _aircraft = _mergeObservedHistory(result);
      _feedStatus = FeedStatus.live;
    } on ProviderException catch (error) {
      _feedStatus = switch (error.type) {
        ProviderErrorType.networkUnavailable ||
        ProviderErrorType.timeout =>
          FeedStatus.offline,
        ProviderErrorType.rateLimited => FeedStatus.rateLimited,
        _ => _aircraft.isEmpty ? FeedStatus.error : FeedStatus.cached,
      };
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

  Duration get _effectiveRefreshInterval =>
      _settings.refreshInterval < minimumRefreshInterval
          ? minimumRefreshInterval
          : _settings.refreshInterval;

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _scheduledRefreshInterval = null;
    if (!_isActive) return;
    _scheduledRefreshInterval = _effectiveRefreshInterval;
    _refreshTimer = Timer.periodic(_effectiveRefreshInterval, (_) => refresh());
  }

  Future<void> setTrackingCenter(TrackingCenter center) async {
    _trackingCenter = center;
    _isChoosingCenterOnMap = false;
    _locationMessage = null;
    notifyListeners();
    unawaited(_persist());
    await _refreshAfterCurrent();
  }

  Future<DeviceLocationStatus> useCurrentLocation() async {
    final provider = _deviceLocationProvider;
    if (provider == null) {
      _locationMessage = 'Current location is unavailable on this device.';
      notifyListeners();
      return DeviceLocationStatus.unavailable;
    }
    final result = await provider.getCurrentLocation();
    if (result.status == DeviceLocationStatus.available) {
      await setTrackingCenter(TrackingCenter(
        latitude: result.latitude!,
        longitude: result.longitude!,
        label: 'Current location',
        type: TrackingCenterType.device,
      ));
    } else {
      _locationMessage = switch (result.status) {
        DeviceLocationStatus.serviceDisabled =>
          'Location services are disabled.',
        DeviceLocationStatus.permissionDenied =>
          'Location permission was denied.',
        DeviceLocationStatus.permissionDeniedForever =>
          'Location permission is permanently denied. Enable it in system settings.',
        _ => 'Current location could not be determined.',
      };
      notifyListeners();
    }
    return result.status;
  }

  List<Airport> searchAirports(String query) =>
      _airportSearchProvider?.search(query) ?? const [];

  Future<void> chooseAirport(Airport airport) async {
    if (airport.latitude == null || airport.longitude == null) return;
    await setTrackingCenter(TrackingCenter(
      latitude: airport.latitude!,
      longitude: airport.longitude!,
      label: '${airport.displayCode} · ${airport.name}',
      type: TrackingCenterType.airport,
    ));
  }

  void beginMapCenterSelection() {
    _isChoosingCenterOnMap = true;
    notifyListeners();
  }

  void cancelMapCenterSelection() {
    _isChoosingCenterOnMap = false;
    notifyListeners();
  }

  void select(String? icao24) {
    _selectedIcao24 = icao24;
    notifyListeners();
  }

  Future<void> setRadarRange(int range) async {
    if (range == _settings.radarRangeNm) return;
    _settings = _settings.copyWith(radarRangeNm: range);
    notifyListeners();
    unawaited(_persist());
    await _refreshAfterCurrent();
  }

  void updateSettings(AppSettings settings) {
    final refreshIntervalChanged =
        settings.refreshInterval != _settings.refreshInterval;
    final radarRangeChanged = settings.radarRangeNm != _settings.radarRangeNm;
    _settings = settings;
    if (refreshIntervalChanged) _scheduleRefresh();
    notifyListeners();
    unawaited(_persist());
    if (radarRangeChanged) unawaited(_refreshAfterCurrent());
  }

  Future<void> _refreshAfterCurrent() async {
    final activeRefresh = _activeRefresh;
    if (activeRefresh != null) await activeRefresh;
    await refresh();
  }

  Future<void> _persist() => _preferencesStore.save(PersistedAppState(
        trackingCenter: _trackingCenter,
        settings: _settings,
        savedAircraft: _saved,
      ));

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
    unawaited(_persist());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
