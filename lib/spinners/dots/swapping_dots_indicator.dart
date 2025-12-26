import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// An animated loading indicator with three dots that rotate positions with an arc motion.
///
/// Three horizontally aligned dots continuously rotate positions. The rightmost dot
/// jumps to the leftmost position by traveling in an upward arc, while the other
/// two dots slide linearly to the right. This creates a smooth cycling effect.
///
/// Example:
/// ```dart
/// SwappingDotsIndicator(
///   size: 80,
///   color: Colors.deepOrange,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
class SwappingDotsIndicator extends StatefulWidget {
  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete rotation cycle through all positions.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a swapping dots loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const SwappingDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<SwappingDotsIndicator> createState() => _SwappingDotsIndicatorState();
}

class _SwappingDotsIndicatorState extends State<SwappingDotsIndicator>
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
      height: widget.size / 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _SwappingDotsPainter(
              progress: _controller.value,
              color: widget.color,
              width: widget.size,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three dots with rotation and arc motion animation.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the dots
/// [width] - Width of the indicator area
class _SwappingDotsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Color of the dots.
  final Color color;

  /// Width of the indicator area.
  final double width;

  _SwappingDotsPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Dot dimensions and positioning
    final radius = size.height * 0.35; // Dot radius (35% of height)
    const int dotCount = 3;
    final spacing = width / dotCount; // Space allocated per dot
    final baselineY = size.height / 2; // Baseline vertical position

    // Calculate the three slot positions (left, middle, right)
    final slots = List.generate(dotCount, (i) => i * spacing + spacing / 2);

    // Normalize progress to 0-1 for current cycle (repeats dotCount times per full progress)
    final cycleProgress = (progress * dotCount) % 1;

    // Draw three dots with position interpolation
    for (int i = 0; i < dotCount; i++) {
      double dx;
      double dy = baselineY;

      // Last dot (rightmost) travels in an arc to become first dot (leftmost)
      if (i == dotCount - 1) {
        final start = slots[i]; // Current rightmost position
        final end = slots[0]; // Target leftmost position

        // Interpolate horizontal position from right to left
        dx = lerpDouble(start, end, cycleProgress)!;

        // Create upward arc using sine wave (0 → peak → 0)
        final arcHeight =
            size.height * 1.2; // Arc peak height (120% of indicator height)
        dy -= arcHeight * math.sin(cycleProgress * math.pi);
      }
      // Other dots slide linearly to the right
      else {
        final start = slots[i]; // Current position
        final end = slots[i + 1]; // Next position to the right

        // Interpolate horizontal position linearly
        dx = lerpDouble(start, end, cycleProgress)!;
      }

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwappingDotsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
