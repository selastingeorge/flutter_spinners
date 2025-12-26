import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with three bars that stretch vertically then horizontally.
///
/// Three square bars alternate between stretching into vertical lines (expanding and collapsing)
/// and horizontal lines (expanding and collapsing). Bars maintain their center position while
/// stretching in both directions, creating a pulsing effect.
///
/// Example:
/// ```dart
/// StretchBarsIndicator(
///   size: 80,
///   color: Colors.amber,
///   duration: Duration(milliseconds: 1200),
///   borderRadius: 3,
/// )
/// ```
class StretchBarsIndicator extends StatefulWidget {
  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle (vertical stretch, horizontal stretch).
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The border radius for rounding the corners of each bar.
  ///
  /// Defaults to 0 (sharp corners).
  final double borderRadius;

  /// Creates a stretch bars loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const StretchBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<StretchBarsIndicator> createState() => _StretchBarsIndicatorState();
}

class _StretchBarsIndicatorState extends State<StretchBarsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize and start the repeating animation
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _StretchBarsPainter(
              t: _controller.value,
              color: widget.color,
              size: widget.size,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three bars with alternating vertical and horizontal stretch animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator (square)
/// [borderRadius] - Border radius for bar corners
class _StretchBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  /// Border radius for bar corners.
  final double borderRadius;

  /// Gap between bars in pixels.
  final int gap = 6;

  _StretchBarsPainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  /// Base size of each bar when not stretched (6x6 pixels).
  static const double bar = 6.0;

  /// Applies ease-in easing using sine function.
  double _ease(double t) => math.sin(t * math.pi / 2);

  /// Extracts a normalized segment [0-1] from a time range [a, b].
  ///
  /// [t] - Current time
  /// [a] - Segment start time
  /// [b] - Segment end time
  double _seg(double t, double a, double b) {
    if (t <= a) return 0;
    if (t >= b) return 1;
    return (t - a) / (b - a);
  }

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Calculate layout dimensions for 3x3 grid of bars
    final layoutW = bar * 3 + gap * 2;
    final layoutH = bar * 3 + gap * 2;
    final ox = (size - layoutW) / 2;
    final oy = (size - layoutH) / 2;

    // Base positions for the three bars (diagonal: top-left, middle, bottom-right)
    final baseX = [ox, ox + bar + gap, ox + (bar + gap) * 2];
    final baseY = [oy, oy + bar + gap, oy + (bar + gap) * 2];

    // Animation phases with time segments (0.00-1.00)
    // Vertical: expand (0.00-0.15), collapse (0.22-0.37)
    // Horizontal: expand (0.44-0.59), collapse (0.66-0.81)
    final vExpand = _ease(_seg(t, 0.00, 0.15));
    final vCollapse = _ease(_seg(t, 0.22, 0.37));
    final hExpand = _ease(_seg(t, 0.44, 0.59));
    final hCollapse = _ease(_seg(t, 0.66, 0.81));

    final vLen = layoutH; // Maximum vertical stretch length
    final hLen = layoutW; // Maximum horizontal stretch length

    // Draw three bars with stretch animation
    for (int i = 0; i < 3; i++) {
      double dx = baseX[i];
      double dy = baseY[i];
      double w = bar;
      double h = bar;

      // Apply vertical stretch/collapse
      if (vExpand > 0 && vCollapse == 0) {
        // Vertical expand phase: bars stretch vertically
        final k = vExpand;
        h = bar + (vLen - bar) * k;
        // Offset position to maintain center (different offset per bar index)
        dy = baseY[i] - (vLen - bar) * k * (i / 2.0);
      } else if (vCollapse > 0) {
        // Vertical collapse phase: bars shrink back to square
        final k = 1 - vCollapse;
        h = bar + (vLen - bar) * k;
        dy = baseY[i] - (vLen - bar) * k * (i / 2.0);
      }

      // Apply horizontal stretch/collapse
      if (hExpand > 0 && hCollapse == 0) {
        // Horizontal expand phase: bars stretch horizontally
        final k = hExpand;
        w = bar + (hLen - bar) * k;
        // Offset position to maintain center (different offset per bar index)
        dx = baseX[i] - (hLen - bar) * k * (i / 2.0);
      } else if (hCollapse > 0) {
        // Horizontal collapse phase: bars shrink back to square
        final k = 1 - hCollapse;
        w = bar + (hLen - bar) * k;
        dx = baseX[i] - (hLen - bar) * k * (i / 2.0);
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(dx, dy, w, h),
          Radius.circular(borderRadius),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StretchBarsPainter old) =>
      old.t != t || old.color != color;
}
