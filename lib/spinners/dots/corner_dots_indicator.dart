import 'package:flutter/material.dart';

class CornerDotsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const CornerDotsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<CornerDotsIndicator> createState() => _CornerDotsIndicatorState();
}

class _CornerDotsIndicatorState extends State<CornerDotsIndicator>
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _CornerDotsPainter(
              t: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _CornerDotsPainter extends CustomPainter {
  final double t;
  final Color color;

  _CornerDotsPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final spacing = size.width / 3;
    final radius = spacing * 0.26;
    final offsetX = (size.width - spacing) / 2;
    final offsetY = (size.height - spacing) / 2;
    final positions = [
      Offset(0, 0),
      Offset(spacing, 0),
      Offset(spacing, spacing),
      Offset(0, spacing),
    ];

    final curve = Curves.easeInOut;

    for (int i = 0; i < 3; i++) {
      double progress = (t + i / 4) % 1;

      int startIndex = (progress * 4).floor() % 4;
      int endIndex = (startIndex + 1) % 4;

      double localT = (progress * 4) - (progress * 4).floor();
      localT = curve.transform(localT);

      final start = positions[startIndex];
      final end = positions[endIndex];

      final dx = start.dx + (end.dx - start.dx) * localT + offsetX;
      final dy = start.dy + (end.dy - start.dy) * localT + offsetY;

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerDotsPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
