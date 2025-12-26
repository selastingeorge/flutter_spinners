import 'package:flutter/material.dart';

/// An animated loading indicator with a 3x3 grid of bars that sink in and out sequentially.
///
/// Rows of bars grow upward from the bottom in sequence (like filling up), hold position briefly,
/// then shrink back down in the same sequential pattern (like draining). Creates a
/// "sinking" or "filling" visual effect.
///
/// Example:
/// ```dart
/// SinkingBarsIndicator(
///   size: 80,
///   color: Colors.cyan,
///   duration: Duration(milliseconds: 2000),
/// )
/// ```
class SinkingBarsIndicator extends StatefulWidget {
  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle (fill, hold, drain).
  ///
  /// Defaults to 1500 milliseconds.
  final Duration duration;

  /// Creates a sinking bars loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1500ms)
  const SinkingBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SinkingBarsIndicator> createState() => _SinkingBarsIndicatorState();
}

class _SinkingBarsIndicatorState extends State<SinkingBarsIndicator>
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
            painter: _SinkingBarsPainter(
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

/// Custom painter that draws a 3x3 grid of bars with sequential vertical fill/drain animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator (square)
class _SinkingBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  _SinkingBarsPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  /// Width of each individual bar cell.
  static const double cell = 6.0;

  /// Horizontal gap between bars in a row.
  static const double gap = 6.0;

  /// Height of each row when fully filled.
  static const double rowHeight = 10.0;

  /// Number of columns (bars per row).
  static const int cols = 3;

  /// Number of rows.
  static const int rows = 3;

  /// Duration fraction for each row to fill/drain (as portion of total animation).
  static const double rowFill = 0.08;

  /// Pause duration between row animations (as portion of total animation).
  static const double rowPause = 0.04;

  /// Hold duration when all rows are fully filled (as portion of total animation).
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

    // Clip to grid bounds
    canvas.save();
    canvas.clipRect(gridRect);

    // Calculate timing for entry (fill) and exit (drain) phases
    final entrySpan = rows * (rowFill + rowPause);
    final exitStart = entrySpan + holdAll;

    // Draw each row with sequential fill/drain animation
    for (int row = 0; row < rows; row++) {
      final entryStart = row * (rowFill + rowPause);
      final exitStartRow = exitStart + row * (rowFill + rowPause);

      double h;

      // Entry phase: bars grow upward from bottom
      if (t < entrySpan) {
        final k = _progress(t, entryStart, rowFill);
        h = rowHeight * k; // Height grows from 0 to rowHeight
      }
      // Exit phase: bars shrink downward to bottom
      else if (t >= exitStart) {
        final k = _progress(t, exitStartRow, rowFill);
        h = rowHeight * (1 - k); // Height shrinks from rowHeight to 0
      }
      // Hold phase: bars stay at full height
      else {
        h = rowHeight;
      }

      // Skip drawing if height is zero or negative
      if (h <= 0) continue;

      // Position bars from bottom up (yBottom - h)
      final yBottom = oy + (row + 1) * rowHeight;

      // Draw all bars in this row
      for (int col = 0; col < cols; col++) {
        final x = ox + col * (cell + gap);

        canvas.drawRect(Rect.fromLTWH(x, yBottom - h, cell, h), paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SinkingBarsPainter old) =>
      old.t != t || old.color != color;
}
