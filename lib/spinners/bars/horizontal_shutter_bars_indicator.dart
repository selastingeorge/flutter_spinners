import 'package:flutter/material.dart';

/// An animated loading indicator with horizontal rows of bars that slide in and out like shutters.
///
/// Creates a grid of 4 rows with 3 bars each. Rows slide in from left to right sequentially,
/// hold position briefly, then slide out to the right in the same sequential pattern.
///
/// Example:
/// ```dart
/// HorizontalShutterBarsIndicator(
///   size: 80,
///   color: Colors.indigo,
///   duration: Duration(milliseconds: 2000),
/// )
/// ```
class HorizontalShutterBarsIndicator extends StatefulWidget {

  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle (slide in, hold, slide out).
  ///
  /// Defaults to 1500 milliseconds.
  final Duration duration;

  /// Creates a horizontal shutter bars loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1500ms)
  const HorizontalShutterBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<HorizontalShutterBarsIndicator> createState() =>
      _HorizontalShutterBarsIndicatorState();
}

class _HorizontalShutterBarsIndicatorState extends State<HorizontalShutterBarsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize and start the repeating animation
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
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
            painter: _HorizontalShutterGridBarsPainter(
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

/// Custom painter that draws a 4x3 grid of bars with sequential horizontal sliding animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator (square)
class _HorizontalShutterGridBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  _HorizontalShutterGridBarsPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  /// Width of each individual bar cell.
  static const double cell = 6.0;

  /// Horizontal gap between bars in a row.
  static const double gap = 6.0;

  /// Height of each row.
  static const double rowHeight = 7.0;

  /// Number of columns (bars per row).
  static const int cols = 3;

  /// Number of rows.
  static const int rows = 4;

  /// Duration fraction for each row to slide in/out (as portion of total animation).
  static const double rowSlide = 0.08;

  /// Pause duration between row animations (as portion of total animation).
  static const double rowPause = 0.04;

  /// Hold duration when all rows are visible (as portion of total animation).
  static const double holdAll = 0.12;

  /// Clamps a value between 0 and 1.
  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  /// Calculates animation progress within a specific time range.
  ///
  /// [t] - Current time
  /// [start] - Start time of the range
  /// [length] - Length of the time range
  double _progress(double t, double start, double length) =>
      _clamp01((t - start) / length);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Calculate grid dimensions and center it
    final gridW = cols * cell + (cols - 1) * gap;
    final gridH = rows * rowHeight;
    final ox = (size - gridW) / 2;
    final oy = (size - gridH) / 2;
    final gridRect = Rect.fromLTWH(ox, oy, gridW, gridH);

    // Clip to grid bounds to hide bars sliding in/out
    canvas.save();
    canvas.clipRect(gridRect);

    // Calculate timing for entry and exit phases
    final entrySpan = rows * (rowSlide + rowPause);
    final exitStart = entrySpan + holdAll;

    // Draw each row with sequential slide animation
    for (int row = 0; row < rows; row++) {
      final entryStart = row * (rowSlide + rowPause);
      final exitStartRow = exitStart + row * (rowSlide + rowPause);

      double dx;

      // Entry phase: slide in from left
      if (t < entrySpan) {
        final k = _progress(t, entryStart, rowSlide);
        dx = -gridW + gridW * k; // Start offscreen left, move to position
      }
      // Exit phase: slide out to right
      else if (t >= exitStart) {
        final k = _progress(t, exitStartRow, rowSlide);
        dx = gridW * k; // Start at position, move offscreen right
      }
      // Hold phase: stay in position
      else {
        dx = 0;
      }

      final y = oy + row * rowHeight;

      // Draw all bars in this row
      for (int col = 0; col < cols; col++) {
        final x = ox + col * (cell + gap) + dx;

        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, rowHeight),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HorizontalShutterGridBarsPainter old) =>
      old.t != t || old.color != color;
}