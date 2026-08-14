enum TrackingCenterType { defaultLocation, device, airport, map }

class TrackingCenter {
  const TrackingCenter({
    required this.latitude,
    required this.longitude,
    required this.label,
    this.type = TrackingCenterType.defaultLocation,
  });

  static const heathrow = TrackingCenter(
    latitude: 51.4700,
    longitude: -0.4543,
    label: 'London Heathrow',
    type: TrackingCenterType.defaultLocation,
  );

  final double latitude;
  final double longitude;
  final String label;
  final TrackingCenterType type;
}
