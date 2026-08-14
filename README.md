# AviJourney

**Live aviation around you.**  
*A CAF4U Companion*

AviJourney is a mobile-first aviation and travel companion. V0.3 begins with live aircraft discovery — radar, real geographic maps, aircraft identity, routes, cards, trails, filters and saved aircraft — while deliberately leaving room to expand into the traveller's own journey: flights, airports, fare intelligence, disruptions and trip support.

## Status

**V0.3.0 — Milestone 3 live tracking development build**

The working Tauri proof of concept remains in `Hugo-Doswald/flightscope-prototype`. Its V0.2.5 build proved the core experience on Android using live OpenSky positions and HexDB enrichment. This repository is a clean Flutter/Dart rebuild, not a line-by-line port.

## Product principles

- Live aviation first.
- Never invent flight identity; if a commercial number cannot be verified, show the callsign.
- Keep OpenSky, HexDB, mapping and future schedule sources behind replaceable interfaces.
- Prefer free/open data and cache aggressively.
- Use real geographic maps and real latitude/longitude.
- Treat mobile safe areas, rotation, lifecycle and offline/error states as first-class requirements.
- Keep the domain model ready for broader travel information later.

## V0.3 MVP

- Live radar centred on a chosen location.
- Real geographic map with live aircraft markers.
- Aircraft cards and aircraft detail.
- OpenSky live state vectors.
- HexDB aircraft/operator/route enrichment.
- Airport IATA code plus airport name.
- Search, altitude filters, trails, labels and saved aircraft.
- Configurable radar range and refresh interval.
- Quick range selector by tapping the radar range badge.
- Persistent local cache and saved state.
- Portrait and landscape layouts.
- Explicit connecting, live, cached, offline, rate-limited and provider-error states.

Commercial flight-number resolution is a separate future provider. Callsign-to-flight-number guessing is prohibited.

## Run locally

Install a current Flutter SDK with Android tooling, then run:

```sh
flutter pub get
flutter run
```

Milestone 3 uses geographically bounded OpenSky state vectors and cached HexDB enrichment through replaceable domain providers. Radar and the interactive `flutter_map` map share the same user-selectable tracking centre. Small settings, the selected centre and saved aircraft are stored locally with `shared_preferences`.

Tracking can be centred on the device's foreground location, a locally indexed airport, or a long-pressed map point. Android location permission is requested only when **Use my location** is selected; AviJourney does not request background location access.

Pushes to `main` run formatting, analysis and tests, build an Android debug APK, and publish it as the `AviJourney-v0.3-debug-APK` workflow artifact.

## Documentation

- `docs/PRODUCT_VISION.md`
- `docs/V0.3_IMPLEMENTATION_BRIEF.md`
- `docs/ARCHITECTURE.md`
- `docs/UX_REQUIREMENTS.md`
- `docs/DATA_PROVIDERS.md`
- `docs/MIGRATION_FROM_FLIGHTSCOPE.md`
- `docs/ACCEPTANCE_CRITERIA.md`
- `docs/CODEX_START_PROMPT.md`
- `AGENTS.md`
