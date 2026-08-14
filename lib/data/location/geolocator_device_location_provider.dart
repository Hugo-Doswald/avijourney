import 'package:geolocator/geolocator.dart';

import '../../domain/providers/device_location_provider.dart';

class GeolocatorDeviceLocationProvider implements DeviceLocationProvider {
  const GeolocatorDeviceLocationProvider();

  @override
  Future<DeviceLocationResult> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const DeviceLocationResult.failure(
            DeviceLocationStatus.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationResult.failure(
            DeviceLocationStatus.permissionDeniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const DeviceLocationResult.failure(
            DeviceLocationStatus.permissionDenied);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return DeviceLocationResult.available(
          position.latitude, position.longitude);
    } catch (_) {
      return const DeviceLocationResult.failure(
          DeviceLocationStatus.unavailable);
    }
  }
}
