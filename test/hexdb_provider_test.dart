import 'package:avijourney/data/hexdb/hexdb_aircraft_enrichment_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('caches successful aircraft identity lookups by ICAO24', () async {
    var requests = 0;
    final provider = HexDbAircraftEnrichmentProvider(
      client: MockClient((request) async {
        requests++;
        return http.Response(
            '{"ICAOTypeCode":"A319","ModeS":"4010EE","RegisteredOwners":"easyJet Airline","Registration":"G-EZBZ","Type":"A319 111"}',
            200);
      }),
    );

    final first = await provider.resolveAircraft('4010ee');
    final second = await provider.resolveAircraft('4010EE');

    expect(first?.registration, 'G-EZBZ');
    expect(second?.operatorName, 'easyJet Airline');
    expect(requests, 1);
  });

  test('caches negative lookups for the shorter negative TTL', () async {
    var requests = 0;
    var now = DateTime.utc(2026);
    final provider = HexDbAircraftEnrichmentProvider(
      now: () => now,
      negativeTtl: const Duration(minutes: 5),
      client: MockClient((request) async {
        requests++;
        return http.Response('{"status":"404","error":"not found"}', 200);
      }),
    );

    expect(await provider.resolveAircraft('000000'), isNull);
    expect(await provider.resolveAircraft('000000'), isNull);
    expect(requests, 1);
    now = now.add(const Duration(minutes: 6));
    expect(await provider.resolveAircraft('000000'), isNull);
    expect(requests, 2);
  });

  test('resolves route airports without inventing a commercial number',
      () async {
    final provider = HexDbAircraftEnrichmentProvider(
      client: MockClient((request) async {
        if (request.url.path.contains('/route/')) {
          return http.Response('{"flight":"EIN17A","route":"EIDW-EGLL"}', 200);
        }
        if (request.url.path.endsWith('EIDW')) {
          return http.Response(
              '{"airport":"Dublin Airport","country_code":"IE","iata":"DUB","icao":"EIDW","latitude":53.4,"longitude":-6.2}',
              200);
        }
        return http.Response(
            '{"airport":"Heathrow Airport","country_code":"GB","iata":"LHR","icao":"EGLL","latitude":51.47,"longitude":-0.46}',
            200);
      }),
    );

    final route = await provider.resolveRoute('EIN17A');

    expect(route?.origin?.displayCode, 'DUB');
    expect(route?.destination?.displayCode, 'LHR');
    expect(route?.commercialFlightNumber, isNull);
    expect(route?.primaryIdentifier, 'EIN17A');
    expect(route?.verified, isFalse);
  });
}
