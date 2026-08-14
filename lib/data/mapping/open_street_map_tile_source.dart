import '../../app/mapping/map_tile_source.dart';

class OpenStreetMapTileSource implements MapTileSource {
  const OpenStreetMapTileSource();

  @override
  String get urlTemplate => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  String get attributionText => 'OpenStreetMap contributors';

  @override
  Uri get attributionUri =>
      Uri.parse('https://www.openstreetmap.org/copyright');

  @override
  String get userAgentPackageName => 'com.caf4u.avijourney';

  @override
  int get maximumNativeZoom => 19;
}
