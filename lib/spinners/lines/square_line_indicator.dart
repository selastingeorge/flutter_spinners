import 'package:flutter/material.dart';

/// An animated loading indicator that draws a square outline progressively.
///
/// A square outline is drawn clockwise, with each side appearing in sequence
/// (top → right → bottom → left). After completing the square, the animation
/// reverses and the lines disappear in the same order, creating a breathing effect.
///
/// Example:
/// ```dart
/// SquareLineIndicator(
///   size: 50,
///   color: Colors.green,
///   duration: Duration(milliseconds: 1500),
///   strokeWidth: 5,
/// )
/// ```
class SquareLineIndicator extends StatefulWidget {
  /// The width and height of the square indicator.
  ///
  /// Defaults to 35.
  final double size;

  /// The color of the square outline.
  ///
  /// Defaults to Color(0xFF046D8B).
  final Color color;

  /// The duration of one complete cycle (drawing and erasing the square).
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The width of the line stroke.
  ///
  /// Defaults to 4.
  final double strokeWidth;

  /// Creates a square line loading indicator.
  ///
  /// [size] - The width and height of the square (default: 35)
  /// [color] - The color of the outline (default: Color(0xFF046D8B))
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [strokeWidth] - Width of the line stroke (default: 4)
  const SquareLineIndicator({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF046D8B),
    this.duration = const Duration(seconds: 1),
    this.strokeWidth = 4,
  });

  @override
  State<SquareLineIndicator> createState() => _SquareLineIndicatorState();
}

class _SquareLineIndicatorState extends State<SquareLineIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize animation with reverse: draws square, then erases it
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
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
            painter: _SquareLinePainter(
              t: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a square outline with progressive reveal animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the square outline
/// [strokeWidth] - Width of the line stroke
class _SquareLinePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the square outline.
  final Color color;

  /// Width of the line stroke.
  final double strokeWidth;

  _SquareLinePainter({
    required this.t,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    final half = strokeWidth / 2; // Half stroke width for centering

    // Progress values for each side (0.0 = not started, 1.0 = complete)
    double top = 0, right = 0, bottom = 0, left = 0;

    // Calculate progress for each side based on animation time
    // Timeline is divided into 4 equal quarters, one for each side
    if (t < 0.25) {
      // First quarter: draw top side
      top = t / 0.25;
    } else if (t < 0.5) {
      // Second quarter: top complete, draw right side
      top = 1;
      right = (t - 0.25) / 0.25;
    } else if (t < 0.75) {
      // Third quarter: top and right complete, draw bottom side
      top = right = 1;
      bottom = (t - 0.5) / 0.25;
    } else {
      // Final quarter: top, right, and bottom complete, draw left side
      top = right = bottom = 1;
      left = (t - 0.75) / 0.25;
    }

    // Draw top side (left to right)
    if (top > 0) {
      canvas.drawLine(
        Offset(half, half), // Start at top-left corner
        Offset(half + (w - strokeWidth) * top, half), // End based on progress
        paint,
      );
    }

    // Draw right side (top to bottom)
    if (right > 0) {
      canvas.drawLine(
        Offset(w - half, half), // Start at top-right corner
        Offset(
          w - half,
          half + (h - strokeWidth) * right,
        ), // End based on progress
        paint,
      );
    }

    // Draw bottom side (right to left)
    if (bottom > 0) {
      canvas.drawLine(
        Offset(w - half, h - half), // Start at bottom-right corner
        Offset(
          w - half - (w - strokeWidth) * bottom,
          h - half,
        ), // End based on progress
        paint,
      );
    }

    // Draw left side (bottom to top)
    if (left > 0) {
      canvas.drawLine(
        Offset(half, h - half), // Start at bottom-left corner
        Offset(
          half,
          h - half - (h - strokeWidth) * left,
        ), // End based on progress
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SquareLinePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
