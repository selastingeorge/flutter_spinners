import 'package:flutter/material.dart';

class SquareLineLoopIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double strokeWidth;

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

class _SquareLineLoopPainter extends CustomPainter {
  final double progress;
  final Color color;
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
    final half = strokeWidth / 2;

    const int steps = 8;
    double stepDuration = 1 / steps;
    int currentStep = (progress / stepDuration).floor() % steps;
    double localProgress = (progress - currentStep * stepDuration) / stepDuration;

    double topStart = 0, topEnd = 0;
    double rightStart = 0, rightEnd = 0;
    double bottomStart = 0, bottomEnd = 0;
    double leftStart = 0, leftEnd = 0;

    if (currentStep < 4) {
      switch (currentStep) {
        case 0:
          topEnd = localProgress;
          break;
        case 1:
          topEnd = 1;
          rightEnd = localProgress;
          break;
        case 2:
          topEnd = rightEnd = 1;
          bottomEnd = localProgress;
          break;
        case 3:
          topEnd = rightEnd = bottomEnd = 1;
          leftEnd = localProgress;
          break;
      }
    } else {
      switch (currentStep) {
        case 4:
          topStart = localProgress;
          topEnd = 1;
          rightEnd = 1;
          bottomEnd = 1;
          leftEnd = 1;
          break;
        case 5:
          topStart = 1;
          rightStart = localProgress;
          rightEnd = 1;
          bottomEnd = 1;
          leftEnd = 1;
          break;
        case 6:
          topStart = 1;
          rightStart = 1;
          bottomStart = localProgress;
          bottomEnd = 1;
          leftEnd = 1;
          break;
        case 7:
          topStart = 1;
          rightStart = 1;
          bottomStart = 1;
          leftStart = localProgress;
          leftEnd = 1;
          break;
      }
    }

    if (topEnd - topStart > 0) {
      canvas.drawLine(
        Offset(half + (w - strokeWidth) * topStart, half),
        Offset(half + (w - strokeWidth) * topEnd, half),
        paint,
      );
    }

    if (rightEnd - rightStart > 0) {
      canvas.drawLine(
        Offset(w - half, half + (h - strokeWidth) * rightStart),
        Offset(w - half, half + (h - strokeWidth) * rightEnd),
        paint,
      );
    }

    if (bottomEnd - bottomStart > 0) {
      canvas.drawLine(
        Offset(w - half - (w - strokeWidth) * bottomStart, h - half),
        Offset(w - half - (w - strokeWidth) * bottomEnd, h - half),
        paint,
      );
    }

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