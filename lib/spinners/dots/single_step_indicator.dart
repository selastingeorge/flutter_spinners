import 'package:flutter/material.dart';

class SingleStepLoader extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SingleStepLoader({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<SingleStepLoader> createState() => _SingleStepLoaderState();
}

class _SingleStepLoaderState extends State<SingleStepLoader>
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
            painter: _SingleStepPainter(
              progress: _steppedProgress(_controller.value),
              color: widget.color,
              width: widget.size,
            ),
          );
        },
      ),
    );
  }

  double _steppedProgress(double t) {
    const steps = 3;
    return (t * steps).floor() / steps;
  }
}

class _SingleStepPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;

  _SingleStepPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final positions = 3;
    final spacing = width / positions;
    final radius = size.height * 0.35;
    final dx = spacing / 2 + progress * spacing * positions;
    final dy = size.height / 2;

    canvas.drawCircle(Offset(dx, dy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _SingleStepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
