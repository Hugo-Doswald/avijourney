import 'package:flutter/foundation.dart';

import '../domain/models/app_settings.dart';
import '../domain/models/tracked_aircraft.dart';
import '../domain/repositories/aircraft_repository.dart';

enum FeedStatus { connecting, live, cached, offline, rateLimited, error }

class AppController extends ChangeNotifier {
  AppController({required AircraftRepository repository})
      : _repository = repository;

  static const centerLatitude = 51.4700;
  static const centerLongitude = -0.4543;
  final AircraftRepository _repository;
  List<TrackedAircraft> _aircraft = const [];
  AppSettings _settings = const AppSettings();
  FeedStatus _feedStatus = FeedStatus.connecting;
  String? _selectedIcao24;
  final Set<String> _saved = <String>{};

  List<TrackedAircraft> get aircraft => List.unmodifiable(_aircraft);
  AppSettings get settings => _settings;
  FeedStatus get feedStatus => _feedStatus;
  String? get selectedIcao24 => _selectedIcao24;
  Set<String> get saved => Set.unmodifiable(_saved);

  List<TrackedAircraft> get visibleAircraft => _aircraft.where((aircraft) {
        final altitude = aircraft.state.altitudeFeet;
        return altitude >= _settings.minimumAltitudeFeet &&
            altitude <= _settings.maximumAltitudeFeet &&
            (!_settings.savedOnly || _saved.contains(aircraft.state.icao24));
      }).toList(growable: false);

  Future<void> initialize() async {
    try {
      final result = await _repository.loadNearby(
        centerLatitude: centerLatitude,
        centerLongitude: centerLongitude,
        radiusNauticalMiles: _settings.radarRangeNm.toDouble(),
      );
      _aircraft = result;
      _feedStatus = FeedStatus.live;
    } catch (_) {
      _feedStatus = _aircraft.isEmpty ? FeedStatus.error : FeedStatus.cached;
    }
    notifyListeners();
  }

  void select(String? icao24) {
    _selectedIcao24 = icao24;
    notifyListeners();
  }

  void setRadarRange(int range) {
    _settings = _settings.copyWith(radarRangeNm: range);
    notifyListeners();
  }

  void updateSettings(AppSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void toggleSaved(String icao24) {
    if (!_saved.add(icao24)) _saved.remove(icao24);
    notifyListeners();
  }
}
