import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../domain/models/tracked_aircraft.dart';

class RadarView extends StatelessWidget {
  const RadarView({required this.controller, super.key});
  final AppController controller;

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final size = math
            .min(constraints.maxWidth, constraints.maxHeight - 62)
            .clamp(240.0, 720.0);
        return Stack(children: [
          Center(
            child: SizedBox.square(
              dimension: size,
              child: CustomPaint(
                painter: RadarPainter(
                  aircraft: controller.visibleAircraft,
                  selectedIcao24: controller.selectedIcao24,
                  rangeNm: controller.settings.radarRangeNm,
                  showLabels: controller.settings.showLabels,
                  showTrails: controller.settings.showTrails,
                ),
                child: GestureDetector(
                  onTapUp: (details) => _selectNearest(
                    details.localPosition,
                    Size.square(size),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              top: 14,
              right: 14,
              child: PopupMenuButton<int>(
                  tooltip: 'Select radar range',
                  initialValue: controller.settings.radarRangeNm,
                  onSelected: controller.setRadarRange,
                  itemBuilder: (_) => const [20, 80, 140, 200]
                      .map((range) =>
                          PopupMenuItem(value: range, child: Text('$range NM')))
                      .toList(),
                  child: Container(
                      key: const Key('rangeBadge'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xE6112118),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(22)),
                      child: Text('${controller.settings.radarRangeNm} NM',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold))))),
          const Positioned(
              left: 16,
              bottom: 14,
              child: Text('CENTER · LONDON HEATHROW\nMOCK POSITION FEED',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.1))),
        ]);
      });

  void _selectNearest(Offset tap, Size size) {
    final radius = size.shortestSide / 2;
    TrackedAircraft? nearest;
    var distance = 28.0;
    for (final aircraft in controller.visibleAircraft) {
      final point = RadarPainter.positionFor(
          aircraft, size, controller.settings.radarRangeNm);
      final candidate = (tap - point).distance;
      if (candidate < distance && candidate <= radius) {
        distance = candidate;
        nearest = aircraft;
      }
    }
    controller.select(nearest?.state.icao24);
  }
}

class RadarPainter extends CustomPainter {
  RadarPainter(
      {required this.aircraft,
      required this.selectedIcao24,
      required this.rangeNm,
      required this.showLabels,
      required this.showTrails});
  final List<TrackedAircraft> aircraft;
  final String? selectedIcao24;
  final int rangeNm;
  final bool showLabels;
  final bool showTrails;

  static Offset positionFor(TrackedAircraft aircraft, Size size, int rangeNm) {
    const nmPerLatitudeDegree = 60.0;
    final longitudeNm =
        (aircraft.state.longitude - AppController.centerLongitude) *
            60 *
            math.cos(AppController.centerLatitude * math.pi / 180);
    final latitudeNm =
        (aircraft.state.latitude - AppController.centerLatitude) *
            nmPerLatitudeDegree;
    final scale = size.shortestSide / 2 / rangeNm;
    return Offset(size.width / 2 + longitudeNm * scale,
        size.height / 2 - latitudeNm * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final grid = Paint()
      ..color = const Color(0x5569E58B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF07150D));
    for (var ring = 1; ring <= 4; ring++)
      canvas.drawCircle(center, radius * ring / 4, grid);
    canvas.drawLine(Offset(center.dx, center.dy - radius),
        Offset(center.dx, center.dy + radius), grid);
    canvas.drawLine(Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy), grid);
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF69E58B));
    for (final target in aircraft) {
      final point = positionFor(target, size, rangeNm);
      if ((point - center).distance > radius) continue;
      final selected = target.state.icao24 == selectedIcao24;
      canvas.save();
      canvas.translate(point.dx, point.dy);
      canvas.rotate(target.state.trackDegrees * math.pi / 180);
      final marker = Path()
        ..moveTo(0, -9)
        ..lineTo(6, 8)
        ..lineTo(0, 5)
        ..lineTo(-6, 8)
        ..close();
      canvas.drawPath(
          marker,
          Paint()
            ..color =
                selected ? const Color(0xFFFFD166) : const Color(0xFF89F7A8));
      if (selected)
        canvas.drawCircle(
            Offset.zero,
            14,
            Paint()
              ..color = const Color(0xFFFFD166)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      canvas.restore();
      if (showLabels && (rangeNm <= 80 || selected)) {
        TextPainter(
            text: TextSpan(
                text: target.primaryIdentifier,
                style: TextStyle(
                    color: selected
                        ? const Color(0xFFFFD166)
                        : const Color(0xFFD8FBE1),
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr)
          ..layout()
          ..paint(canvas, point + const Offset(9, -15));
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) =>
      oldDelegate.aircraft != aircraft ||
      oldDelegate.selectedIcao24 != selectedIcao24 ||
      oldDelegate.rangeNm != rangeNm ||
      oldDelegate.showLabels != showLabels ||
      oldDelegate.showTrails != showTrails;
}
