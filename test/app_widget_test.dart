import 'package:avijourney/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell navigates and exposes quick radar range choices',
      (tester) async {
    await tester.pumpWidget(
        const AviJourneyApp(showMapTiles: false, useLiveData: false));
    await tester.pumpAndSettle();
    expect(find.text('AVIJOURNEY'), findsOneWidget);
    expect(find.text('20 NM'), findsOneWidget);
    expect(find.textContaining('CENTER · LONDON HEATHROW'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rangeBadge')));
    await tester.pumpAndSettle();
    expect(find.text('80 NM'), findsOneWidget);
    await tester.tap(find.text('80 NM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('aircraftGeographicMap')), findsOneWidget);
  });

  testWidgets('settings labels the recommended interval as 60 seconds',
      (tester) async {
    await tester.pumpWidget(
        const AviJourneyApp(showMapTiles: false, useLiveData: false));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filters and settings'));
    await tester.pumpAndSettle();

    expect(find.text('60 seconds (recommended)'), findsOneWidget);
  });

  testWidgets('Radar Cards and Saved navigation continues to share state',
      (tester) async {
    await tester.pumpWidget(
        const AviJourneyApp(showMapTiles: false, useLiveData: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('rangeBadge')), findsOneWidget);

    await tester.tap(find.text('Cards'));
    await tester.pumpAndSettle();
    expect(find.text('BAW12'), findsOneWidget);
    await tester.tap(find.byTooltip('Save aircraft').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('BAW12'), findsOneWidget);
  });
}
