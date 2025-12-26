import 'package:flutter/material.dart';

/// An animated loading indicator with three dots that bounce in a wave pattern with pause.
///
/// Three horizontally aligned dots animate vertically through keyframes, creating a
/// wave effect where each dot bounces up and down in sequence. After completing one
/// cycle, the animation pauses before restarting, making it easier to track the pattern.
///
/// Example:
/// ```dart
/// WavyDotsIndicator(
///   size: 80,
///   color: Colors.indigo,
///   duration: Duration(milliseconds: 1500),
///   pauseDuration: Duration(milliseconds: 500),
/// )
/// ```
class WavyDotsIndicator extends StatefulWidget {
  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated dots.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete wave cycle through all keyframes.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The pause duration between animation cycles.
  ///
  /// After completing one cycle, the animation pauses for this duration
  /// before restarting. Defaults to 300 milliseconds.
  final Duration pauseDuration;

  /// Creates a wavy dots loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [pauseDuration] - Pause between cycles (default: 300ms)
  const WavyDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.pauseDuration = const Duration(milliseconds: 300),
  });

  @override
  State<WavyDotsIndicator> createState() => _WavyDotsIndicatorState();
}

class _WavyDotsIndicatorState extends State<WavyDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Add listener to pause between cycles
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Wait for pause duration before restarting
        await Future.delayed(widget.pauseDuration);
        if (!mounted) return; // Check if widget is still in tree
        _controller.reset();
        _controller.forward();
      }
    });

    // Start the animation
    _controller.forward();
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
            painter: _WavyDotsPainter(
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

/// Custom painter that draws three dots with keyframe-based vertical wave animation.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the dots
/// [width] - Width of the indicator area
class _WavyDotsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Color of the dots.
  final Color color;

  /// Width of the indicator area.
  final double width;

  _WavyDotsPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Setup for three dots
    final dotCount = 3;
    final spacing = width / 3; // Space allocated per dot
    final radius = size.height * 0.35; // Dot radius (35% of height)

    // Time keyframes (6 keyframes at 0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    final keyframes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

    // Vertical position keyframes for each dot (0.0 = top, 0.5 = center, 1.0 = bottom)
    // Each row represents one dot, each column represents a keyframe
    // Pattern creates sequential wave: dot1 bounces, then dot2, then dot3
    final List<List<double>> yKeyframes = [
      [0.5, 0.0, 1.0, 0.5, 0.5, 0.5], // Dot 1: center → top → bottom → center
      [0.5, 0.5, 0.0, 1.0, 0.5, 0.5], // Dot 2: starts later, same pattern
      [0.5, 0.5, 0.5, 0.0, 1.0, 0.5], // Dot 3: starts last, same pattern
    ];

    // Draw each dot with interpolated vertical position
    for (int i = 0; i < dotCount; i++) {
      // Find the current keyframe segment based on progress
      int k = 0;
      while (k < keyframes.length - 1 && progress > keyframes[k + 1]) {
        k++;
      }

      // Get keyframe boundaries and values
      final t0 = keyframes[k]; // Current keyframe time
      final t1 = keyframes[k + 1]; // Next keyframe time
      final y0 = yKeyframes[i][k]; // Current keyframe y position
      final y1 = yKeyframes[i][k + 1]; // Next keyframe y position

      // Calculate interpolation progress within this keyframe segment
      final localT = (progress - t0) / (t1 - t0);

      // Linearly interpolate vertical position between keyframes
      final y = y0 + (y1 - y0) * localT;

      // Calculate dot position
      final dx = spacing * i + spacing / 2;
      final dy = y * size.height;

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyDotsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
