import 'package:flutter/material.dart';
import 'dart:math' as math;

/// An animated loading indicator with two rows of three bars that grow and shrink in sequence.
///
/// The top row bars grow upward while the bottom row bars grow downward,
/// with one column animating at a time in a sequential pattern from left to right.
///
/// Example:
/// ```dart
/// DoubleRowBarsIndicator(
///   size: 80,
///   color: Colors.green,
///   duration: Duration(milliseconds: 1500),
///   borderRadius: 3,
/// )
/// ```
class DoubleRowBarsIndicator extends StatefulWidget {

  /// The width of the indicator. Height is automatically set to 80% of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle through all columns.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The border radius for rounding the corners of each bar.
  ///
  /// Defaults to 0 (sharp corners).
  final double borderRadius;

  /// Creates a double row bars loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const DoubleRowBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<DoubleRowBarsIndicator> createState() =>
      _DoubleRowBarsIndicatorState();
}

class _DoubleRowBarsIndicatorState
    extends State<DoubleRowBarsIndicator> with SingleTickerProviderStateMixin {
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
      height: widget.size * 0.8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _DoubleRowBarsPainter(
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

/// Custom painter that draws two rows of bars with sequential column animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator
/// [borderRadius] - Border radius for bar corners
class _DoubleRowBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  /// Border radius for bar corners.
  final double borderRadius;

  _DoubleRowBarsPainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Bar dimensions: 10% width
    final barWidth = size * 0.10;
    final gap = barWidth;

    // Calculate horizontal positions to center the bars
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size - totalBarsWidth) / 2;
    final xPositions = [
      startX,
      startX + barWidth + gap,
      startX + 2 * (barWidth + gap),
    ];

    // Container and bar height calculations
    final containerHeight = size * 0.55;
    final barMaxHeight = containerHeight;
    final topRowY = (size * 0.8 - containerHeight) / 2;
    final bottomRowBase = topRowY + containerHeight;

    // Determine which column is currently active
    const nCols = 3;
    final segment = t * nCols;
    final activeColumn = segment.floor() % nCols;
    final localT = segment % 1.0;

    // Apply smooth easing using cosine interpolation
    final smoothT = 0.5 - 0.5 * math.cos(localT * math.pi);

    // Draw bars for each column (top and bottom)
    for (int i = 0; i < nCols; i++) {
      final x = xPositions[i];

      // Active column grows to full height, others stay at 20%
      final heightFactor = (i == activeColumn) ? smoothT : 0.2;
      final barHeight = barMaxHeight * heightFactor;

      // Top row bar (grows upward from base)
      final rectTop = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, topRowY, barWidth, barHeight),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rectTop, paint);

      // Bottom row bar (grows downward from base)
      final rectBottom = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bottomRowBase - barHeight, barWidth, barHeight),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rectBottom, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DoubleRowBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}