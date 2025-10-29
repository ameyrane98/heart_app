import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class LiquidHeartChart extends StatelessWidget {
  const LiquidHeartChart({
    super.key,
    required this.percent,
    this.size = 220,
    this.backgroundColor = const Color(0x408BCD8D),
    this.fillColor = Colors.pink,
    this.borderColor = Colors.red,
    this.borderWidth = 0,
    this.showPercentText = true,
  });

  /// 0–100: how full the heart is.
  final double percent;

  final double size;
  final Color backgroundColor;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final bool showPercentText;

  @override
  Widget build(BuildContext context) {
    final fillValue = (percent.clamp(0, 100)) / 100.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Liquid fill
          LiquidCustomProgressIndicator(
            value: fillValue,
            direction: Axis.vertical,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(fillColor),
            shapePath: _buildHeartPath(Size(size, size)),
            center: showPercentText
                ? Text(
                    '${percent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Path _buildHeartPath(Size size) {
    final w = size.width;
    final h = size.height;
    final pad = borderWidth / 2 + 2.0;
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
}

class _HeartBorderPainter extends CustomPainter {
  _HeartBorderPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final pad = strokeWidth / 2 + 2.0;
    final sx = size.width - 2 * pad;
    final sy = size.height - 2 * pad;
    final ox = pad;
    final oy = pad;

    final path = Path()
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

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartBorderPainter old) {
    return old.color != color || old.strokeWidth != strokeWidth;
  }
}
