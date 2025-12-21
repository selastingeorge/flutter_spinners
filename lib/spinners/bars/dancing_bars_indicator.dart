import 'package:flutter/material.dart';

class DancingBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const DancingBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<DancingBarsIndicator> createState() => _DancingBarsIndicatorState();
}

class _DancingBarsIndicatorState extends State<DancingBarsIndicator> with SingleTickerProviderStateMixin {
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
            painter: _DancingBarsPainter(
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

class _DancingBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double borderRadius;

  _DancingBarsPainter({required this.t, required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final barWidth = size.width * 0.10;
    final barHeightMax = size.height * 0.65;
    final gap = barWidth;
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size.width - totalBarsWidth) / 2;
    final xPositions = [startX, startX + barWidth + gap, startX + (barWidth + gap) * 2];
    final keyframes = [
      [1.0, 1.0, 1.0],
      [0.6, 1.0, 1.0],
      [0.8, 0.6, 1.0],
      [1.0, 0.8, 0.6],
      [1.0, 1.0, 0.8],
      [1.0, 1.0, 1.0],
    ];

    const nFrames = 6;
    final frameTime = 1.0 / (nFrames - 1);

    for (int i = 0; i < 3; i++) {
      int frame = (t / frameTime).floor();
      int nextFrame = (frame + 1) % nFrames;
      double localT = (t - frame * frameTime) / frameTime;

      final heightFactor = keyframes[frame][i] + (keyframes[nextFrame][i] - keyframes[frame][i]) * localT;
      final dy = size.height - barHeightMax * heightFactor;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xPositions[i], dy, barWidth, barHeightMax * heightFactor),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DancingBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
