import 'package:flutter/material.dart';

class SquareWaveGridIndicator extends StatefulWidget {
  const SquareWaveGridIndicator({
    super.key,
    this.size = 40.0,
    this.color = const Color(0xFFFFFFFF),
    this.duration = const Duration(milliseconds: 1300),
  });

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<SquareWaveGridIndicator> createState() => _SquareWaveGridIndicatorState();
}

class _SquareWaveGridIndicatorState extends State<SquareWaveGridIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  final List<double> _delays = [0.2, 0.3, 0.4, 0.1, 0.2, 0.3, 0.0, 0.1, 0.2];

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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SquareWaveGridPainter(
              progress: _controller.value,
              size: widget.size,
              color: widget.color,
              delays: _delays,
            ),
          );
        },
      ),
    );
  }
}

class _SquareWaveGridPainter extends CustomPainter {
  _SquareWaveGridPainter({
    required this.progress,
    required this.size,
    required this.color,
    required this.delays,
  });

  final double progress;
  final double size;
  final Color color;
  final List<double> delays;

  static const double gridFraction = 0.9;

  double _scaleForProgress(double t) {
    t = t % 1.0;

    if (t < 0.15) return 1.0;
    if (t < 0.35) {
      return 1 - Curves.easeInOut.transform((t - 0.15) / 0.20);
    }
    if (t < 0.55) {
      return Curves.easeInOut.transform((t - 0.35) / 0.20);
    }
    return 1.0;
  }

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    final gridSize = size * gridFraction;
    final cubeSize = gridSize / 3;
    final ox = (size - gridSize) / 2;
    final oy = (size - gridSize) / 2;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final index = row * 3 + col;
        double t = (progress - delays[index]) % 1.0;
        if (t < 0) t += 1.0;

        final scale = _scaleForProgress(t);
        final inset = cubeSize * (1 - scale) / 2;

        canvas.drawRect(
          Rect.fromLTWH(
            ox + col * cubeSize + inset,
            oy + row * cubeSize + inset,
            cubeSize * scale,
            cubeSize * scale,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SquareWaveGridPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
