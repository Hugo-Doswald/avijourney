# AviJourney Data Providers

## Provider philosophy

Every external service is replaceable. Provider-specific JSON structures terminate in the data layer and never leak into widgets.

## OpenSky — initial live-position provider

Use for ICAO24, callsign, latitude/longitude, altitude, velocity, track, vertical rate, squawk/on-ground/last-contact when supplied.

Use geographically bounded requests rather than global queries.

### Free-first quota strategy

- Default refresh: 60 seconds initially.
- Expose supported refresh choices in settings.
- Pause or slow requests while backgrounded.
- Keep the last valid snapshot.
- Surface rate limiting clearly.
- Never trigger refreshes merely because widgets rebuild.

## HexDB — initial enrichment provider

Use for registration, type/model, operator/registered owner, callsign route where supplied and airport metadata.

### Caching

- aircraft identity key: ICAO24;
- route key: callsign plus suitable context;
- airport metadata key: ICAO/IATA;
- successful static identity lookups get long TTLs;
- failed/negative results get shorter retry TTLs.

## Map data

V0.3 requires a real map, but the tile supplier must be configurable. Respect attribution/licensing and avoid permanent coupling to one public tile service.

## Flight identity provider — future

ATC callsigns such as `BAW7LC` are not reliably reversible into passenger-facing numbers such as `BA783`.

Create an interface now, but do not guess. Future sources may include schedule APIs, airport public feeds or cached confirmed mappings.

Results should carry provenance/confidence.
