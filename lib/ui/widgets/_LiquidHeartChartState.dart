import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class LiquidHeartChart extends StatefulWidget {
  const LiquidHeartChart({
    super.key,
    required this.percent, // 0..100
    this.size = 240, // width; height = 0.8 * size
    this.backgroundColor,
    this.fillColor,
    this.borderColor,
    this.borderWidth = 4.0,
    this.onTap, // optional: make the heart clickable
  });

  final double percent; // 0..100
  final double size;
  final Color? backgroundColor;
  final Color? fillColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  State<LiquidHeartChart> createState() => _LiquidHeartChartState();
}

class _LiquidHeartChartState extends State<LiquidHeartChart> {
  // Build a heart path using two cubic Bézier arches.
  Path _heartPath(double width) {
    final height = width * 0.8;
    return Path()
      // left arch
      ..moveTo(0.5 * width, 0.27 * height)
      ..cubicTo(
        0.4 * width,
        0.0 * height,
        -0.27 * width,
        0.2 * height,
        0.5 * width,
        0.9 * height,
      )
      // right arch
      ..moveTo(0.5 * width, 0.27 * height)
      ..cubicTo(
        0.6 * width,
        0.0 * height,
        1.27 * width,
        0.2 * height,
        0.5 * width,
        0.9 * height,
      );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.size;
    final h = w * 0.8;
    final path = _heartPath(w);

    final core = Stack(
      alignment: Alignment.center,
      children: [
        // Liquid fill inside the heart path (0..1). The package animates the waves.
        SizedBox(
          width: w,
          height: h,
          child: LiquidCustomProgressIndicator(
            value: (widget.percent.clamp(0, 100)) / 100.0, // 0..1
            direction: Axis.vertical,
            backgroundColor: (widget.backgroundColor ?? Colors.red.shade100)
                .withOpacity(0.25),
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.fillColor ?? Colors.redAccent,
            ),
            shapePath: path,
            center: Text(
              '${widget.percent.clamp(0, 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
          ),
        ),

        // Crisp outline on top
        IgnorePointer(
          child: CustomPaint(
            size: Size(w, h),
            painter: _HeartOutlinePainter(
              path: path,
              color: widget.borderColor ?? Colors.red,
              strokeWidth: widget.borderWidth,
            ),
          ),
        ),
      ],
    );

    // Optional tap wrapper for start/pause toggle, etc.
    return widget.onTap == null
        ? core
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(w / 2),
              onTap: widget.onTap,
              child: Padding(padding: const EdgeInsets.all(8.0), child: core),
            ),
          );
  }
}

class _HeartOutlinePainter extends CustomPainter {
  _HeartOutlinePainter({
    required this.path,
    required this.color,
    required this.strokeWidth,
  });

  final Path path;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _HeartOutlinePainter old) =>
      old.path != path || old.color != color || old.strokeWidth != strokeWidth;
}
