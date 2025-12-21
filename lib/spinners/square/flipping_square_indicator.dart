import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlippingSquareIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FlippingSquareIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<FlippingSquareIndicator> createState() =>
      _FlippingSquareIndicatorState();
}

class _FlippingSquareIndicatorState
    extends State<FlippingSquareIndicator>
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
        builder: (_, _) {
          return CustomPaint(
            painter: _FlippingSquarePainter(
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

class _FlippingSquarePainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _FlippingSquarePainter({
    required this.t,
    required this.color,
    required this.size,
  });

  static const double flipPortion = 0.55;

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    const squareSize = 36.0;
    final cx = size / 2;
    final cy = size / 2;
    final int cycle = (t * 2).floor();
    final bool flipVertically = cycle.isEven;
    final double localT = (t * 2) % 1.0;

    double angle;
    if (localT < flipPortion) {
      angle = math.pi * _clamp01(localT / flipPortion);
    } else {
      angle = math.pi;
    }

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.012);

    if (flipVertically) {
      matrix.rotateX(angle);
    } else {
      matrix.rotateY(angle);
    }

    canvas.save();
    canvas.translate(cx, cy);
    canvas.transform(matrix.storage);

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
  bool shouldRepaint(covariant _FlippingSquarePainter old) =>
      old.t != t || old.color != color;
}
