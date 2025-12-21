import 'package:flutter/material.dart';
import 'dart:math';

class SteppedDotsLoader extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SteppedDotsLoader({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<SteppedDotsLoader> createState() => _SteppedDotsLoaderState();
}

class _SteppedDotsLoaderState extends State<SteppedDotsLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _steppedAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
    _steppedAnimation = _controller.drive(StepTween(begin: 0, end: 4));
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
        animation: _steppedAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _SteppedDotsPainter(step: _steppedAnimation.value, color: widget.color),
          );
        },
      ),
    );
  }
}

class _SteppedDotsPainter extends CustomPainter {
  final int step;
  final Color color;
  static final Paint _paint = Paint();

  _SteppedDotsPainter({required this.step, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    _paint.color = color;

    const dotCount = 3;
    final spacing = size.width / dotCount;
    final radius = min(spacing, size.height) * 0.35;
    final dy = size.height * 0.5;
    final progress = step / 4.0;
    final clipWidth = size.width * (1 + 0.34) * progress;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, clipWidth, size.height));
    canvas.drawCircle(Offset(spacing * 0.5, dy), radius, _paint);
    canvas.drawCircle(Offset(spacing * 1.5, dy), radius, _paint);
    canvas.drawCircle(Offset(spacing * 2.5, dy), radius, _paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SteppedDotsPainter oldDelegate) {
    return oldDelegate.step != step || oldDelegate.color != color;
  }
}
