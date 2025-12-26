import 'package:flutter/material.dart';

/// An animated loading indicator with three vertical bars that shrink, swap positions, and grow back.
///
/// The animation has three phases: bars shrink to half height, swap positions (rotating order),
/// then grow back to full height. The leftmost bar shrinks from top down while others shrink
/// from bottom up, creating a distinctive asymmetric effect.
///
/// Example:
/// ```dart
/// ShrinkSwapBarsIndicator(
///   size: 80,
///   color: Colors.deepPurple,
///   duration: Duration(milliseconds: 1200),
///   borderRadius: 4,
/// )
/// ```
class ShrinkSwapBarsIndicator extends StatefulWidget {

  /// The width of the indicator. Height is automatically set to 80% of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle (shrink, swap, grow).
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// The border radius for rounding the corners of each bar.
  ///
  /// Defaults to 0 (sharp corners).
  final double borderRadius;

  /// Creates a shrink-swap bars loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  /// [borderRadius] - Corner radius for bars (default: 0)
  const ShrinkSwapBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<ShrinkSwapBarsIndicator> createState() => _ShrinkSwapBarsIndicatorState();
}

class _ShrinkSwapBarsIndicatorState extends State<ShrinkSwapBarsIndicator>
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
            painter: _ShrinkSwapBarsPainter(
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

/// Custom painter that draws three bars with shrink, swap, and grow animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator
/// [borderRadius] - Border radius for bar corners
class _ShrinkSwapBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  /// Border radius for bar corners.
  final double borderRadius;

  _ShrinkSwapBarsPainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Translate canvas down to create vertical padding
    canvas.save();
    canvas.translate(0, size * 0.2);

    // Bar dimensions: 10% width, 55% max height
    final barWidth = size * 0.10;
    final gap = barWidth;
    final totalWidth = barWidth * 3 + gap * 2;
    final startX = (size - totalWidth) / 2;

    // Base positions: left, middle, right
    final baseX = [startX, startX + barWidth + gap, startX + 2 * (barWidth + gap)];

    // Rotated positions: right becomes left, left becomes middle, middle becomes right
    final rotatedX = [baseX[2], baseX[0], baseX[1]];

    final maxHeight = size * 0.55;
    final minHeight = maxHeight * 0.5;

    late List<double> heights;
    late List<double> xs;

    // Phase 1 (0 - 1/3): All bars shrink to half height
    if (t < 1 / 3) {
      final p = t * 3; // Normalize to 0-1 within this phase
      heights = [
        maxHeight - (maxHeight - minHeight) * p,
        maxHeight - (maxHeight - minHeight) * p,
        maxHeight - (maxHeight - minHeight) * p,
      ];

      xs = baseX;
    }
    // Phase 2 (1/3 - 2/3): Bars swap horizontal positions while staying at min height
    else if (t < 2 / 3) {
      final p = (t - 1 / 3) * 3; // Normalize to 0-1 within this phase
      heights = List.filled(3, minHeight);

      // Interpolate from base positions to rotated positions
      xs = List.generate(3, (i) => baseX[i] + (rotatedX[i] - baseX[i]) * p);
    }
    // Phase 3 (2/3 - 1): All bars grow back to full height
    else {
      final p = (t - 2 / 3) * 3; // Normalize to 0-1 within this phase
      heights = List.generate(3, (_) => minHeight + (maxHeight - minHeight) * p);
      xs = rotatedX;
    }

    // Draw three bars
    for (int i = 0; i < 3; i++) {
      // First bar (leftmost) shrinks from top, others shrink from bottom
      final isTopShrink = i == 0;

      final y = isTopShrink ? 0.0 : maxHeight - heights[i];

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xs[i], y, barWidth, heights[i]),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShrinkSwapBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}