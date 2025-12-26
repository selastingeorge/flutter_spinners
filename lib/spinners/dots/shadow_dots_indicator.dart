import 'package:flutter/material.dart';

/// An animated loading indicator with three dots that fade in and out sequentially.
///
/// Three horizontally aligned dots display a traveling highlight effect by modulating
/// their opacity. The highlight moves from left to right continuously, with dots at
/// different distances from the highlight showing different opacity levels (full, medium, low).
///
/// Example:
/// ```dart
/// ShadowDotsIndicator(
///   size: 80,
///   color: Colors.blue,
///   duration: Duration(milliseconds: 1200),
/// )
/// ```
class ShadowDotsIndicator extends StatefulWidget {

  /// The width of the indicator. Height is automatically set to 1/4 of this value.
  ///
  /// Defaults to 60.
  final double size;

  /// The base color of the animated dots (alpha is modulated for fade effect).
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete highlight cycle through all dots.
  ///
  /// Defaults to 1 second.
  final Duration duration;

  /// Creates a shadow dots loading indicator.
  ///
  /// [size] - The width of the indicator (default: 60)
  /// [color] - The base color of the dots (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1 second)
  const ShadowDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<ShadowDotsIndicator> createState() => _ShadowDotsIndicatorState();
}

class _ShadowDotsIndicatorState extends State<ShadowDotsIndicator>
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
    final height = widget.size / 4;

    return SizedBox(
      width: widget.size,
      height: height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _ShadowDotsPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws three dots with sequential fade/highlight animation.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [color] - Base color of the dots (alpha is modulated)
class _ShadowDotsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Base color of the dots.
  final Color color;

  _ShadowDotsPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Dot dimensions and positioning
    final radius = size.height * 0.35; // Dot radius (35% of height)
    final cy = size.height / 2; // Vertical center
    final spacing = size.width / 3; // Space between dots

    // Scale progress to 0-3 range (covering all three dots)
    final phase = progress * 3;

    // Alpha levels for different distances from highlight
    const int full = 0xFF; // Full opacity (255) - at highlight
    const int mid  = 0x66; // Medium opacity (102) - near highlight
    const int low  = 0x22; // Low opacity (34) - far from highlight

    /// Calculates alpha value based on distance from highlight position.
    ///
    /// [index] - Dot index (0, 1, or 2)
    int alphaForDot(int index) {
      // Calculate distance between highlight phase and dot index
      final d = (phase - index).abs();

      // Closest to highlight: full opacity
      if (d < 0.5) return full;

      // Near highlight: medium opacity
      if (d < 1.5) return mid;

      // Far from highlight: low opacity
      return low;
    }

    // Draw three dots with distance-based opacity
    for (int i = 0; i < 3; i++) {
      paint.color = color.withAlpha(alphaForDot(i));

      final dx = spacing * i + spacing / 2;
      canvas.drawCircle(
        Offset(dx, cy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShadowDotsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}