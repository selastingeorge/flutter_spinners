import 'package:flutter/material.dart';

class SlidingSquareLineIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double strokeWidth;
  final double snakeLength;

  const SlidingSquareLineIndicator({
    super.key,
    this.size = 35,
    this.color = const Color(0xFF046D8B),
    this.duration = const Duration(seconds: 4),
    this.strokeWidth = 4,
    this.snakeLength = 0.25,
  });

  @override
  State<SlidingSquareLineIndicator> createState() => _SlidingSquareLineIndicatorState();
}

class _SlidingSquareLineIndicatorState extends State<SlidingSquareLineIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
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

class _SlidingSquareLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
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
    final half = strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const totalSides = 4;

    double headProgress = progress;
    double tailProgress = progress - snakeLength;

    Offset getPointAtProgress(double p) {
      p = p % 1.0;
      if (p < 0) p += 1.0;

      double sideProgress = (p * totalSides) % 1.0;
      int side = (p * totalSides).floor() % totalSides;

      switch (side) {
        case 0:
          return Offset(half + (w - strokeWidth) * sideProgress, half);
        case 1:
          return Offset(w - half, half + (h - strokeWidth) * sideProgress);
        case 2:
          return Offset(w - half - (w - strokeWidth) * sideProgress, h - half);
        case 3:
        default:
          return Offset(half, h - half - (h - strokeWidth) * sideProgress);
      }
    }

    if (tailProgress < 0) {
      double wrappedTail = tailProgress + 1.0;
      for (double t = wrappedTail; t < 1.0;) {
        int currentSide = (t * totalSides).floor() % totalSides;
        double nextSideStart = (currentSide + 1) / totalSides.toDouble();
        double segmentEnd = nextSideStart > 1.0 ? 1.0 : nextSideStart;
        canvas.drawLine(getPointAtProgress(t), getPointAtProgress(segmentEnd), paint);
        t = segmentEnd;
        if (t >= 1.0) break;
      }

      for (double t = 0.0; t < headProgress;) {
        int currentSide = (t * totalSides).floor() % totalSides;
        double nextSideStart = (currentSide + 1) / totalSides.toDouble();
        double segmentEnd = nextSideStart > headProgress ? headProgress : nextSideStart;
        canvas.drawLine(getPointAtProgress(t), getPointAtProgress(segmentEnd), paint);
        t = segmentEnd;
        if (t >= headProgress) break;
      }
    } else {
      int headSide = (headProgress * totalSides).floor() % totalSides;
      int tailSide = (tailProgress * totalSides).floor() % totalSides;

      if (headSide == tailSide) {
        canvas.drawLine(getPointAtProgress(tailProgress), getPointAtProgress(headProgress), paint);
      } else {
        double tailSideEnd = (tailSide + 1) / totalSides.toDouble();
        canvas.drawLine(getPointAtProgress(tailProgress), getPointAtProgress(tailSideEnd), paint);

        for (int i = tailSide + 1; i < headSide; i++) {
          int side = i % totalSides;
          double sideStart = side / totalSides.toDouble();
          double sideEnd = (side + 1) / totalSides.toDouble();
          canvas.drawLine(getPointAtProgress(sideStart), getPointAtProgress(sideEnd), paint);
        }

        double headSideStart = headSide / totalSides.toDouble();
        canvas.drawLine(getPointAtProgress(headSideStart), getPointAtProgress(headProgress), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SlidingSquareLinePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
