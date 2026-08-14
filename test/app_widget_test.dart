import 'package:avijourney/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell navigates and exposes quick radar range choices',
      (tester) async {
    await tester.pumpWidget(const AviJourneyApp());
    await tester.pumpAndSettle();
    expect(find.text('AVIJOURNEY'), findsOneWidget);
    expect(find.text('20 NM'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rangeBadge')));
    await tester.pumpAndSettle();
    expect(find.text('80 NM'), findsOneWidget);
    await tester.tap(find.text('80 NM'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    expect(find.text('REAL MAP COMING NEXT'), findsOneWidget);
  });

  testWidgets('settings labels the recommended interval as 60 seconds',
      (tester) async {
    await tester.pumpWidget(const AviJourneyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filters and settings'));
    await tester.pumpAndSettle();

    expect(find.text('60 seconds (recommended)'), findsOneWidget);
  });
}
