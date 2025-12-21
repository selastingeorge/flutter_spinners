import 'package:flutter/material.dart';

class ShadowDotsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const ShadowDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<ShadowDotsIndicator> createState() => _ShadowDotsIndicatorState();
}

class _ShadowDotsIndicatorState extends State<ShadowDotsIndicator>
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
    final height = widget.size / 4;

    return SizedBox(
      width: widget.size,
      height: height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _ShadowDotsPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _ShadowDotsPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShadowDotsPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final radius = size.height * 0.35;
    final cy = size.height / 2;
    final spacing = size.width / 3;
    final phase = progress * 3;

    const int full = 0xFF;
    const int mid  = 0x66;
    const int low  = 0x22;

    int alphaForDot(int index) {
      final d = (phase - index).abs();

      if (d < 0.5) return full;
      if (d < 1.5) return mid;
      return low;
    }

    for (int i = 0; i < 3; i++) {
      paint.color = color.withAlpha(alphaForDot(i));

      final dx = spacing * i + spacing / 2;
      canvas.drawCircle(
        Offset(dx, cy),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShadowDotsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
