enum DeviceLocationStatus {
  available,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class DeviceLocationResult {
  const DeviceLocationResult._(this.status, this.latitude, this.longitude);

  const DeviceLocationResult.available(double latitude, double longitude)
      : this._(DeviceLocationStatus.available, latitude, longitude);
  const DeviceLocationResult.failure(DeviceLocationStatus status)
      : this._(status, null, null);

  final DeviceLocationStatus status;
  final double? latitude;
  final double? longitude;
}

abstract interface class DeviceLocationProvider {
  Future<DeviceLocationResult> getCurrentLocation();
}
