import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with three dots that flip sequentially in 3D.
///
/// Three horizontally aligned dots take turns flipping 180 degrees around their
/// horizontal axis with perspective depth. Each dot flips in sequence from left
/// to right, creating a wave-like 3D flipping effect.
///
/// Example:
/// ```dart
/// FlippingDotsIndicator(
///   size: 80,
///   color: Colors.pink,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
class FlippingDotsIndicator extends StatefulWidget {

  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle through all three dots.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a flipping dots loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const FlippingDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<FlippingDotsIndicator> createState() => _FlippingDotsIndicatorState();
}

class _FlippingDotsIndicatorState extends State<FlippingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize and start the repeating animation
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
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
      height: widget.size / 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _FlippingDotsPainter(
              t: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three dots with sequential 3D flip animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the dots
class _FlippingDotsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the dots.
  final Color color;

  _FlippingDotsPainter({
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Dot dimensions and positioning
    final radius = size.height * 0.35; // Dot radius (35% of height)
    final cy = size.height / 2; // Vertical center
    final spacing = size.width / 3; // Space between dots

    // Determine which dot is currently flipping (cycles through 0, 1, 2)
    final activeIndex = (t * 3).floor() % 3;

    // Calculate position within the current dot's flip animation (0-1)
    final localT = (t * 3) % 1.0;

    // Perspective depth for 3D effect
    const double perspective = 0.004;

    // Draw three dots
    for (int i = 0; i < 3; i++) {
      // Calculate horizontal center position for this dot
      final dx = spacing * i + spacing / 2;

      canvas.save();
      canvas.translate(dx, cy); // Move to dot center

      // Apply 3D flip transformation only to the active dot
      if (i == activeIndex) {
        final angle = localT * math.pi; // Rotate from 0 to π (180°)

        // Create perspective matrix and apply X-axis rotation
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, perspective) // Add perspective depth
          ..rotateX(angle); // Rotate around horizontal axis

        canvas.transform(matrix.storage);
      }

      // Draw the dot at origin (after translation)
      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlippingDotsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}