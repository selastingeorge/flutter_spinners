import 'package:flutter/material.dart';

/// An animated loading indicator with four dots at square corners that swap positions.
///
/// Four dots positioned at the corners of an invisible square alternately swap positions.
/// In the first half of the cycle, diagonal dots (top-left ↔ bottom-right) swap places.
/// In the second half, the other diagonal pair (top-right ↔ bottom-left) swaps.
/// The square is scaled to 80% to create tighter spacing between dots.
///
/// Example:
/// ```dart
/// QuadDotSwapIndicator(
///   size: 80,
///   color: Colors.orange,
///   duration: Duration(milliseconds: 1400),
/// )
/// ```
class QuadDotSwapIndicator extends StatefulWidget {
  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete cycle (both diagonal swaps).
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a quad dot swap loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const QuadDotSwapIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<QuadDotSwapIndicator> createState() => _QuadDotSwapIndicatorState();
}

class _QuadDotSwapIndicatorState extends State<QuadDotSwapIndicator>
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
            painter: _QuadDotSwapPainter(
              t: _controller.value,
              dotColor: widget.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws four dots with alternating diagonal swap animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [dotColor] - Color of the dots
/// [size] - The size of the indicator (square)
class _QuadDotSwapPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the dots.
  final Color dotColor;

  /// Size of the indicator.
  final double size;

  _QuadDotSwapPainter({
    required this.t,
    required this.dotColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final dotPaint = Paint()..color = dotColor;

    // Calculate base square dimensions (60% of indicator size)
    final baseSquareSize = size * 0.6;
    final dotRadius =
        baseSquareSize * 0.145; // Dot radius (14.5% of base square)

    // Adjust square size to account for dot radius
    final squareSize = baseSquareSize - dotRadius * 2;

    // Center the square within the indicator
    final offset = Offset(
      (size - baseSquareSize) / 2 + dotRadius,
      (size - baseSquareSize) / 2 + dotRadius,
    );

    // Define the four corner positions (clockwise from top-left)
    List<Offset> corners = [
      offset + Offset(0, 0), // Top-left
      offset + Offset(squareSize, 0), // Top-right
      offset + Offset(squareSize, squareSize), // Bottom-right
      offset + Offset(0, squareSize), // Bottom-left
    ];

    // Calculate center point of the square
    final center = offset + Offset(squareSize / 2, squareSize / 2);

    // Scale corners toward center by 80% to tighten spacing
    corners = corners.map((corner) {
      final dx = center.dx + (corner.dx - center.dx) * 0.8;
      final dy = center.dy + (corner.dy - center.dy) * 0.8;
      return Offset(dx, dy);
    }).toList();

    // Split animation into two halves (each swap takes half the cycle)
    double cycleT = (t * 2) % 1; // Normalize to 0-1 for current swap
    int swapStep = (t * 2).floor(); // 0 = first diagonal, 1 = second diagonal

    // Apply smooth easing to swap motion
    final easedT = Curves.easeInOutCubic.transform(cycleT);

    // Start with dots at corner positions
    List<Offset> dots = List.from(corners);

    // Alternate between diagonal swaps
    if (swapStep == 0) {
      // First half: swap top-left (0) ↔ bottom-right (2)
      dots[0] = Offset.lerp(corners[0], corners[2], easedT)!;
      dots[2] = Offset.lerp(corners[2], corners[0], easedT)!;
    } else {
      // Second half: swap top-right (1) ↔ bottom-left (3)
      dots[1] = Offset.lerp(corners[1], corners[3], easedT)!;
      dots[3] = Offset.lerp(corners[3], corners[1], easedT)!;
    }

    // Draw all four dots at their current positions
    for (final dot in dots) {
      canvas.drawCircle(dot, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuadDotSwapPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.dotColor != dotColor;
}
