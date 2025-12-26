import 'package:flutter/material.dart';

/// An animated loading indicator with a line segment that travels around a square path.
///
/// A colored line segment (like a snake) travels continuously around the perimeter
/// of an invisible square in a clockwise direction. The line maintains a constant
/// length as it moves, with the head and tail progressing along the square's edges.
///
/// Example:
/// ```dart
/// SlidingSquareLineIndicator(
///   size: 50,
///   color: Colors.blue,
///   duration: Duration(seconds: 3),
///   strokeWidth: 5,
///   snakeLength: 0.3,
/// )
/// ```
class SlidingSquareLineIndicator extends StatefulWidget {
  /// The width and height of the square indicator.
  ///
  /// Defaults to 35.
  final double size;

  /// The color of the animated line segment.
  ///
  /// Defaults to Color(0xFF046D8B).
  final Color color;

  /// The duration of one complete cycle around the square.
  ///
  /// Defaults to 4 seconds.
  final Duration duration;

  /// The width of the line stroke.
  ///
  /// Defaults to 4.
  final double strokeWidth;

  /// The length of the line segment as a fraction of the total perimeter (0.0-1.0).
  ///
  /// For example, 0.25 means the line occupies 25% of the square's perimeter.
  /// Defaults to 0.25 (one quarter of the perimeter).
  final double snakeLength;

  /// Creates a sliding square line loading indicator.
  ///
  /// [size] - The width and height of the square (default: 35)
  /// [color] - The color of the line (default: Color(0xFF046D8B))
  /// [duration] - Animation cycle duration (default: 4 seconds)
  /// [strokeWidth] - Width of the line stroke (default: 4)
  /// [snakeLength] - Line length as fraction of perimeter (default: 0.25)
  const SlidingSquareLineIndicator({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF046D8B),
    this.duration = const Duration(seconds: 4),
    this.strokeWidth = 4,
    this.snakeLength = 0.25,
  });

  @override
  State<SlidingSquareLineIndicator> createState() =>
      _SlidingSquareLineIndicatorState();
}

class _SlidingSquareLineIndicatorState extends State<SlidingSquareLineIndicator>
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
            painter: _SlidingSquareLinePainter(
              progress: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              snakeLength: widget.snakeLength,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a line segment traveling around a square path.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the line segment
/// [strokeWidth] - Width of the line stroke
/// [snakeLength] - Length of the line as fraction of total perimeter
class _SlidingSquareLinePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Color of the line segment.
  final Color color;

  /// Width of the line stroke.
  final double strokeWidth;

  /// Length of the line segment as fraction of perimeter (0.0-1.0).
  final double snakeLength;

  _SlidingSquareLinePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.snakeLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final half = strokeWidth / 2; // Half stroke width for centering

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const totalSides = 4; // Square has 4 sides

    // Calculate head (front) and tail (back) positions of the line segment
    double headProgress = progress;
    double tailProgress = progress - snakeLength;

    /// Converts a progress value (0.0-1.0) to a point on the square perimeter.
    ///
    /// Progress maps clockwise around the square: 0.0 = top-left corner,
    /// 0.25 = top-right, 0.5 = bottom-right, 0.75 = bottom-left, 1.0 = back to top-left.
    ///
    /// [p] - Progress value (automatically wrapped to 0.0-1.0 range)
    Offset getPointAtProgress(double p) {
      p = p % 1.0;
      if (p < 0) p += 1.0;

      // Determine which side and position within that side
      double sideProgress =
          (p * totalSides) % 1.0; // Position within current side (0.0-1.0)
      int side = (p * totalSides).floor() % totalSides; // Which side (0-3)

      // Return point based on current side
      switch (side) {
        case 0: // Top side: left to right
          return Offset(half + (w - strokeWidth) * sideProgress, half);
        case 1: // Right side: top to bottom
          return Offset(w - half, half + (h - strokeWidth) * sideProgress);
        case 2: // Bottom side: right to left
          return Offset(w - half - (w - strokeWidth) * sideProgress, h - half);
        case 3: // Left side: bottom to top
        default:
          return Offset(half, h - half - (h - strokeWidth) * sideProgress);
      }
    }

    // Handle case where tail wraps around (negative tailProgress)
    if (tailProgress < 0) {
      double wrappedTail = tailProgress + 1.0;

      // Draw segment from wrapped tail to end of perimeter (1.0)
      for (double t = wrappedTail; t < 1.0;) {
        int currentSide = (t * totalSides).floor() % totalSides;
        double nextSideStart = (currentSide + 1) / totalSides.toDouble();
        double segmentEnd = nextSideStart > 1.0 ? 1.0 : nextSideStart;
        canvas.drawLine(
          getPointAtProgress(t),
          getPointAtProgress(segmentEnd),
          paint,
        );
        t = segmentEnd;
        if (t >= 1.0) break;
      }

      // Draw segment from start of perimeter (0.0) to head
      for (double t = 0.0; t < headProgress;) {
        int currentSide = (t * totalSides).floor() % totalSides;
        double nextSideStart = (currentSide + 1) / totalSides.toDouble();
        double segmentEnd = nextSideStart > headProgress
            ? headProgress
            : nextSideStart;
        canvas.drawLine(
          getPointAtProgress(t),
          getPointAtProgress(segmentEnd),
          paint,
        );
        t = segmentEnd;
        if (t >= headProgress) break;
      }
    }
    // Normal case: head and tail on same cycle
    else {
      int headSide = (headProgress * totalSides).floor() % totalSides;
      int tailSide = (tailProgress * totalSides).floor() % totalSides;

      // If head and tail are on the same side, draw single segment
      if (headSide == tailSide) {
        canvas.drawLine(
          getPointAtProgress(tailProgress),
          getPointAtProgress(headProgress),
          paint,
        );
      }
      // Otherwise, draw segments across multiple sides
      else {
        // Draw tail segment to end of its side
        double tailSideEnd = (tailSide + 1) / totalSides.toDouble();
        canvas.drawLine(
          getPointAtProgress(tailProgress),
          getPointAtProgress(tailSideEnd),
          paint,
        );

        // Draw complete intermediate sides
        for (int i = tailSide + 1; i < headSide; i++) {
          int side = i % totalSides;
          double sideStart = side / totalSides.toDouble();
          double sideEnd = (side + 1) / totalSides.toDouble();
          canvas.drawLine(
            getPointAtProgress(sideStart),
            getPointAtProgress(sideEnd),
            paint,
          );
        }

        // Draw head segment from start of its side
        double headSideStart = headSide / totalSides.toDouble();
        canvas.drawLine(
          getPointAtProgress(headSideStart),
          getPointAtProgress(headProgress),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SlidingSquareLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
