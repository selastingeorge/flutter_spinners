import 'package:flutter/material.dart';

class QuadDotSwapIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const QuadDotSwapIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<QuadDotSwapIndicator> createState() => _QuadDotSwapIndicatorState();
}

class _QuadDotSwapIndicatorState extends State<QuadDotSwapIndicator>
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
        builder: (_, _) {
          return CustomPaint(
            painter: _QuadDotSwapPainter(
              t: _controller.value,
              dotColor: widget.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class _QuadDotSwapPainter extends CustomPainter {
  final double t;
  final Color dotColor;
  final double size;

  _QuadDotSwapPainter({
    required this.t,
    required this.dotColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final dotPaint = Paint()..color = dotColor;
    final baseSquareSize = size * 0.6;
    final dotRadius = baseSquareSize * 0.145;
    final squareSize = baseSquareSize - dotRadius * 2;
    final offset = Offset(
      (size - baseSquareSize) / 2 + dotRadius,
      (size - baseSquareSize) / 2 + dotRadius,
    );

    List<Offset> corners = [
      offset + Offset(0, 0),
      offset + Offset(squareSize, 0),
      offset + Offset(squareSize, squareSize),
      offset + Offset(0, squareSize),
    ];

    final center = offset + Offset(squareSize / 2, squareSize / 2);
    corners = corners.map((corner) {
      final dx = center.dx + (corner.dx - center.dx) * 0.8;
      final dy = center.dy + (corner.dy - center.dy) * 0.8;
      return Offset(dx, dy);
    }).toList();

    double cycleT = (t * 2) % 1;
    int swapStep = (t * 2).floor();

    final easedT = Curves.easeInOutCubic.transform(cycleT);

    List<Offset> dots = List.from(corners);

    if (swapStep == 0) {
      dots[0] = Offset.lerp(corners[0], corners[2], easedT)!;
      dots[2] = Offset.lerp(corners[2], corners[0], easedT)!;
    } else {
      dots[1] = Offset.lerp(corners[1], corners[3], easedT)!;
      dots[3] = Offset.lerp(corners[3], corners[1], easedT)!;
    }

    for (final dot in dots) {
      canvas.drawCircle(dot, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _QuadDotSwapPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.dotColor != dotColor;
}
