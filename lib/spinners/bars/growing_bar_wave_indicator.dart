import 'package:flutter/material.dart';

/// An animated loading indicator with three vertical bars that grow and shrink in a wave pattern.
///
/// Bars expand and contract through keyframe animation, creating a wave effect
/// that travels from left to right. Each bar is vertically centered and grows
/// symmetrically from its center point.
///
/// Example:
/// ```dart
/// GrowingBarWaveIndicator(
///   size: 80,
///   color: Colors.teal,
///   duration: Duration(milliseconds: 1400),
///   borderRadius: 5,
/// )
/// ```
class GrowingBarWaveIndicator extends StatefulWidget {

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

  /// Creates a growing bar wave loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const GrowingBarWaveIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<GrowingBarWaveIndicator> createState() => _GrowingBarWaveIndicatorState();
}

class _GrowingBarWaveIndicatorState extends State<GrowingBarWaveIndicator>
    with SingleTickerProviderStateMixin {
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
            painter: _GrowingBarWavePainter(
              t: _controller.value,
              color: widget.color,
              size: widget.size,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three bars with keyframe-based growing wave animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator
/// [borderRadius] - Border radius for bar corners
class _GrowingBarWavePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  /// Border radius for bar corners.
  final double borderRadius;

  _GrowingBarWavePainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Bar dimensions: 10% width, 80% max height
    final barWidth = size * 0.10;
    final gap = barWidth;

    // Calculate horizontal positions to center the bars
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size - totalBarsWidth) / 2;
    final xPositions = [startX, startX + barWidth + gap, startX + 2 * (barWidth + gap)];
    final barHeightMax = size * 0.80;

    // Keyframes define the height factor (0.0-1.0) for each bar at each frame
    // Each row is a keyframe, each column is a bar (left, middle, right)
    // Wave pattern: each bar grows then shrinks in sequence
    final keyframes = [
      [0.5, 0.5, 0.5], // All bars at medium height
      [0.2, 0.5, 0.5], // Left bar shrinks
      [1.0, 0.2, 0.5], // Left grows to max, middle shrinks
      [0.5, 1.0, 0.2], // Middle grows to max, right shrinks
      [0.5, 0.5, 1.0], // Right grows to max
      [0.5, 0.5, 0.5], // All return to medium height
    ];

    const nFrames = 6;
    final frameTime = 1.0 / (nFrames - 1);

    // Draw three bars with interpolated heights based on keyframes
    for (int i = 0; i < 3; i++) {
      // Determine current and next keyframe
      int frame = (t / frameTime).floor();
      int next = (frame + 1) % nFrames;
      final localT = (t - frame * frameTime) / frameTime;

      // Interpolate height factor between current and next keyframe
      final factor = keyframes[frame][i] + (keyframes[next][i] - keyframes[frame][i]) * localT;

      final barHeight = barHeightMax * factor;

      // Center the bar vertically (grows from center, not from bottom)
      final y = (size * 0.8 - barHeight) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPositions[i], y, barWidth, barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowingBarWavePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}