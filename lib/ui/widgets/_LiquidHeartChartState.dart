import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

/// A self-contained heart with a rising liquid fill.
/// - Tap the button to Start/Pause the animation.
/// - Use [size] and [duration] to customize behavior.
///
/// Beginner tips included as comments throughout.
class LiquidHeartChart extends StatefulWidget {
  const LiquidHeartChart({
    super.key,
    this.size = 220,
    this.duration = const Duration(seconds: 4),
    this.backgroundColor = const Color(0x408BCD8D), // light green with opacity
    this.fillColor = const Color(0xFF096B49), // deep green
    this.borderColor = Colors.red, // heart outline
    this.borderWidth = 3.0,
    this.showPercentText = true,
  });

  /// Square size of the heart.
  final double size;

  /// How long the fill animation takes from 0 → 100%.
  final Duration duration;

  /// Color behind the liquid.
  final Color backgroundColor;

  /// Liquid color (the fill).
  final Color fillColor;

  /// Outline color drawn on top of the heart.
  final Color borderColor;

  /// Outline thickness.
  final double borderWidth;

  /// Whether to display "XX%" at the center.
  final bool showPercentText;

  @override
  State<LiquidHeartChart> createState() => _LiquidHeartChartState();
}

class _LiquidHeartChartState extends State<LiquidHeartChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // The animation controller goes from 0.0 → 1.0 over [widget.duration].
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // (Optional learning aid) See lifecycle in your debug console.
    debugPrint('LiquidHeartChart initState');
  }

  @override
  void dispose() {
    _animationController.dispose();
    debugPrint('LiquidHeartChart disposed'); // helpful while learning
    super.dispose();
  }

  /// Toggle Start/Pause. If finished (value >= 1.0), restart from 0.
  void _toggle() {
    if (_isAnimating) {
      _animationController.stop();
      setState(() => _isAnimating = false);
    } else {
      final from = _animationController.value >= 1.0
          ? 0.0
          : _animationController.value;
      _animationController.forward(from: from);
      setState(() => _isAnimating = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder rebuilds just this subtree whenever the controller ticks.
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        // Keep progress safely between 0.0 and 1.0
        final fillPercent = _animationController.value.clamp(0.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                children: [
                  // 1) The liquid, clipped to the heart path
                  LiquidCustomProgressIndicator(
                    value: fillPercent,
                    direction: Axis.vertical,
                    backgroundColor: widget.backgroundColor,
                    valueColor: AlwaysStoppedAnimation(widget.fillColor),
                    shapePath: _buildHeartPath(Size(widget.size, widget.size)),
                    center: widget.showPercentText
                        ? Text(
                            '${(fillPercent * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),

                  // 2) A simple border outline drawn on top (for a crisp edge)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HeartBorderPainter(
                        color: widget.borderColor,
                        strokeWidth: widget.borderWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds a single, closed heart path that fits inside [size].
  /// Tip: Think of [sx]/[sy] as scaled width/height, and [ox]/[oy] as padding.
  Path _buildHeartPath(Size size) {
    final w = size.width;
    final h = size.height;

    // Keep nice margins so the outline isn't clipped.
    final pad = widget.borderWidth / 2 + 2.0;
    final sx = w - 2 * pad;
    final sy = h - 2 * pad;
    final ox = pad;
    final oy = pad;

    final path = Path()
      // Start at the top center of the heart
      ..moveTo(ox + 0.50 * sx, oy + 0.28 * sy)
      // Left lobe & left side
      ..cubicTo(
        ox + 0.20 * sx,
        oy + 0.00 * sy, // control 1
        ox - 0.10 * sx,
        oy + 0.35 * sy, // control 2
        ox + 0.50 * sx,
        oy + 0.95 * sy, // bottom point
      )
      // Right side & right lobe back to top
      ..cubicTo(
        ox + 1.10 * sx,
        oy + 0.35 * sy, // control 1
        ox + 0.80 * sx,
        oy + 0.00 * sy, // control 2
        ox + 0.50 * sx,
        oy + 0.28 * sy, // back to top center
      )
      ..close();

    return path;
  }
}

/// Minimal painter to draw the heart outline on top of the liquid.
/// (Uses the exact same path math for consistency.)
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

    // Keep the same padding logic as in _buildHeartPath
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
  bool shouldRepaint(covariant _HeartBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
