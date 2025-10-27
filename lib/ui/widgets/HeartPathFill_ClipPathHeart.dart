import 'package:flutter/material.dart';

/// Heart that fills from bottom→top using ClipPath + Path.
/// - [percent]: 0..100
/// - [size]: square extent of the heart
/// - [backgroundColor]: empty part color
/// - [fillColor]: filled part color
class HeartFillWidget2 extends StatelessWidget {
  const HeartFillWidget2({
    super.key,
    required this.percent,
    this.size = 200,
    this.backgroundColor = const Color(0xFFE6E6E6),
    this.fillColor = const Color.fromARGB(255, 110, 10, 164),
    this.showPercentText = true,
  });

  final double percent; // 0..100
  final double size;
  final Color backgroundColor;
  final Color fillColor;
  final bool showPercentText;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0) / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background (empty heart)
          ClipPath(
            clipper: _HeartClipper(),
            clipBehavior: Clip.antiAlias,
            child: Container(color: backgroundColor),
          ),

          // Fill (rises from bottom)
          ClipPath(
            clipper: _HeartClipper(),
            clipBehavior: Clip.antiAlias,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: clamped, // 0..1
                widthFactor: 1,
                alignment: Alignment.bottomCenter,
                child: Container(color: fillColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Defines the scalable heart shape.
class _HeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => _buildHeartPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Heart path math.
Path _buildHeartPath(Size size) {
  const inset = 3.0;
  final sx = size.width - inset * 2;
  final sy = size.height - inset * 2;

  final path = Path()
    ..moveTo(inset + 0.50 * sx, inset + 0.28 * sy)
    ..cubicTo(
      inset + 0.20 * sx,
      inset + 0.00 * sy, // left control 1
      inset + 0.10 * sx,
      inset + 0.35 * sy, // left control 2
      inset + 0.60 * sx,
      inset + 0.95 * sy, // bottom
    )
    ..cubicTo(
      inset + 1.10 * sx,
      inset + 0.35 * sy, // right control 1
      inset + 0.80 * sx,
      inset + 0.00 * sy, // right control 2
      inset + 0.50 * sx,
      inset + 0.28 * sy, // back to top
    )
    ..close();

  return path;
}
