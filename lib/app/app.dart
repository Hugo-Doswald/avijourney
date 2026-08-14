import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/mock/mock_aircraft_provider.dart';
import '../data/mock/mock_enrichment_provider.dart';
import '../data/repositories/mock_aircraft_repository.dart';
import '../features/home/home_shell.dart';
import 'app_controller.dart';

class AviJourneyApp extends StatefulWidget {
  const AviJourneyApp({super.key, this.controller});

  final AppController? controller;

  @override
  State<AviJourneyApp> createState() => _AviJourneyAppState();
}

class _AviJourneyAppState extends State<AviJourneyApp>
    with WidgetsBindingObserver {
  late final AppController controller = widget.controller ??
      AppController(
        repository: MockAircraftRepository(
          positions: const MockAircraftPositionProvider(),
          enrichment: const MockAircraftEnrichmentProvider(),
        ),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.resume();
    } else {
      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AviJourney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: HomeShell(controller: controller),
    );
  }
}
