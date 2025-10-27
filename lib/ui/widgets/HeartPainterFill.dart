import 'package:flutter/material.dart';

/// HeartPainterFill (Beginner-Friendly)
/// ------------------------------------
/// - Draws a heart with a background color.
/// - Fills from bottom → top based on [percent] (0..100).
/// - Uses a simple vertical gradient for the fill.
/// - No border, no shadow, no gloss — just the essentials.
class HeartPainterFill extends StatelessWidget {
  const HeartPainterFill({
    super.key,
    required this.percent, // 0..100
    this.size = 220,
    this.gradient = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFFE53935), Color(0xFFFFA1A1)],
    ),
    this.backgroundColor = const Color(0xFFEAEAEA),
    this.showPercentText = true,
  });

  final double percent;
  final double size;
  final LinearGradient gradient;
  final Color backgroundColor;
  final bool showPercentText;

  @override
  Widget build(BuildContext context) {
    final clamped = (percent.clamp(0.0, 100.0)) / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Paint the heart & fill
          CustomPaint(
            painter: _HeartFillPainter(
              fill: clamped, // 0..1
              gradient: gradient,
              backgroundColor: backgroundColor,
            ),
            size: Size.square(size),
          ),
        ],
      ),
    );
  }
}

class _HeartFillPainter extends CustomPainter {
  _HeartFillPainter({
    required this.fill, // 0..1
    required this.gradient,
    required this.backgroundColor,
  });

  final double fill;
  final LinearGradient gradient;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Build the heart path (single closed shape)
    final path = _buildHeartPath(size);

    // 2) Clip all drawing to the heart shape
    canvas.save();
    canvas.clipPath(path, doAntiAlias: true);

    // 3) Paint background inside the heart
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 4) Paint the fill (bottom portion only) with a vertical gradient
    final bounds = path.getBounds();
    final filledHeight = bounds.height * fill;

    // Fill rectangle from bottom up
    final fillRect = Rect.fromLTWH(
      bounds.left,
      bounds.bottom - filledHeight,
      bounds.width,
      filledHeight,
    );

    // Use a shader so the gradient looks nice
    final shader = gradient.createShader(bounds);
    final fillPaint = Paint()..shader = shader;
    canvas.drawRect(fillRect, fillPaint);

    canvas.restore(); // end of clipping
  }

  @override
  bool shouldRepaint(covariant _HeartFillPainter old) =>
      old.fill != fill ||
      old.gradient != gradient ||
      old.backgroundColor != backgroundColor;
}

/// Simple, scalable heart path using two cubic curves.
/// Keeps a tiny inset so edges don’t get clipped.
Path _buildHeartPath(Size size) {
  const inset = 1.0; // small padding
  final sx = size.width - 2 * inset;
  final sy = size.height - 2 * inset;
  final ox = inset;
  final oy = inset;

  return Path()
    // Start near the top center
    ..moveTo(ox + 0.50 * sx, oy + 0.28 * sy)
    // Left half of the heart
    ..cubicTo(
      ox + 0.20 * sx,
      oy + 0.00 * sy, // control 1
      ox + 0.10 * sx,
      oy + 0.35 * sy, // control 2
      ox + 0.50 * sx,
      oy + 0.95 * sy, // bottom point
    )
    // Right half of the heart
    ..cubicTo(
      ox + 0.90 * sx,
      oy + 0.35 * sy, // control 1
      ox + 0.80 * sx,
      oy + 0.00 * sy, // control 2
      ox + 0.50 * sx,
      oy + 0.28 * sy, // back to near top center
    )
    ..close();
}
