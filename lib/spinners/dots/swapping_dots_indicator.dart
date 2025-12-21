import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class SwappingDotsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SwappingDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<SwappingDotsIndicator> createState() => _SwappingDotsIndicatorState();
}

class _SwappingDotsIndicatorState extends State<SwappingDotsIndicator> with SingleTickerProviderStateMixin {
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
      height: widget.size / 4,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _SwappingDotsPainter(
              progress: _controller.value,
              color: widget.color,
              width: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class _SwappingDotsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;

  _SwappingDotsPainter({required this.progress, required this.color, required this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final radius = size.height * 0.35;
    const int dotCount = 3;
    final spacing = width / dotCount;
    final baselineY = size.height / 2;
    final slots = List.generate(dotCount, (i) => i * spacing + spacing / 2);
    final cycleProgress = (progress * dotCount) % 1;

    for (int i = 0; i < dotCount; i++) {
      double dx;
      double dy = baselineY;

      if (i == dotCount - 1) {
        final start = slots[i];
        final end = slots[0];
        dx = lerpDouble(start, end, cycleProgress)!;
        final arcHeight = size.height * 1.2;
        dy -= arcHeight * math.sin(cycleProgress * math.pi);
      } else {
        final start = slots[i];
        final end = slots[i + 1];
        dx = lerpDouble(start, end, cycleProgress)!;
      }

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SwappingDotsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
