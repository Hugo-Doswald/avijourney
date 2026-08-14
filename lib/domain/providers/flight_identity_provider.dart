import '../models/flight.dart';

abstract interface class FlightIdentityProvider {
  Future<Flight?> resolveVerifiedIdentity(String callsign);
}

class NoOpFlightIdentityProvider implements FlightIdentityProvider {
  const NoOpFlightIdentityProvider();

  @override
  Future<Flight?> resolveVerifiedIdentity(String callsign) async => null;
}

class CachedFlightIdentityProvider implements FlightIdentityProvider {
  CachedFlightIdentityProvider(this.source,
      {this.positiveTtl = const Duration(hours: 6),
      this.negativeTtl = const Duration(minutes: 30),
      DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final FlightIdentityProvider source;
  final Duration positiveTtl;
  final Duration negativeTtl;
  final DateTime Function() _now;
  final Map<String, ({Flight? value, DateTime expires})> _cache = {};

  @override
  Future<Flight?> resolveVerifiedIdentity(String callsign) async {
    final key = callsign.trim().toUpperCase();
    if (key.isEmpty) return null;
    final cached = _cache[key];
    if (cached != null && cached.expires.isAfter(_now())) return cached.value;
    final value = await source.resolveVerifiedIdentity(key);
    _cache[key] = (
      value: value,
      expires: _now().add(value == null ? negativeTtl : positiveTtl),
    );
    return value;
  }
}
