import 'package:flutter/material.dart';

/// A heart that fills from bottom → top based on [percent] (0–100).
/// Shows ONLY the heart. Put the percentage text below in the screen.
class HeartFillWidget extends StatelessWidget {
  final double percent; // 0..100
  final double size;
  final Color fillColor;
  final Color backgroundColor;

  const HeartFillWidget({
    super.key,
    required this.percent,
    this.size = 200,
    this.fillColor = const Color(0xFF3F0D82), // purple
    this.backgroundColor = const Color(0xFFE7E7E7), // light grey
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background empty heart (grey)
        Icon(Icons.favorite, color: backgroundColor, size: size),

        // Foreground filled heart (purple), clipped based on percent
        ClipRect(
          clipper: _HeartClipper(percent),
          child: Icon(Icons.favorite, color: fillColor, size: size),
        ),
      ],
    );
  }
}

/// Custom clipper to control how much of the heart is visible.
class _HeartClipper extends CustomClipper<Rect> {
  final double percent; // 0..100
  _HeartClipper(this.percent);

  @override
  Rect getClip(Size size) {
    final p = percent.clamp(0, 100) / 100.0;
    final fillHeight = size.height * p;
    final rect = Rect.fromLTWH(
      0,
      size.height - fillHeight, // fill from bottom
      size.width,
      fillHeight,
    );

    return rect;
  }

  @override
  bool shouldReclip(_HeartClipper old) => old.percent != percent;
}
