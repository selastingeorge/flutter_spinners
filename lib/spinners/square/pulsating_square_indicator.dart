import 'dart:math' as math;
import 'package:flutter/material.dart';

class PulsatingSquareIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const PulsatingSquareIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulsatingSquareIndicator> createState() =>
      _PulsatingSquareIndicatorState();
}

class _PulsatingSquareIndicatorState
    extends State<PulsatingSquareIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
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
        builder: (_, __) {
          return CustomPaint(
            painter: _ElasticSquarePainter(
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

class _ElasticSquarePainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _ElasticSquarePainter({
    required this.t,
    required this.color,
    required this.size,
  });

  double _elasticOut(double x) {
    if (x == 0 || x == 1) return x;
    const c4 = (2 * math.pi) / 3;
    return math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1;
  }

  @override
  void paint(Canvas canvas, Size _) {
    const squareSize = 36.0;

    final cx = size / 2;
    final cy = size / 2;

    double scale;
    if (t < 0.4) {
      scale = 1.0 - 0.35 * (t / 0.4);
    } else {
      final k = (t - 0.4) / 0.6;
      scale = 0.65 + (1.0 - 0.65) * _elasticOut(k);
    }

    final paint = Paint()..color = color;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: squareSize,
        height: squareSize,
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ElasticSquarePainter old) =>
      old.t != t || old.color != color;
}
