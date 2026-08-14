import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const background = Color(0xFF050906);
    const surface = Color(0xFF09150E);
    const primary = Color(0xFF69E58B);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Color(0xFF173C25),
      ),
      useMaterial3: true,
    );
  }
}
