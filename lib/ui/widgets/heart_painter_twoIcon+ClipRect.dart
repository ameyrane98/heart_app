import 'package:flutter/material.dart';

/// A heart that fills from bottom → top based on [percent] (0–100).
class HeartFillWidget extends StatelessWidget {
  final double percent; // 0..100
  final double size;

  const HeartFillWidget({super.key, required this.percent, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background empty heart (grey outline)
        Icon(Icons.favorite, color: Colors.grey.shade300, size: size),

        // Foreground filled heart (red), clipped based on percent
        ClipRect(
          clipper: _HeartClipper(percent),
          child: Icon(Icons.favorite, color: Colors.red, size: size),
        ),

        // Optional: show text inside
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 3,
                color: Colors.black26,
                offset: Offset(1, 1),
              ),
            ],
          ),
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
    // height to fill
    final fillHeight = size.height * (percent.clamp(0, 100) / 100);
    return Rect.fromLTWH(
      0,
      size.height - fillHeight, // fill from bottom
      size.width,
      fillHeight,
    );
  }

  @override
  bool shouldReclip(_HeartClipper oldClipper) => oldClipper.percent != percent;
}
