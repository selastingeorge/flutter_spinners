import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with three dots that pulse in and out sequentially.
///
/// Three horizontally aligned dots scale up and down in a smooth wave pattern.
/// Each dot pulses with a phase offset, creating a rippling effect from left to right
/// using cosine-based scaling animation.
///
/// Example:
/// ```dart
/// PulseDotsIndicator(
///   size: 80,
///   color: Colors.green,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
class PulseDotsIndicator extends StatefulWidget {

  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete pulse cycle through all dots.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a pulse dots loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const PulseDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<PulseDotsIndicator> createState() => _PulseDotsIndicatorState();
}

class _PulseDotsIndicatorState extends State<PulseDotsIndicator>
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
            painter: _PulseDotsPainter(
              t: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three dots with sequential pulsing scale animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the dots
class _PulseDotsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the dots.
  final Color color;

  _PulseDotsPainter({
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Dot dimensions and positioning
    final radius = size.height * 0.35; // Base dot radius (35% of height)
    final cy = size.height / 2; // Vertical center
    final spacing = size.width / 3; // Space between dots

    // Draw three dots with phase-offset pulsing
    for (int i = 0; i < 3; i++) {
      // Each dot is phase-shifted by 1/3 of the cycle (120 degrees)
      final phase = (t - i / 3) * 2 * math.pi;

      // Calculate cosine wave value (-1 to 1)
      final wave = math.cos(phase);

      // Normalize to 0-1 range for scaling
      final normalized = (wave + 1) / 2;
      final scale = normalized; // Scale from 0 (shrunk) to 1 (full size)

      // Calculate horizontal center position for this dot
      final dx = spacing * i + spacing / 2;

      canvas.save();
      canvas.translate(dx, cy); // Move to dot center
      canvas.scale(scale, scale); // Apply uniform scaling
      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PulseDotsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}