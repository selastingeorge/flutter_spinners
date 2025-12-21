import 'package:flutter/material.dart';

class GrowingBarWaveIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const GrowingBarWaveIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<GrowingBarWaveIndicator> createState() => _GrowingBarWaveIndicatorState();
}

class _GrowingBarWaveIndicatorState extends State<GrowingBarWaveIndicator>
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
      height: widget.size * 0.8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _GrowingBarWavePainter(
              t: _controller.value,
              color: widget.color,
              size: widget.size,
              borderRadius: widget.borderRadius,
            ),
          );
        },
      ),
    );
  }
}

class _GrowingBarWavePainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;
  final double borderRadius;

  _GrowingBarWavePainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    final barWidth = size * 0.10;
    final gap = barWidth;
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size - totalBarsWidth) / 2;
    final xPositions = [startX, startX + barWidth + gap, startX + 2 * (barWidth + gap)];
    final barHeightMax = size * 0.80;
    final keyframes = [
      [0.5, 0.5, 0.5],
      [0.2, 0.5, 0.5],
      [1.0, 0.2, 0.5],
      [0.5, 1.0, 0.2],
      [0.5, 0.5, 1.0],
      [0.5, 0.5, 0.5],
    ];

    const nFrames = 6;
    final frameTime = 1.0 / (nFrames - 1);

    for (int i = 0; i < 3; i++) {
      int frame = (t / frameTime).floor();
      int next = (frame + 1) % nFrames;
      final localT = (t - frame * frameTime) / frameTime;

      final factor = keyframes[frame][i] + (keyframes[next][i] - keyframes[frame][i]) * localT;

      final barHeight = barHeightMax * factor;
      final y = (size * 0.8 - barHeight) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPositions[i], y, barWidth, barHeight),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowingBarWavePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
