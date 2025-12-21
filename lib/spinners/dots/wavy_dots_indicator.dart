import 'package:flutter/material.dart';

class WavyDotsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Duration pauseDuration; // new parameter for delay

  const WavyDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.pauseDuration = const Duration(milliseconds: 300), // default pause
  });

  @override
  State<WavyDotsIndicator> createState() => _WavyDotsIndicatorState();
}

class _WavyDotsIndicatorState extends State<WavyDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(widget.pauseDuration);
        if (!mounted) return;
        _controller.reset();
        _controller.forward();
      }
    });

    _controller.forward();
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
            painter: _WavyDotsPainter(
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

class _WavyDotsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;

  _WavyDotsPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final dotCount = 3;
    final spacing = width / 3;
    final radius = size.height * 0.35;
    final keyframes = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];
    final List<List<double>> yKeyframes = [
      [0.5, 0.0, 1.0, 0.5, 0.5, 0.5],
      [0.5, 0.5, 0.0, 1.0, 0.5, 0.5],
      [0.5, 0.5, 0.5, 0.0, 1.0, 0.5],
    ];

    for (int i = 0; i < dotCount; i++) {
      int k = 0;
      while (k < keyframes.length - 1 && progress > keyframes[k + 1]) {
        k++;
      }

      final t0 = keyframes[k];
      final t1 = keyframes[k + 1];
      final y0 = yKeyframes[i][k];
      final y1 = yKeyframes[i][k + 1];
      final localT = (progress - t0) / (t1 - t0);
      final y = y0 + (y1 - y0) * localT;
      final dx = spacing * i + spacing / 2;
      final dy = y * size.height;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyDotsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
