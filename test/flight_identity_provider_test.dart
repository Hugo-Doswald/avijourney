import 'package:avijourney/domain/models/flight.dart';
import 'package:avijourney/domain/providers/flight_identity_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingIdentityProvider implements FlightIdentityProvider {
  var calls = 0;
  final Flight? result;
  RecordingIdentityProvider(this.result);

  @override
  Future<Flight?> resolveVerifiedIdentity(String callsign) async {
    calls++;
    return result;
  }
}

void main() {
  test('cached provider reuses verified and unresolved lookups', () async {
    final source = RecordingIdentityProvider(null);
    final provider = CachedFlightIdentityProvider(source);
    await provider.resolveVerifiedIdentity('BAW7LC');
    await provider.resolveVerifiedIdentity(' baw7lc ');
    expect(source.calls, 1);
  });

  test('verified identity becomes primary and unverified identity does not',
      () {
    const verified = Flight(
      operationalCallsign: 'BAW7LC',
      commercialFlightNumber: 'BA783',
      verificationState: FlightVerificationState.verified,
    );
    const unverified = Flight(
      operationalCallsign: 'BAW7LC',
      commercialFlightNumber: 'BA783',
      verificationState: FlightVerificationState.unverified,
    );
    expect(verified.primaryIdentifier, 'BA783');
    expect(unverified.primaryIdentifier, 'BAW7LC');
  });
}
