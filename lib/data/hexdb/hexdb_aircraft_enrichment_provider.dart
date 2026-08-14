import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/aircraft_identity.dart';
import '../../domain/models/airport.dart';
import '../../domain/models/flight_route.dart';
import '../../domain/providers/aircraft_enrichment_provider.dart';

class HexDbAircraftEnrichmentProvider implements AircraftEnrichmentProvider {
  HexDbAircraftEnrichmentProvider({
    required http.Client client,
    Uri? baseUri,
    DateTime Function()? now,
    this.successTtl = const Duration(days: 30),
    this.negativeTtl = const Duration(minutes: 15),
    this.timeout = const Duration(seconds: 10),
  })  : _client = client,
        _baseUri = baseUri ?? Uri.parse('https://hexdb.io/api/v1/'),
        _now = now ?? DateTime.now;

  final http.Client _client;
  final Uri _baseUri;
  final DateTime Function() _now;
  final Duration successTtl;
  final Duration negativeTtl;
  final Duration timeout;
  final Map<String, _CacheEntry<AircraftIdentity?>> _identityCache = {};
  final Map<String, _CacheEntry<FlightRoute?>> _routeCache = {};
  final Map<String, _CacheEntry<Airport?>> _airportCache = {};

  @override
  Future<AircraftIdentity?> resolveAircraft(String icao24) async {
    final key = icao24.trim().toUpperCase();
    final cached = _valid(_identityCache[key]);
    if (cached != null) return cached.value;
    AircraftIdentity? identity;
    try {
      final json = await _getJson('aircraft/$key');
      if (json != null) {
        identity = AircraftIdentity(
          icao24: key,
          registration: _text(json['Registration']),
          typeCode: _text(json['ICAOTypeCode']),
          model: _text(json['Type']),
          operatorName: _text(json['RegisteredOwners']),
        );
      }
    } catch (_) {
      identity = null;
    }
    _identityCache[key] = _entry(identity);
    return identity;
  }

  @override
  Future<FlightRoute?> resolveRoute(String callsign) async {
    final key = callsign.trim().toUpperCase();
    if (key.isEmpty) return null;
    final cached = _valid(_routeCache[key]);
    if (cached != null) return cached.value;
    FlightRoute? route;
    try {
      final json = await _getJson('route/icao/$key');
      final routeText = _text(json?['route']);
      if (routeText != null) {
        final codes = routeText
            .split('-')
            .map((code) => code.trim().toUpperCase())
            .where((code) => code.isNotEmpty)
            .toList(growable: false);
        if (codes.length >= 2) {
          final airports = await Future.wait([
            resolveAirport(codes.first),
            resolveAirport(codes.last),
          ]);
          route = FlightRoute(
            callsign: key,
            origin: airports.first,
            destination: airports.last,
            source: 'HexDB route database',
          );
        }
      }
    } catch (_) {
      route = null;
    }
    _routeCache[key] = _entry(route);
    return route;
  }

  @override
  Future<Airport?> resolveAirport(String code) async {
    final key = code.trim().toUpperCase();
    if (key.isEmpty) return null;
    final cached = _valid(_airportCache[key]);
    if (cached != null) return cached.value;
    Airport? airport;
    try {
      final codeType = key.length == 3 ? 'iata' : 'icao';
      final json = await _getJson('airport/$codeType/$key');
      if (json != null) {
        final icao = _text(json['icao']);
        if (icao != null) {
          airport = Airport(
            icao: icao,
            iata: _text(json['iata']),
            name: _text(json['airport']) ?? icao,
            country: _text(json['country_code']),
            latitude: _number(json['latitude']),
            longitude: _number(json['longitude']),
          );
        }
      }
    } catch (_) {
      airport = null;
    }
    _airportCache[key] = _entry(airport);
    return airport;
  }

  Future<Map<String, dynamic>?> _getJson(String path) async {
    final response = await _client.get(_baseUri.resolve(path)).timeout(timeout);
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded.containsKey('error')) {
      return null;
    }
    return decoded;
  }

  _CacheEntry<T>? _valid<T>(_CacheEntry<T>? entry) =>
      entry != null && entry.expiresAt.isAfter(_now()) ? entry : null;

  _CacheEntry<T?> _entry<T>(T? value) => _CacheEntry(
        value,
        _now().add(value == null ? negativeTtl : successTtl),
      );

  static String? _text(Object? value) {
    if (value is! String || value.trim().isEmpty) return null;
    return value.trim();
  }

  static double? _number(Object? value) =>
      value is num ? value.toDouble() : double.tryParse('$value');
}

class _CacheEntry<T> {
  const _CacheEntry(this.value, this.expiresAt);
  final T value;
  final DateTime expiresAt;
}
