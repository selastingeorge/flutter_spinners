import 'package:flutter/material.dart';

/// An animated loading indicator with three dots that chase each other around a square path.
///
/// Three dots continuously move around the corners of an invisible square in a clockwise
/// direction. Each dot is offset from the others, creating a chasing effect as they
/// travel around the four corners with smooth easing.
///
/// Example:
/// ```dart
/// CornerDotsIndicator(
///   size: 80,
///   color: Colors.blue,
///   duration: Duration(milliseconds: 1500),
/// )
/// ```
class CornerDotsIndicator extends StatefulWidget {

  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete cycle around all four corners.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a corner dots loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const CornerDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<CornerDotsIndicator> createState() => _CornerDotsIndicatorState();
}

class _CornerDotsIndicatorState extends State<CornerDotsIndicator>
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _CornerDotsPainter(
              t: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three dots moving around a square path through four corners.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the dots
class _CornerDotsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the dots.
  final Color color;

  _CornerDotsPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Calculate square path dimensions
    final spacing = size.width / 3;
    final radius = spacing * 0.26; // Dot radius (26% of spacing)

    // Center the square path
    final offsetX = (size.width - spacing) / 2;
    final offsetY = (size.height - spacing) / 2;

    // Define the four corner positions (clockwise: top-left, top-right, bottom-right, bottom-left)
    final positions = [
      Offset(0, 0),           // Top-left
      Offset(spacing, 0),     // Top-right
      Offset(spacing, spacing), // Bottom-right
      Offset(0, spacing),     // Bottom-left
    ];

    final curve = Curves.easeInOut;

    // Draw three dots with phase offsets
    for (int i = 0; i < 3; i++) {
      // Each dot is offset by 1/4 of the cycle (25%)
      double progress = (t + i / 4) % 1;

      // Determine which corner segment the dot is currently traveling between
      int startIndex = (progress * 4).floor() % 4;
      int endIndex = (startIndex + 1) % 4;

      // Calculate position within the current segment (0-1)
      double localT = (progress * 4) - (progress * 4).floor();
      localT = curve.transform(localT); // Apply easing

      // Interpolate position between start and end corners
      final start = positions[startIndex];
      final end = positions[endIndex];

      final dx = start.dx + (end.dx - start.dx) * localT + offsetX;
      final dy = start.dy + (end.dy - start.dy) * localT + offsetY;

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerDotsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}