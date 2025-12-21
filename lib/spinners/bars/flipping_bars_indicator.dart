import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlippingBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const FlippingBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1200),
    this.borderRadius = 0,
  });

  @override
  State<FlippingBarsIndicator> createState() => _FlippingBarsIndicatorState();
}

class _FlippingBarsIndicatorState extends State<FlippingBarsIndicator> with SingleTickerProviderStateMixin {
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
      height: widget.size * 0.8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _FlippingBarsPainter(
              t: _controller.value,
              color: widget.color,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

class _FlippingBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double borderRadius;

  _FlippingBarsPainter({required this.t, required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final barWidth = size.width * 0.10;
    final barHeight = size.height * 0.65;

    final gap = barWidth;
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size.width - totalBarsWidth) / 2;
    final centerY = size.height / 2;

    const barCount = 3;
    final slot = 1.0 / barCount;
    final depth = 0.0025;

    for (int i = 0; i < barCount; i++) {
      final x = startX + i * (barWidth + gap);
      final start = i * slot;
      final end = start + slot;

      double angle = 0;

      if (t >= start && t < end) {
        final localT = (t - start) / slot;
        angle = localT * math.pi;
      } else if (t >= end) {
        angle = math.pi;
      }

      canvas.save();
      canvas.translate(x + barWidth / 2, centerY);
      final matrix = Matrix4.identity()
        ..setEntry(3, 2, depth)
        ..rotateX(angle);
      canvas.transform(matrix.storage);

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: barWidth, height: barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FlippingBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
