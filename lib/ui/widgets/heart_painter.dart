import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Draws a circular progress "ring" that fills based on [percent] (0..100).
class HeartPainter extends CustomPainter {
  final double percent; // 0..100
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  HeartPainter(
    this.percent, {
    this.strokeWidth = 16,
    this.backgroundColor = const Color(0xFFE5E7EB), // grey.300
    this.progressColor = Colors.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Compute center & radius from the paint area (the CustomPaint.size).
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.4;

    // 2) Background ring paint.
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    // 3) Foreground (progress) ring paint.
    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // 4) Draw full background circle.
    canvas.drawCircle(center, radius, bgPaint);

    // 5) Translate percent (0..100) to sweep angle in radians.
    final sweepAngle = 2 * math.pi * (percent.clamp(0, 100) / 100.0);

    // 6) Start from top (-90°) and draw the arc with the computed sweep.
    const startAngle = -math.pi / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant HeartPainter old) {
    // Repaint only when inputs that affect drawing change.
    return old.percent != percent ||
        old.strokeWidth != strokeWidth ||
        old.backgroundColor != backgroundColor ||
        old.progressColor != progressColor;
  }
}
