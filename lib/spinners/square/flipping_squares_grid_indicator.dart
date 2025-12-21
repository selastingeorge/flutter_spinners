import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlippingSquaresGridIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FlippingSquaresGridIndicator({
    super.key,
    this.size = 36,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<FlippingSquaresGridIndicator> createState() =>
      _FlippingSquaresGridIndicatorState();
}

class _FlippingSquaresGridIndicatorState extends State<FlippingSquaresGridIndicator>
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
            painter: _FlippingSquaresGridPainter(
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

class _FlippingSquaresGridPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _FlippingSquaresGridPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  static const int cellCount = 4;
  static const double flipPortion = 0.16;
  static const double pausePortion = 0.09;

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
  double _progress(double t, double start, double len) =>
      _clamp01((t - start) / len);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    final cell = size / 2;
    final step = flipPortion + pausePortion;
    final bool verticalFlip = ((t * 2).floor() % 2) == 0;

    for (int i = 0; i < cellCount; i++) {
      final start = i * step;
      final k = _progress(t % 0.5 * 2, start, flipPortion);
      final row = i ~/ 2;
      final col = i % 2;
      final cx = col * cell + cell / 2;
      final cy = row * cell + cell / 2;
      final angle = math.pi * k;
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, 0.012);

      if (verticalFlip) {
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
          width: cell,
          height: cell,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlippingSquaresGridPainter old) =>
      old.t != t || old.color != color;
}
