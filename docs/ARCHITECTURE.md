# AviJourney V0.3 Architecture

## Principle

UI features depend on domain abstractions. Domain code must not depend on OpenSky, HexDB, HTTP libraries or map vendors.

```text
Presentation
    |
Application / repositories
    |
Domain interfaces + models
    |
Data provider implementations
    |--- OpenSky
    |--- HexDB
    |--- map tile provider
    |--- local cache
    `--- future flight identity source
```

## Suggested structure

```text
lib/
  app/
  core/
    cache/
    errors/
    lifecycle/
    networking/
    theme/
  domain/
    models/
    providers/
    repositories/
  data/
    opensky/
    hexdb/
    local/
    mapping/
  features/
    radar/
    map/
    cards/
    aircraft_detail/
    filters/
    saved/
```

## Domain split

### AircraftState
Fast-changing surveillance data: ICAO24, callsign, position, altitude, speed, track, vertical rate, squawk and observation time.

### AircraftIdentity
Slow-changing identity: registration, type, model, manufacturer and operator.

### FlightRoute
Journey information: callsign, verified commercial number if known, origin, destination and provenance.

### Airport
ICAO, IATA, name, city, country and coordinates where available.

### TrackedAircraft
Presentation/application aggregate composed from state + identity + route.

## Repository responsibilities

- merge live state with cached enrichment;
- deduplicate enrichment requests;
- retain last valid snapshot;
- manage refresh cadence;
- expose provider health;
- append observed position history;
- persist saved aircraft;
- emit immutable app state to widgets.

## Mapping

Use a real Flutter slippy-map implementation behind an adapter/component boundary. Aircraft markers must use geographic coordinates. The map provider must be replaceable and attribution supported. Never implement another hand-drawn pseudo-map.

## State management

Choose one predictable Flutter state-management approach and use it consistently. Keep network requests out of widget `build()` methods.

## Error model

Use typed categories such as network unavailable, timeout, unauthorized, rate limited, service unavailable, malformed response and unknown provider error.

## Caching

At minimum:

- short-lived live snapshot cache;
- ICAO24 -> aircraft identity cache;
- callsign/context -> route cache;
- airport code -> airport metadata cache;
- persistent saved-aircraft store.
