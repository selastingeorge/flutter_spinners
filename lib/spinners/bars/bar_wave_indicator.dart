import 'dart:math' as math;
import 'package:flutter/material.dart';

class BarWaveIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const BarWaveIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<BarWaveIndicator> createState() => _BarWaveIndicatorState();
}

class _BarWaveIndicatorState extends State<BarWaveIndicator> with SingleTickerProviderStateMixin {
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
            painter: _BarWavePainter(
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

class _BarWavePainter extends CustomPainter {
  final double t;
  final Color color;
  final double borderRadius;

  _BarWavePainter({required this.t, required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final barWidth = size.width * 0.10;
    final barHeight = size.height * 0.65;
    final gap = barWidth;
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size.width - totalBarsWidth) / 2;
    final xPositions = [startX, startX + barWidth + gap, startX + (barWidth + gap) * 2];

    for (int i = 0; i < 3; i++) {
      final phase = (t + i * 0.2) % 1.0;
      final yFactor = (1 - (0.5 + 0.5 * math.sin(2 * math.pi * phase)));
      final dy = (size.height - barHeight) * yFactor;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPositions[i], dy, barWidth, barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarWavePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
