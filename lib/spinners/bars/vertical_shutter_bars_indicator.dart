import 'package:flutter/material.dart';

/// An animated loading indicator with vertical rows of bars that drop down and rise up like shutters.
///
/// Creates a grid of 4 rows with 3 bars each. Rows drop down from top to bottom sequentially,
/// landing in reverse order (first row to drop lands at bottom), hold position briefly,
/// then rise up and disappear in the same sequential pattern.
///
/// Example:
/// ```dart
/// VerticalShutterBarsIndicator(
///   size: 80,
///   color: Colors.red,
///   duration: Duration(milliseconds: 2000),
/// )
/// ```
class VerticalShutterBarsIndicator extends StatefulWidget {
  /// The width and height of the indicator (creates a square).
  ///
  /// Defaults to 60.
  final double size;

  /// The color of the animated bars.
  ///
  /// Defaults to [Colors.black].
  final Color color;

  /// The duration of one complete animation cycle (drop, hold, rise).
  ///
  /// Defaults to 1500 milliseconds.
  final Duration duration;

  /// Creates a vertical shutter bars loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 60)
  /// [color] - The color of the bars (default: Colors.black)
  /// [duration] - Animation cycle duration (default: 1500ms)
  const VerticalShutterBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<VerticalShutterBarsIndicator> createState() =>
      _VerticalShutterBarsIndicatorState();
}

class _VerticalShutterBarsIndicatorState
    extends State<VerticalShutterBarsIndicator>
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
            painter: _VerticalShutterBarsPainter(
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

/// Custom painter that draws a 4x3 grid of bars with sequential vertical drop and rise animation.
///
/// [t] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the bars
/// [size] - The size of the indicator (square)
class _VerticalShutterBarsPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double t;

  /// Color of the bars.
  final Color color;

  /// Size of the indicator.
  final double size;

  _VerticalShutterBarsPainter({
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

  /// Duration fraction for each row to drop/rise (as portion of total animation).
  static const double rowDrop = 0.12;

  /// Pause duration between row animations (as portion of total animation).
  static const double rowPause = 0.05;

  /// Hold duration when all rows are in position (as portion of total animation).
  static const double holdAll = 0.12;

  /// Clamps a value between 0 and 1.
  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  /// Calculates animation progress within a specific time range.
  ///
  /// [t] - Current time
  /// [start] - Start time of the range
  /// [len] - Length of the time range
  double _progress(double t, double start, double len) =>
      _clamp01((t - start) / len);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    // Calculate grid dimensions and center it
    final gridW = cols * cell + (cols - 1) * gap;
    final gridH = rows * rowHeight;

    final ox = (size - gridW) / 2;
    final oy = (size - gridH) / 2;

    // Calculate timing for entry (drop) and exit (rise) phases
    final step = rowDrop + rowPause;
    final entrySpan = rows * step;
    final exitSpan = rows * step;
    final totalSpan = entrySpan + holdAll + exitSpan;

    // Normalize time to cycle through animation
    final time = (t * totalSpan) % totalSpan;

    // Clip to grid bounds to hide bars dropping in/rising out
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(ox, oy, gridW, gridH));

    // Entry phase: rows drop down sequentially
    if (time < entrySpan) {
      for (int i = 0; i < rows; i++) {
        final start = i * step;
        if (time < start) break; // Row hasn't started dropping yet

        final k = _progress(time, start, rowDrop);
        final targetRow =
            rows - 1 - i; // Reverse order: first to drop lands at bottom

        // Start above grid, drop down to target position
        final y = oy - rowHeight + gridH * k * ((targetRow + 1) / rows);

        _drawRow(canvas, paint, ox, y);
      }
    }
    // Hold phase: all rows stay in position
    else if (time < entrySpan + holdAll) {
      for (int i = 0; i < rows; i++) {
        final targetRow = rows - 1 - i;
        final y = oy + targetRow * rowHeight;
        _drawRow(canvas, paint, ox, y);
      }
    }
    // Exit phase: rows rise up sequentially
    else {
      final exitTime = time - (entrySpan + holdAll);

      for (int i = 0; i < rows; i++) {
        final start = i * step;
        final targetRow = rows - 1 - i;
        final baseY = oy + targetRow * rowHeight;

        if (exitTime < start) {
          // Row hasn't started rising yet, stay in position
          _drawRow(canvas, paint, ox, baseY);
        } else {
          final k = _progress(exitTime, start, rowDrop);

          // Rise up from position and disappear above grid
          final y = baseY + gridH * k * ((targetRow + 1) / rows);

          if (k < 1) {
            _drawRow(canvas, paint, ox, y);
          }
          // Don't draw when k >= 1 (fully risen out of view)
        }
      }
    }

    canvas.restore();
  }

  /// Draws a single row of bars at the specified vertical position.
  ///
  /// [canvas] - The canvas to draw on
  /// [paint] - The paint to use
  /// [ox] - Horizontal offset (left edge of grid)
  /// [y] - Vertical position of the row
  void _drawRow(Canvas canvas, Paint paint, double ox, double y) {
    for (int col = 0; col < cols; col++) {
      final x = ox + col * (cell + gap);
      canvas.drawRect(Rect.fromLTWH(x, y, cell, rowHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalShutterBarsPainter old) =>
      old.t != t || old.color != color;
}
