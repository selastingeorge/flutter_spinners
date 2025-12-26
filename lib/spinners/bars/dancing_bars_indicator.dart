import 'package:flutter/material.dart';

/// An animated loading indicator with three vertical bars that dance with different heights.
///
/// The bars animate through predefined keyframes to create a choreographed
/// dancing effect where each bar changes height independently.
///
/// Example:
/// ```dart
/// DancingBarsIndicator(
///   size: 80,
///   color: Colors.purple,
///   duration: Duration(milliseconds: 1200),
///   borderRadius: 4,
/// )
/// ```
class DancingBarsIndicator extends StatefulWidget {

  /// The width of the indicator. Height is automatically set to 80% of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle through all keyframes.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The border radius for rounding the corners of each bar.
  ///
  /// Defaults to 0 (sharp corners).
  final double borderRadius;

  /// Creates a dancing bars loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const DancingBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<DancingBarsIndicator> createState() => _DancingBarsIndicatorState();
}

class _DancingBarsIndicatorState extends State<DancingBarsIndicator> with SingleTickerProviderStateMixin {
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
            painter: _DancingBarsPainter(
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

/// Custom painter that draws three animated bars with keyframe-based dancing motion.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [borderRadius] - Border radius for bar corners
class _DancingBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Border radius for bar corners.
  final double borderRadius;

  _DancingBarsPainter({required this.t, required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Bar dimensions: 10% width, 65% max height
    final barWidth = size.width * 0.10;
    final barHeightMax = size.height * 0.65;
    final gap = barWidth;

    // Calculate horizontal positions to center the bars
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size.width - totalBarsWidth) / 2;
    final xPositions = [startX, startX + barWidth + gap, startX + (barWidth + gap) * 2];

    // Keyframes define the height factor (0.0-1.0) for each bar at each frame
    // Each row is a keyframe, each column is a bar (left, middle, right)
    final keyframes = [
      [1.0, 1.0, 1.0], // All bars at full height
      [0.6, 1.0, 1.0], // Left bar shrinks
      [0.8, 0.6, 1.0], // Left grows, middle shrinks
      [1.0, 0.8, 0.6], // Middle grows, right shrinks
      [1.0, 1.0, 0.8], // Right grows
      [1.0, 1.0, 1.0], // All bars return to full height
    ];

    const nFrames = 6;
    final frameTime = 1.0 / (nFrames - 1);

    // Draw three bars with interpolated heights based on keyframes
    for (int i = 0; i < 3; i++) {
      // Determine current and next keyframe
      int frame = (t / frameTime).floor();
      int nextFrame = (frame + 1) % nFrames;
      double localT = (t - frame * frameTime) / frameTime;

      // Interpolate height between current and next keyframe
      final heightFactor = keyframes[frame][i] + (keyframes[nextFrame][i] - keyframes[frame][i]) * localT;

      // Calculate vertical position and height
      final dy = size.height - barHeightMax * heightFactor;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPositions[i], dy, barWidth, barHeightMax * heightFactor),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DancingBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}