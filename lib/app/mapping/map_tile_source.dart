abstract interface class MapTileSource {
  String get urlTemplate;
  String get attributionText;
  Uri get attributionUri;
  String get userAgentPackageName;
  int get maximumNativeZoom;
}
