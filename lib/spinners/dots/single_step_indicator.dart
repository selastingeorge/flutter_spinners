import 'package:flutter/material.dart';

/// An animated loading indicator with a single dot that jumps between positions.
///
/// A single dot moves horizontally across three discrete positions in a stepped
/// manner (no smooth interpolation). The dot instantly jumps to each position,
/// creating a staccato stepping effect rather than a smooth slide.
///
/// Example:
/// ```dart
/// SingleStepLoader(
///   size: 80,
///   color: Colors.red,
///   duration: Duration(milliseconds: 900),
/// )
/// ```
class SingleStepLoader extends StatefulWidget {
  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dot.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete cycle through all three positions.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a single step loader indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the dot (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const SingleStepLoader({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<SingleStepLoader> createState() => _SingleStepLoaderState();
}

class _SingleStepLoaderState extends State<SingleStepLoader>
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
            painter: _SingleStepPainter(
              progress: _steppedProgress(_controller.value),
              color: widget.color,
              width: widget.size,
            ),
          );
        },
      ),
    );
  }

  /// Converts smooth animation progress into discrete steps.
  ///
  /// Takes a continuous value (0.0-1.0) and returns a stepped value
  /// that jumps between 0.0, 0.333, and 0.667 for the three positions.
  ///
  /// [t] - Continuous animation progress (0.0-1.0)
  double _steppedProgress(double t) {
    const steps = 3; // Three discrete positions
    return (t * steps).floor() / steps;
  }
}

/// Custom painter that draws a single dot at a discrete horizontal position.
///
/// [progress] - Stepped progress value (0.0, 0.333, or 0.667)
/// [color] - Color of the dot
/// [width] - Width of the indicator area
class _SingleStepPainter extends CustomPainter {
  /// Stepped progress value representing discrete position.
  final double progress;

  /// Color of the dot.
  final Color color;

  /// Width of the indicator area.
  final double width;

  _SingleStepPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Number of discrete positions
    final positions = 3;
    final spacing = width / positions; // Space allocated per position
    final radius = size.height * 0.35; // Dot radius (35% of height)

    // Calculate horizontal position based on stepped progress
    // progress ranges from 0.0 to ~0.667, multiplied by positions gives 0, 1, or 2
    final dx = spacing / 2 + progress * spacing * positions;
    final dy = size.height / 2; // Vertical center

    canvas.drawCircle(Offset(dx, dy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _SingleStepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
