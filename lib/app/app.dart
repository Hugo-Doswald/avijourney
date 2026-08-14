import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/home_shell.dart';

class AviJourneyApp extends StatelessWidget {
  const AviJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AviJourney',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeShell(),
    );
  }
}
