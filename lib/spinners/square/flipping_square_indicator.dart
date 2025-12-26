import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with a square that flips alternately on vertical and horizontal axes.
///
/// A filled square rotates 180 degrees in 3D space, alternating between vertical flips
/// (X-axis rotation) and horizontal flips (Y-axis rotation). The flip animation uses
/// 55% of each half-cycle, with a brief pause before alternating to the other axis.
///
/// Example:
/// ```dart
/// FlippingSquareIndicator(
///   size: 80,
///   color: Colors.deepOrange,
///   duration: Duration(milliseconds: 1500),
/// )
/// ```
class FlippingSquareIndicator extends StatefulWidget {

  /// The width and height of the indicator area (creates a square container).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the square.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete cycle (two flips: vertical and horizontal).
  ///
  /// Defaults to 1200 milliseconds.
  final Duration duration;

  /// Creates a flipping square loading indicator.
  ///
  /// [size] - The width and height of the container (default: 60)
  /// [color] - The color of the square (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1200ms)
  const FlippingSquareIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<FlippingSquareIndicator> createState() =>
      _FlippingSquareIndicatorState();
}

class _FlippingSquareIndicatorState
    extends State<FlippingSquareIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize and start the repeating animation
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
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
            painter: _FlippingSquarePainter(
              t: _controller.value,
              color: widget.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a square with alternating 3D flip animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the square
/// [size] - Size of the indicator container
class _FlippingSquarePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the square.
  final Color color;

  /// Size of the indicator container.
  final double size;

  _FlippingSquarePainter({
    required this.t,
    required this.color,
    required this.size,
  });

  /// Portion of each half-cycle used for the flip animation (55%).
  /// The remaining 45% is a pause before alternating axes.
  static const double flipPortion = 0.55;

  /// Clamps a value between 0 and 1.
  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Fixed square size (36x36 pixels)
    const squareSize = 36.0;
    final cx = size / 2; // Center X
    final cy = size / 2; // Center Y

    // Determine which half of the cycle (0 = vertical flip, 1 = horizontal flip)
    final int cycle = (t * 2).floor();
    final bool flipVertically = cycle.isEven; // Even cycles flip vertically

    // Normalize progress within current half-cycle (0.0-1.0)
    final double localT = (t * 2) % 1.0;

    double angle;
    // Calculate rotation angle based on flip portion
    if (localT < flipPortion) {
      // Active flip: rotate from 0 to π (180°)
      angle = math.pi * _clamp01(localT / flipPortion);
    } else {
      // Pause: hold at π (180°)
      angle = math.pi;
    }

    // Create 3D transformation matrix with perspective
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.012); // Add perspective depth

    // Apply rotation based on current cycle
    if (flipVertically) {
      matrix.rotateX(angle); // Vertical flip (around horizontal axis)
    } else {
      matrix.rotateY(angle); // Horizontal flip (around vertical axis)
    }

    canvas.save();
    canvas.translate(cx, cy); // Move to center
    canvas.transform(matrix.storage); // Apply 3D transformation

    // Draw square centered at origin (after translation)
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlippingSquarePainter old) =>
      old.t != t || old.color != color;
}