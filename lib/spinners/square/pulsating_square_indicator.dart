import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with a square that pulsates with elastic bounce effect.
///
/// A filled square scales down smoothly, then springs back to full size with an
/// elastic bounce effect. The animation uses a custom elastic easing function
/// for the expansion phase, creating an energetic, bouncy appearance.
///
/// Example:
/// ```dart
/// PulsatingSquareIndicator(
///   size: 80,
///   color: Colors.green,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
class PulsatingSquareIndicator extends StatefulWidget {
  /// The width and height of the indicator container (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the square.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete pulsation cycle (shrink and expand).
  ///
  /// Defaults to 1000 milliseconds.
  final Duration duration;

  /// Creates a pulsating square loading indicator.
  ///
  /// [size] - The width and height of the container (default: 60)
  /// [color] - The color of the square (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1000ms)
  const PulsatingSquareIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsatingSquareIndicator> createState() =>
      _PulsatingSquareIndicatorState();
}

class _PulsatingSquareIndicatorState extends State<PulsatingSquareIndicator>
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
            painter: _ElasticSquarePainter(
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

/// Custom painter that draws a square with elastic pulsating scale animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the square
/// [size] - Size of the indicator container
class _ElasticSquarePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the square.
  final Color color;

  /// Size of the indicator container.
  final double size;

  _ElasticSquarePainter({
    required this.t,
    required this.color,
    required this.size,
  });

  /// Applies elastic-out easing function for bouncy expansion effect.
  ///
  /// Creates an exponentially decaying oscillation that overshoots and
  /// settles at the target value, mimicking elastic behavior.
  ///
  /// [x] - Input value from 0.0 to 1.0
  double _elasticOut(double x) {
    if (x == 0 || x == 1) return x;

    // Constant for oscillation frequency (2π/3 radians)
    const c4 = (2 * math.pi) / 3;

    // Exponentially decaying sine wave
    // pow(2, -10x) creates decay, sin creates oscillation
    return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1;
  }

  @override
  void paint(Canvas canvas, Size _) {
    // Fixed square size (36x36 pixels)
    const squareSize = 36.0;

    final cx = size / 2; // Center X
    final cy = size / 2; // Center Y

    double scale;

    // Animation timeline:
    // 0.0-0.4 (40%): Linear shrink from 1.0 to 0.65
    if (t < 0.4) {
      scale = 1.0 - 0.35 * (t / 0.4);
    }
    // 0.4-1.0 (60%): Elastic expansion from 0.65 to 1.0
    else {
      final k = (t - 0.4) / 0.6; // Normalize to 0-1 for elastic function
      scale = 0.65 + (1.0 - 0.65) * _elasticOut(k);
    }

    final paint = Paint()..color = color;

    canvas.save();
    canvas.translate(cx, cy); // Move to center
    canvas.scale(scale); // Apply uniform scaling

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
  bool shouldRepaint(covariant _ElasticSquarePainter old) =>
      old.t != t || old.color != color;
}
