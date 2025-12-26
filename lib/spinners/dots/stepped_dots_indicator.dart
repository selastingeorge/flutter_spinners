import 'package:flutter/material.dart';
import 'dart:math';

/// An animated loading indicator with three dots that reveal progressively via clipping.
///
/// Three horizontally aligned dots are revealed from left to right using a clipping
/// mask that expands in discrete steps. The animation uses a StepTween to create
/// a stepped reveal effect rather than smooth continuous movement.
///
/// Example:
/// ```dart
/// SteppedDotsLoader(
///   size: 80,
///   color: Colors.teal,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
class SteppedDotsLoader extends StatefulWidget {
  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete reveal cycle through all dots.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a stepped dots loader indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const SteppedDotsLoader({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<SteppedDotsLoader> createState() => _SteppedDotsLoaderState();
}

class _SteppedDotsLoaderState extends State<SteppedDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _steppedAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize repeating animation
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    // Create stepped animation that jumps between integer values 0-4
    _steppedAnimation = _controller.drive(StepTween(begin: 0, end: 4));
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
        animation: _steppedAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _SteppedDotsPainter(
              step: _steppedAnimation.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three dots with progressive clipping reveal.
///
/// [step] - Current step value (0-4) determining clip width
/// [color] - Color of the dots
class _SteppedDotsPainter extends CustomPainter {
  /// Current step in the animation (0-4).
  final int step;

  /// Color of the dots.
  final Color color;

  /// Shared paint object for performance (avoids recreating on each paint).
  static final Paint _paint = Paint();

  _SteppedDotsPainter({required this.step, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color;

    // Setup for three dots
    const dotCount = 3;
    final spacing = size.width / dotCount; // Space allocated per dot
    final radius =
        min(spacing, size.height) *
        0.35; // Dot radius (35% of smaller dimension)
    final dy = size.height * 0.5; // Vertical center

    // Convert step (0-4) to progress (0.0-1.0)
    final progress = step / 4.0;

    // Calculate clip width: expands from 0 to 134% of width
    // Extra 34% ensures last dot is fully revealed even with spacing
    final clipWidth = size.width * (1 + 0.34) * progress;

    // Apply clipping mask to reveal dots progressively
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, clipWidth, size.height));

    // Draw all three dots (clipping mask controls visibility)
    canvas.drawCircle(Offset(spacing * 0.5, dy), radius, _paint); // Left dot
    canvas.drawCircle(Offset(spacing * 1.5, dy), radius, _paint); // Middle dot
    canvas.drawCircle(Offset(spacing * 2.5, dy), radius, _paint); // Right dot

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SteppedDotsPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.color != color;
  }
}
