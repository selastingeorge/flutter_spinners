import 'dart:math' as math;
import 'package:flutter/material.dart';

/// An animated loading indicator with three vertical bars moving in a wave pattern.
///
/// The bars animate up and down continuously with phase offsets to create
/// a smooth wave effect.
///
/// Example:
/// ```dart
/// BarWaveIndicator(
///   size: 80,
///   color: Colors.blue,
///   duration: Duration(milliseconds: 800),
///   borderRadius: 4,
/// )
/// ```
class BarWaveIndicator extends StatefulWidget {
  /// The width of the indicator. Height is automatically set to 80% of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The border radius for rounding the corners of each bar.
  ///
  /// Defaults to 0 (sharp corners).
  final double borderRadius;

  /// Creates a bar wave loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const BarWaveIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<BarWaveIndicator> createState() => _BarWaveIndicatorState();
}

class _BarWaveIndicatorState extends State<BarWaveIndicator> with SingleTickerProviderStateMixin {
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
            painter: _BarWavePainter(
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

/// Custom painter that draws three animated bars with wave motion.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [borderRadius] - Border radius for bar corners
class _BarWavePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Border radius for bar corners.
  final double borderRadius;

  _BarWavePainter({required this.t, required this.color, required this.borderRadius});

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
    final xPositions = [startX, startX + barWidth + gap, startX + (barWidth + gap) * 2];

    // Draw three bars with phase-offset animations
    for (int i = 0; i < 3; i++) {
      // Phase offset creates wave effect (0.2 = 20% offset between bars)
      final phase = (t + i * 0.2) % 1.0;

      // Calculate vertical position using sine wave
      final yFactor = (1 - (0.5 + 0.5 * math.sin(2 * math.pi * phase)));
      final dy = (size.height - barHeight) * yFactor;

      // Create rounded rectangle for bar
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPositions[i], dy, barWidth, barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarWavePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
