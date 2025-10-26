import 'package:flutter/material.dart';

/// HeartPainterFill
/// ----------------
/// Max-control, gradient fill using CustomPainter + Canvas.
/// - Fill rises bottom→top according to [percent] (0..100)
/// - Smooth vertical gradient, crisp border, optional soft shadow & gloss
///
/// Example:
///   HeartPainterFill(
///     percent: vm.progress,
///     size: 220,
///     gradient: const LinearGradient(
///       begin: Alignment.bottomCenter,
///       end: Alignment.topCenter,
///       colors: [Color(0xFFFF4B5C), Color(0xFFFF9AA2)],
///     ),
///     backgroundColor: Color(0xFFF1F1F1),
///     borderColor: Colors.red,
///     borderWidth: 4,
///     shadowElevation: 8,
///     showGloss: true,
///   )
class HeartPainterFill extends StatelessWidget {
  const HeartPainterFill({
    super.key,
    required this.percent, // 0..100
    this.size = 220,
    this.gradient = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFFE53935), Color(0xFFFFA1A1)],
      stops: [0.2, 1.0],
    ),
    this.backgroundColor = const Color(0xFFEAEAEA),
    this.borderColor = const Color(0xFFB00020),
    this.borderWidth = 3.0,
    this.shadowElevation = 6.0,
    this.showGloss = true,
  });

  final double percent;
  final double size;
  final LinearGradient gradient;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowElevation; // 0 to disable
  final bool showGloss;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0) / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HeartFillPainter(
          fill: clamped,
          gradient: gradient,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          shadowElevation: shadowElevation,
          showGloss: showGloss,
        ),
      ),
    );
  }
}

class _HeartFillPainter extends CustomPainter {
  _HeartFillPainter({
    required this.fill, // 0..1
    required this.gradient,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowElevation,
    required this.showGloss,
  });

  final double fill;
  final LinearGradient gradient;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowElevation;
  final bool showGloss;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildHeartPath(size, borderWidth);

    // Optional soft shadow for “lifted” look
    if (shadowElevation > 0) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          _sigmaForElevation(shadowElevation),
        );
      canvas.drawPath(path, shadowPaint);
    }

    // Background inside heart
    canvas.save();
    canvas.clipPath(path);
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Fill from bottom up (only the lower portion)
    final bounds = path.getBounds();
    final filledHeight = bounds.height * fill;

    // Shader for the gradient fill (span entire heart bounds for consistent look)
    final shader = gradient.createShader(bounds);

    final fillPaint = Paint()..shader = shader;
    final fillRect = Rect.fromLTWH(
      bounds.left,
      bounds.bottom - filledHeight,
      bounds.width,
      filledHeight,
    );
    canvas.drawRect(fillRect, fillPaint);

    // Optional glossy highlight on the top area
    if (showGloss) {
      final glossHeight = bounds.height * 0.35;
      final glossRect = Rect.fromLTWH(
        bounds.left,
        bounds.top,
        bounds.width,
        glossHeight,
      );
      final glossGradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
        stops: [0.0, 1.0],
      );
      final glossPaint = Paint()
        ..shader = glossGradient.createShader(glossRect);
      canvas.drawRect(glossRect, glossPaint);
    }

    canvas.restore();

    // Border on top
    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..isAntiAlias = true;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _HeartFillPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.gradient != gradient ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.shadowElevation != shadowElevation ||
        oldDelegate.showGloss != showGloss;
  }
}

/// Shared heart path math (closed, single path, padded for border).
Path _buildHeartPath(Size size, double strokeWidth) {
  final w = size.width;
  final h = size.height;

  final pad = strokeWidth / 2 + 2.0;
  final sx = w - 2 * pad;
  final sy = h - 2 * pad;
  final ox = pad;
  final oy = pad;

  return Path()
    ..moveTo(ox + 0.50 * sx, oy + 0.28 * sy)
    ..cubicTo(
      ox + 0.20 * sx,
      oy + 0.00 * sy,
      ox - 0.10 * sx,
      oy + 0.35 * sy,
      ox + 0.50 * sx,
      oy + 0.95 * sy,
    )
    ..cubicTo(
      ox + 1.10 * sx,
      oy + 0.35 * sy,
      ox + 0.80 * sx,
      oy + 0.00 * sy,
      ox + 0.50 * sx,
      oy + 0.28 * sy,
    )
    ..close();
}

/// Convert elevation-ish value to a reasonable blur sigma.
double _sigmaForElevation(double e) {
  // Light mapping: larger e -> stronger blur.
  return 0.6 * e + 0.8;
}
