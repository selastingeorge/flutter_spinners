import 'dart:math' as math;
import 'package:flutter/material.dart';

class PulseDotsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const PulseDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<PulseDotsIndicator> createState() => _PulseDotsIndicatorState();
}

class _PulseDotsIndicatorState extends State<PulseDotsIndicator>
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
            painter: _PulseDotsPainter(
              t: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _PulseDotsPainter extends CustomPainter {
  final double t;
  final Color color;

  _PulseDotsPainter({
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final radius = size.height * 0.35;
    final cy = size.height / 2;
    final spacing = size.width / 3;

    for (int i = 0; i < 3; i++) {
      final phase = (t - i / 3) * 2 * math.pi;
      final wave = math.cos(phase);
      final normalized = (wave + 1) / 2;
      final scale = normalized;
      final dx = spacing * i + spacing / 2;

      canvas.save();
      canvas.translate(dx, cy);
      canvas.scale(scale, scale);
      canvas.drawCircle(Offset.zero, radius, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PulseDotsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
