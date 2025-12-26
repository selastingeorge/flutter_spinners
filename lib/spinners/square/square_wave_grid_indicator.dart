import 'package:flutter/material.dart';

/// An animated loading indicator with a 3x3 grid of squares that scale in a wave pattern.
///
/// Nine squares arranged in a grid animate independently with staggered timing.
/// Each square scales down and back up in a smooth wave motion, with delays creating
/// a diagonal wave pattern from bottom-left to top-right across the grid.
///
/// Example:
/// ```dart
/// SquareWaveGridIndicator(
///   size: 50.0,
///   color: Colors.blue,
///   duration: Duration(milliseconds: 1500),
/// )
/// ```
class SquareWaveGridIndicator extends StatefulWidget {

  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 40.0.
  final double size;

  /// The color of the squares.
  ///
  /// Defaults to Color(0xFFFFFFFF) (white).
  final Color color;

  /// The duration of one complete animation cycle through all squares.
  ///
  /// Defaults to 1300 milliseconds.
  final Duration duration;

  /// Creates a square wave grid loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 40.0)
  /// [color] - The color of the squares (default: Color(0xFFFFFFFF))
  /// [duration] - Animation cycle duration (default: 1300ms)
  const SquareWaveGridIndicator({
    super.key,
    this.size = 40.0,
    this.color = const Color(0xFFFFFFFF),
    this.duration = const Duration(milliseconds: 1300),
  });

  @override
  State<SquareWaveGridIndicator> createState() => _SquareWaveGridIndicatorState();
}

class _SquareWaveGridIndicatorState extends State<SquareWaveGridIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Animation delay values for each square in the 3x3 grid (0.0-1.0).
  ///
  /// Pattern creates a diagonal wave from bottom-left to top-right:
  /// [0.2, 0.3, 0.4]  // Row 0 (top)
  /// [0.1, 0.2, 0.3]  // Row 1 (middle)
  /// [0.0, 0.1, 0.2]  // Row 2 (bottom)
  final List<double> _delays = [0.2, 0.3, 0.4, 0.1, 0.2, 0.3, 0.0, 0.1, 0.2];

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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SquareWaveGridPainter(
              progress: _controller.value,
              size: widget.size,
              color: widget.color,
              delays: _delays,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a 3x3 grid of squares with staggered scale animation.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [size] - The size of the indicator (square)
/// [color] - Color of the squares
/// [delays] - List of 9 delay values for each square
class _SquareWaveGridPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Size of the indicator.
  final double size;

  /// Color of the squares.
  final Color color;

  /// Delay values for each of the 9 squares (0.0-1.0).
  final List<double> delays;

  _SquareWaveGridPainter({
    required this.progress,
    required this.size,
    required this.color,
    required this.delays,
  });

  /// Grid size as fraction of total size (90%).
  static const double gridFraction = 0.9;

  /// Calculates scale factor for a given animation progress.
  ///
  /// Timeline for one square:
  /// - 0.00-0.15: Full size (scale = 1.0)
  /// - 0.15-0.35: Scale down to 0.0 (shrink phase)
  /// - 0.35-0.55: Scale up to 1.0 (grow phase)
  /// - 0.55-1.00: Full size (scale = 1.0)
  ///
  /// [t] - Progress value for this square (0.0-1.0)
  double _scaleForProgress(double t) {
    t = t % 1.0;

    if (t < 0.15) return 1.0; // Initial pause at full size

    if (t < 0.35) {
      // Shrink phase: scale from 1.0 to 0.0
      return 1 - Curves.easeInOut.transform((t - 0.15) / 0.20);
    }

    if (t < 0.55) {
      // Grow phase: scale from 0.0 to 1.0
      return Curves.easeInOut.transform((t - 0.35) / 0.20);
    }

    return 1.0; // Final pause at full size
  }

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Calculate grid dimensions
    final gridSize = size * gridFraction;
    final cubeSize = gridSize / 3; // Each square is 1/3 of grid

    // Center the grid within the indicator
    final ox = (size - gridSize) / 2;
    final oy = (size - gridSize) / 2;

    // Draw 3x3 grid of squares
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        // Calculate index in delays array (row-major order: 0-8)
        final index = row * 3 + col;

        // Calculate progress for this square with delay offset
        double t = (progress - delays[index]) % 1.0;
        if (t < 0) t += 1.0; // Wrap negative values

        // Get scale factor for current progress
        final scale = _scaleForProgress(t);

        // Calculate inset to keep square centered while scaling
        final inset = cubeSize * (1 - scale) / 2;

        // Draw scaled square
        canvas.drawRect(
          Rect.fromLTWH(
            ox + col * cubeSize + inset,
            oy + row * cubeSize + inset,
            cubeSize * scale,
            cubeSize * scale,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SquareWaveGridPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}