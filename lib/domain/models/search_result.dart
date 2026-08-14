enum SearchResultType { flight, aircraft, airline, route, airport }

class SearchResult {
  const SearchResult({
    required this.type,
    required this.identifier,
    required this.title,
    required this.subtitle,
    required this.matchReason,
    this.value,
  });

  final SearchResultType type;
  final String identifier;
  final String title;
  final String subtitle;
  final String matchReason;
  final Object? value;
}
