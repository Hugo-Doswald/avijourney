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

### V0.3 implementation notes

The live implementation uses an anonymous, geographically bounded
`/api/states/all` request. AviJourney enforces a minimum 30-second acquisition
cadence, pauses the central timer outside the foreground, and retains the last
valid snapshot when OpenSky is offline, rate limited, or temporarily fails.
Optional OAuth client credentials may be added later without changing widgets
or domain models.

## HexDB — initial enrichment provider

Use for registration, type/model, operator/registered owner, callsign route where supplied and airport metadata.

### Caching

- aircraft identity key: ICAO24;
- route key: callsign plus suitable context;
- airport metadata key: ICAO/IATA;
- successful static identity lookups get long TTLs;
- failed/negative results get shorter retry TTLs.

The V0.3 HexDB adapter keeps successful identity, route and airport results for
30 days in memory and negative/error results for 15 minutes. This avoids repeat
enrichment requests during each OpenSky refresh and remains comfortably below
HexDB's published free-use request guidance. Enrichment errors never discard a
valid OpenSky position.

## Tracking centre and local state

The default first-launch centre is London Heathrow. Users may replace it with a
foreground device position, an airport from the embedded offline search catalog,
or a point selected on the map. The chosen centre, radar/filter settings and
saved aircraft identifiers are stored locally with `shared_preferences`.

## Map data

V0.3 requires a real map, but the tile supplier must be configurable. Respect attribution/licensing and avoid permanent coupling to one public tile service.

## Flight identity provider — future

ATC callsigns such as `BAW7LC` are not reliably reversible into passenger-facing numbers such as `BA783`.

Create an interface now, but do not guess. Future sources may include schedule APIs, airport public feeds or cached confirmed mappings.

Results should carry provenance/confidence.
