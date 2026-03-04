import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'spotlight_target.dart';

class SpotlightPainter extends CustomPainter {
  SpotlightPainter({
    required this.holes,
    required this.scrimColor,
  });

  final List<SpotlightHole> holes;
  final Color scrimColor;

  @override
  void paint(Canvas canvas, Size size) {
    final screenPath = Path()..addRect(Offset.zero & size);
    var holesPath = Path();

    for (final hole in holes) {
      holesPath = Path.combine(
        PathOperation.union,
        holesPath,
        hole.path,
      );
    }

    final overlayPath = Path.combine(
      PathOperation.difference,
      screenPath,
      holesPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = scrimColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return !listEquals(oldDelegate.holes, holes) ||
        oldDelegate.scrimColor != scrimColor;
  }
}
