import 'package:flutter/material.dart';
import '../models/location_model.dart';

class MovesPainter extends CustomPainter {
  final List<LocationModel> locations;

  MovesPainter(this.locations);

  @override
  void paint(Canvas canvas, Size size) {
    if (locations.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Normalize the lat/lng to fit the canvas
    double minLat = locations.map((e) => e.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = locations.map((e) => e.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = locations.map((e) => e.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = locations.map((e) => e.longitude).reduce((a, b) => a > b ? a : b);

    double latRange = maxLat - minLat;
    double lngRange = maxLng - minLng;

    Offset mapToOffset(double lat, double lng) {
      double x = (lng - minLng) / lngRange * size.width;
      double y = size.height - ((lat - minLat) / latRange * size.height); // flip y
      return Offset(x, y);
    }

    for (int i = 0; i < locations.length - 1; i++) {
      final start = mapToOffset(locations[i].latitude, locations[i].longitude);
      final end = mapToOffset(locations[i + 1].latitude, locations[i + 1].longitude);
      canvas.drawLine(start, end, paint);
      canvas.drawCircle(start, 6, dotPaint);
    }

    // draw last dot
    final last = mapToOffset(locations.last.latitude, locations.last.longitude);
    canvas.drawCircle(last, 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
