class TrackingCenter {
  const TrackingCenter({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  static const heathrow = TrackingCenter(
    latitude: 51.4700,
    longitude: -0.4543,
    label: 'London Heathrow',
  );

  final double latitude;
  final double longitude;
  final String label;
}
