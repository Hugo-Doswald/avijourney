import '../../domain/models/app_settings.dart';
import '../../domain/models/tracking_center.dart';

class PersistedAppState {
  const PersistedAppState({
    required this.trackingCenter,
    required this.settings,
    required this.savedAircraft,
  });

  final TrackingCenter trackingCenter;
  final AppSettings settings;
  final Set<String> savedAircraft;
}

abstract interface class AppPreferencesStore {
  Future<PersistedAppState?> load();
  Future<void> save(PersistedAppState state);
}

class NoOpAppPreferencesStore implements AppPreferencesStore {
  const NoOpAppPreferencesStore();

  @override
  Future<PersistedAppState?> load() async => null;

  @override
  Future<void> save(PersistedAppState state) async {}
}
