import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlippingDotsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FlippingDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<FlippingDotsIndicator> createState() => _FlippingDotsIndicatorState();
}

class _FlippingDotsIndicatorState extends State<FlippingDotsIndicator>
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
      height: widget.size / 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _FlippingDotsPainter(
              t: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}


class _FlippingDotsPainter extends CustomPainter {
  final double t;
  final Color color;

  _FlippingDotsPainter({
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final radius = size.height * 0.35;
    final cy = size.height / 2;
    final spacing = size.width / 3;
    final activeIndex = (t * 3).floor() % 3;
    final localT = (t * 3) % 1.0;

    const double perspective = 0.004;

    for (int i = 0; i < 3; i++) {
      final dx = spacing * i + spacing / 2;

      canvas.save();
      canvas.translate(dx, cy);

      if (i == activeIndex) {
        final angle = localT * math.pi;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, perspective)
          ..rotateX(angle);

        canvas.transform(matrix.storage);
      }

      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlippingDotsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
