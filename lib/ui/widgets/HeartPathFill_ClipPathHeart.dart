import 'package:flutter/material.dart';

/// A simple heart fill using ClipPath + Path (no third-party animation).
/// - [percent]: 0..100
/// - [size]: square extent of the heart area
/// - [backgroundColor]: color of empty area inside the heart
/// - [fillColor]: color of the filled portion
/// - [borderColor]/[borderWidth]: outline on top
class HeartFillWidget2 extends StatelessWidget {
  const HeartFillWidget2({
    super.key,
    required this.percent,
    this.size = 200,
    this.backgroundColor = const Color(0xFFE6E6E6),
    this.fillColor = Colors.redAccent,
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.showPercentText = true,
  });

  final double percent; // expected 0..100
  final double size;
  final Color backgroundColor;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final bool showPercentText;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0) / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 1) Background clipped to heart
          ClipPath(
            clipper: _HeartClipper(borderWidth: borderWidth),
            child: Container(color: backgroundColor),
          ),

          // 2) Fill clipped to heart (rises from bottom)
          ClipPath(
            clipper: _HeartClipper(borderWidth: borderWidth),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: clamped, // 0..1
                widthFactor: 1.0,
                alignment: Alignment.bottomCenter,
                child: Container(color: fillColor),
              ),
            ),
          ),

          // 3) Optional percent text
          if (showPercentText)
            Center(
              child: Text(
                '${(clamped * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

          // 4) Border on top for a crisp edge
          Positioned.fill(
            child: CustomPaint(
              painter: _HeartBorderPainter(
                color: borderColor,
                strokeWidth: borderWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Clipper that returns the scalable heart path.
class _HeartClipper extends CustomClipper<Path> {
  _HeartClipper({required this.borderWidth});
  final double borderWidth;

  @override
  Path getClip(Size size) => _buildHeartPath(size, borderWidth);

  @override
  bool shouldReclip(covariant _HeartClipper oldClipper) =>
      oldClipper.borderWidth != borderWidth;
}

/// Painter that draws the heart outline (same path as the clipper).
class _HeartBorderPainter extends CustomPainter {
  _HeartBorderPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildHeartPath(size, strokeWidth);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Shared heart path math (closed, single path, scaled with margins).
Path _buildHeartPath(Size size, double strokeWidth) {
  final w = size.width;
  final h = size.height;

  // Keep a tiny padding so border doesn't get clipped
  final pad = strokeWidth / 2 + 2.0;
  final sx = w - 2 * pad;
  final sy = h - 2 * pad;
  final ox = pad;
  final oy = pad;

  return Path()
    ..moveTo(ox + 0.50 * sx, oy + 0.28 * sy)
    ..cubicTo(
      ox + 0.20 * sx,
      oy + 0.00 * sy, // control 1
      ox - 0.10 * sx,
      oy + 0.35 * sy, // control 2
      ox + 0.50 * sx,
      oy + 0.95 * sy, // bottom point
    )
    ..cubicTo(
      ox + 1.10 * sx,
      oy + 0.35 * sy, // control 1
      ox + 0.80 * sx,
      oy + 0.00 * sy, // control 2
      ox + 0.50 * sx,
      oy + 0.28 * sy, // back to top center
    )
    ..close();
}
