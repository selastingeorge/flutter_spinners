import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with three vertical bars that flip sequentially in 3D.
///
/// Each bar rotates 180 degrees around its horizontal axis in sequence from left to right,
/// creating a smooth 3D flipping effect with perspective depth.
///
/// Example:
/// ```dart
/// FlippingBarsIndicator(
///   size: 80,
///   color: Colors.orange,
///   duration: Duration(milliseconds: 1500),
///   borderRadius: 4,
/// )
/// ```
class FlippingBarsIndicator extends StatefulWidget {
  /// The width of the indicator. Height is automatically set to 80% of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle through all bars.
  ///
  /// Defaults to 1200 milliseconds.
  final Duration duration;

  /// The border radius for rounding the corners of each bar.
  ///
  /// Defaults to 0 (sharp corners).
  final double borderRadius;

  /// Creates a flipping bars loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1200ms)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const FlippingBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1200),
    this.borderRadius = 0,
  });

  @override
  State<FlippingBarsIndicator> createState() => _FlippingBarsIndicatorState();
}

class _FlippingBarsIndicatorState extends State<FlippingBarsIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize and start the repeating animation
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
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
      height: widget.size * 0.8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _FlippingBarsPainter(
              t: _controller.value,
              color: widget.color,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three bars with sequential 3D flip animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [borderRadius] - Border radius for bar corners
class _FlippingBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Border radius for bar corners.
  final double borderRadius;

  _FlippingBarsPainter({required this.t, required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Bar dimensions: 10% width, 65% height
    final barWidth = size.width * 0.10;
    final barHeight = size.height * 0.65;

    final gap = barWidth;

    // Calculate horizontal positions to center the bars
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size.width - totalBarsWidth) / 2;
    final centerY = size.height / 2;

    // Animation timing: divide timeline into slots for each bar
    const barCount = 3;
    final slot = 1.0 / barCount; // Each bar gets 1/3 of the timeline
    final depth = 0.0025; // Perspective depth for 3D effect

    // Draw each bar with sequential flip animation
    for (int i = 0; i < barCount; i++) {
      final x = startX + i * (barWidth + gap);

      // Calculate time window for this bar's animation
      final start = i * slot;
      final end = start + slot;

      double angle = 0;

      // Determine rotation angle based on animation progress
      if (t >= start && t < end) {
        // Bar is currently flipping
        final localT = (t - start) / slot;
        angle = localT * math.pi; // Rotate from 0 to π (180°)
      } else if (t >= end) {
        // Bar has finished flipping
        angle = math.pi;
      }

      // Apply 3D transformation with perspective
      canvas.save();
      canvas.translate(x + barWidth / 2, centerY); // Move to bar center

      // Create perspective matrix and apply X-axis rotation
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, depth) // Add perspective depth
        ..rotateX(angle); // Rotate around horizontal axis
      canvas.transform(matrix.storage);

      // Draw the bar centered at origin (after translation)
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: barWidth, height: barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlippingBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
