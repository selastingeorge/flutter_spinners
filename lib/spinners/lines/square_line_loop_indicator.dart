import 'package:flutter/material.dart';

/// An animated loading indicator that draws and erases a square outline in a loop.
///
/// A square outline is drawn clockwise side-by-side (top → right → bottom → left),
/// then erased in the same order. The animation uses 8 discrete steps: 4 for drawing
/// and 4 for erasing, creating a continuous looping effect.
///
/// Example:
/// ```dart
/// SquareLineLoopIndicator(
///   size: 50,
///   color: Colors.purple,
///   duration: Duration(seconds: 3),
///   strokeWidth: 5,
/// )
/// ```
class SquareLineLoopIndicator extends StatefulWidget {

  /// The width and height of the square indicator.
  ///
  /// Defaults to 35.
  final double size;

  /// The color of the square outline.
  ///
  /// Defaults to Color(0xFF046D8B).
  final Color color;

  /// The duration of one complete cycle (drawing and erasing the square).
  ///
  /// Defaults to 4 seconds.
  final Duration duration;

  /// The width of the line stroke.
  ///
  /// Defaults to 4.
  final double strokeWidth;

  /// Creates a square line loop loading indicator.
  ///
  /// [size] - The width and height of the square (default: 35)
  /// [color] - The color of the outline (default: Color(0xFF046D8B))
  /// [duration] - Animation cycle duration (default: 4 seconds)
  /// [strokeWidth] - Width of the line stroke (default: 4)
  const SquareLineLoopIndicator({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF046D8B),
    this.duration = const Duration(seconds: 4),
    this.strokeWidth = 4,
  });

  @override
  State<SquareLineLoopIndicator> createState() =>
      _SquareLineLoopIndicatorState();
}

class _SquareLineLoopIndicatorState
    extends State<SquareLineLoopIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize repeating animation (no reverse, creates continuous loop)
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SquareLineLoopPainter(
              progress: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a square outline with draw/erase loop animation.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the square outline
/// [strokeWidth] - Width of the line stroke
class _SquareLineLoopPainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Color of the square outline.
  final Color color;

  /// Width of the line stroke.
  final double strokeWidth;

  _SquareLineLoopPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    final half = strokeWidth / 2; // Half stroke width for centering

    // Animation divided into 8 discrete steps
    // Steps 0-3: Draw each side (top, right, bottom, left)
    // Steps 4-7: Erase each side (top, right, bottom, left)
    const int steps = 8;
    double stepDuration = 1 / steps; // Duration of each step (0.125)

    // Determine current step (0-7) and progress within that step (0.0-1.0)
    int currentStep = (progress / stepDuration).floor() % steps;
    double localProgress = (progress - currentStep * stepDuration) / stepDuration;

    // Start and end points for each side (0.0-1.0 along side length)
    double topStart = 0, topEnd = 0;
    double rightStart = 0, rightEnd = 0;
    double bottomStart = 0, bottomEnd = 0;
    double leftStart = 0, leftEnd = 0;

    // Steps 0-3: Drawing phase
    if (currentStep < 4) {
      switch (currentStep) {
        case 0: // Draw top side
          topEnd = localProgress;
          break;
        case 1: // Top complete, draw right side
          topEnd = 1;
          rightEnd = localProgress;
          break;
        case 2: // Top and right complete, draw bottom side
          topEnd = rightEnd = 1;
          bottomEnd = localProgress;
          break;
        case 3: // Top, right, and bottom complete, draw left side
          topEnd = rightEnd = bottomEnd = 1;
          leftEnd = localProgress;
          break;
      }
    }
    // Steps 4-7: Erasing phase
    else {
      switch (currentStep) {
        case 4: // Erase top side (start advances)
          topStart = localProgress;
          topEnd = 1;
          rightEnd = 1;
          bottomEnd = 1;
          leftEnd = 1;
          break;
        case 5: // Top erased, erase right side
          topStart = 1; // Fully erased (start == end)
          rightStart = localProgress;
          rightEnd = 1;
          bottomEnd = 1;
          leftEnd = 1;
          break;
        case 6: // Top and right erased, erase bottom side
          topStart = 1;
          rightStart = 1;
          bottomStart = localProgress;
          bottomEnd = 1;
          leftEnd = 1;
          break;
        case 7: // Top, right, and bottom erased, erase left side
          topStart = 1;
          rightStart = 1;
          bottomStart = 1;
          leftStart = localProgress;
          leftEnd = 1;
          break;
      }
    }

    // Draw top side (left to right) if visible
    if (topEnd - topStart > 0) {
      canvas.drawLine(
        Offset(half + (w - strokeWidth) * topStart, half),
        Offset(half + (w - strokeWidth) * topEnd, half),
        paint,
      );
    }

    // Draw right side (top to bottom) if visible
    if (rightEnd - rightStart > 0) {
      canvas.drawLine(
        Offset(w - half, half + (h - strokeWidth) * rightStart),
        Offset(w - half, half + (h - strokeWidth) * rightEnd),
        paint,
      );
    }

    // Draw bottom side (right to left) if visible
    if (bottomEnd - bottomStart > 0) {
      canvas.drawLine(
        Offset(w - half - (w - strokeWidth) * bottomStart, h - half),
        Offset(w - half - (w - strokeWidth) * bottomEnd, h - half),
        paint,
      );
    }

    // Draw left side (bottom to top) if visible
    if (leftEnd - leftStart > 0) {
      canvas.drawLine(
        Offset(half, h - half - (h - strokeWidth) * leftStart),
        Offset(half, h - half - (h - strokeWidth) * leftEnd),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SquareLineLoopPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}