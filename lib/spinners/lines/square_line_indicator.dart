import 'package:flutter/material.dart';

class SquareLineIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double strokeWidth;

  const SquareLineIndicator({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF046D8B),
    this.duration = const Duration(seconds: 1),
    this.strokeWidth = 4,
  });

  @override
  State<SquareLineIndicator> createState() => _SquareLineIndicatorState();
}

class _SquareLineIndicatorState extends State<SquareLineIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
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
            painter: _SquareLinePainter(
              t: _controller.value,
              color: widget.color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _SquareLinePainter extends CustomPainter {
  final double t;
  final Color color;
  final double strokeWidth;

  _SquareLinePainter({
    required this.t,
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

    double top = 0, right = 0, bottom = 0, left = 0;

    if (t < 0.25) {
      top = t / 0.25;
    } else if (t < 0.5) {
      top = 1;
      right = (t - 0.25) / 0.25;
    } else if (t < 0.75) {
      top = right = 1;
      bottom = (t - 0.5) / 0.25;
    } else {
      top = right = bottom = 1;
      left = (t - 0.75) / 0.25;
    }

    if (top > 0) {
      canvas.drawLine(
        Offset(half, half),
        Offset(half + (w - strokeWidth) * top, half),
        paint,
      );
    }

    if (right > 0) {
      canvas.drawLine(
        Offset(w - half, half),
        Offset(w - half, half + (h - strokeWidth) * right),
        paint,
      );
    }

    if (bottom > 0) {
      canvas.drawLine(
        Offset(w - half, h - half),
        Offset(w - half - (w - strokeWidth) * bottom, h - half),
        paint,
      );
    }

    if (left > 0) {
      canvas.drawLine(
        Offset(half, h - half),
        Offset(half, h - half - (h - strokeWidth) * left),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SquareLinePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
