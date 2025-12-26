import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// An animated loading indicator with a 3x3 grid of squares that shimmer diagonally.
///
/// Nine squares arranged in a grid display a shimmer effect that travels diagonally
/// from top-left to bottom-right. Squares brighten and fade based on their distance
/// from the shimmer wave using a gaussian-like intensity curve.
///
/// Example:
/// ```dart
/// ShimmeringSquareGridIndicator(
///   size: 80,
///   color: Colors.indigo,
///   duration: Duration(milliseconds: 1500),
/// )
/// ```
class ShimmeringSquareGridIndicator extends StatefulWidget {
  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The base color of the squares (alpha is modulated for shimmer effect).
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete shimmer cycle across the grid.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a shimmering square grid loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The base color of the squares (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const ShimmeringSquareGridIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<ShimmeringSquareGridIndicator> createState() =>
      _ShimmeringSquareGridIndicatorState();
}

class _ShimmeringSquareGridIndicatorState
    extends State<ShimmeringSquareGridIndicator>
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
            painter: _ShimmeringSquareGridPainter(
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

/// Custom painter that draws a 3x3 grid of squares with diagonal shimmer effect.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Base color of the squares (alpha is modulated for shimmer)
/// [size] - The size of the indicator (square)
class _ShimmeringSquareGridPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Base color of the squares.
  final Color color;

  /// Size of the indicator.
  final double size;

  _ShimmeringSquareGridPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size s) {
    // Grid takes up 70% of the indicator size
    final gridSize = size * 0.7;
    final spacing = gridSize / 3; // Space between square centers
    final squareSize = spacing * 0.7; // Each square is 70% of spacing

    // Center the grid within the indicator
    final offset = Offset((size - gridSize) / 2, (size - gridSize) / 2);

    // Shimmer position travels diagonally from -1 to 5 (covers diagonal indices 0-4)
    // This range ensures shimmer enters and exits the grid smoothly
    final shimmerPos = lerpDouble(-1, 5, t)!;

    // Draw 3x3 grid of squares
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        // Diagonal index: squares along same diagonal have same sum (row + col)
        // Diagonals: 0 (top-left), 1, 2, 3, 4 (bottom-right)
        final diagonalIndex = row + col;

        // Calculate distance from shimmer wave position
        final dist = (diagonalIndex - shimmerPos).abs();

        // Apply gaussian-like intensity curve (closer = brighter)
        // exp(-dist² * 1.6) creates a sharp, focused shimmer wave
        final intensity = math.exp(-dist * dist * 1.6);

        // Map intensity to alpha: dim (70) to bright (255)
        final alpha = (70 + intensity * 185).round().clamp(0, 255);

        final paint = Paint()..color = color.withAlpha(alpha);

        // Calculate square position (centered within its cell)
        final dx = offset.dx + col * spacing + (spacing - squareSize) / 2;
        final dy = offset.dy + row * spacing + (spacing - squareSize) / 2;

        canvas.drawRect(Rect.fromLTWH(dx, dy, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShimmeringSquareGridPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
