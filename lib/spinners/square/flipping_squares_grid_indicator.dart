import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with a 2x2 grid of squares that flip sequentially in 3D.
///
/// Four squares arranged in a 2x2 grid flip one by one with a stagger effect,
/// alternating between vertical flips (X-axis rotation) and horizontal flips
/// (Y-axis rotation). Each square flips 180 degrees with a brief pause before
/// the next square starts, creating a wave-like sequential animation.
///
/// Example:
/// ```dart
/// FlippingSquaresGridIndicator(
///   size: 50,
///   color: Colors.teal,
///   duration: Duration(milliseconds: 2500),
/// )
/// ```
class FlippingSquaresGridIndicator extends StatefulWidget {
  /// The width and height of the entire grid (creates a square container).
  ///
  /// Defaults to 36.
  final double size;

  /// The color of the squares.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete cycle (all squares flip twice: vertical and horizontal).
  ///
  /// Defaults to 2000 milliseconds.
  final Duration duration;

  /// Creates a flipping squares grid loading indicator.
  ///
  /// [size] - The width and height of the grid (default: 36)
  /// [color] - The color of the squares (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 2000ms)
  const FlippingSquaresGridIndicator({
    super.key,
    this.size = 36,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<FlippingSquaresGridIndicator> createState() =>
      _FlippingSquaresGridIndicatorState();
}

class _FlippingSquaresGridIndicatorState
    extends State<FlippingSquaresGridIndicator>
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
            painter: _FlippingSquaresGridPainter(
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

/// Custom painter that draws a 2x2 grid of squares with sequential 3D flip animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the squares
/// [size] - Size of the entire grid
class _FlippingSquaresGridPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the squares.
  final Color color;

  /// Size of the entire grid.
  final double size;

  _FlippingSquaresGridPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  /// Number of cells in the 2x2 grid.
  static const int cellCount = 4;

  /// Portion of time used for each square's flip animation (16%).
  static const double flipPortion = 0.16;

  /// Pause duration between consecutive square flips (9%).
  static const double pausePortion = 0.09;

  /// Clamps a value between 0 and 1.
  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  /// Calculates animation progress within a specific time range.
  ///
  /// [t] - Current time
  /// [start] - Start time of the range
  /// [len] - Length of the time range
  double _progress(double t, double start, double len) =>
      _clamp01((t - start) / len);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Each cell is half the total size (2x2 grid)
    final cell = size / 2;

    // Time between consecutive square flips
    final step = flipPortion + pausePortion;

    // Determine flip direction: even cycles flip vertically, odd cycles flip horizontally
    final bool verticalFlip = ((t * 2).floor() % 2) == 0;

    // Draw and animate each of the 4 squares
    for (int i = 0; i < cellCount; i++) {
      // Calculate when this square should start flipping
      final start = i * step;

      // Calculate flip progress for this square within the current half-cycle
      final k = _progress(t % 0.5 * 2, start, flipPortion);

      // Calculate grid position (row and column)
      final row = i ~/ 2; // Integer division: 0-1 → row 0, 2-3 → row 1
      final col = i % 2; // Modulo: 0,2 → col 0, 1,3 → col 1

      // Calculate center position of this square
      final cx = col * cell + cell / 2;
      final cy = row * cell + cell / 2;

      // Calculate rotation angle (0 to π radians / 180 degrees)
      final angle = math.pi * k;

      // Create 3D transformation matrix with perspective
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.012); // Add perspective depth

      // Apply rotation based on current cycle
      if (verticalFlip) {
        matrix.rotateX(angle); // Vertical flip (around horizontal axis)
      } else {
        matrix.rotateY(angle); // Horizontal flip (around vertical axis)
      }

      canvas.save();
      canvas.translate(cx, cy); // Move to square center
      canvas.transform(matrix.storage); // Apply 3D transformation

      // Draw square centered at origin (after translation)
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: cell, height: cell),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlippingSquaresGridPainter old) =>
      old.t != t || old.color != color;
}
