import 'package:flutter/material.dart';

class HorizontalShutterBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const HorizontalShutterBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<HorizontalShutterBarsIndicator> createState() =>
      _HorizontalShutterBarsIndicatorState();
}

class _HorizontalShutterBarsIndicatorState extends State<HorizontalShutterBarsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
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
            painter: _HorizontalShutterGridBarsPainter(
              t: _controller.value,
              color: widget.color,
              size: widget.size,
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalShutterGridBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _HorizontalShutterGridBarsPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  static const double cell = 6.0;
  static const double gap = 6.0;
  static const double rowHeight = 7.0;
  static const int cols = 3;
  static const int rows = 4;

  static const double rowSlide = 0.08;
  static const double rowPause = 0.04;
  static const double holdAll = 0.12;

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
  double _progress(double t, double start, double length) =>
      _clamp01((t - start) / length);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    final gridW = cols * cell + (cols - 1) * gap;
    final gridH = rows * rowHeight;
    final ox = (size - gridW) / 2;
    final oy = (size - gridH) / 2;
    final gridRect = Rect.fromLTWH(ox, oy, gridW, gridH);

    canvas.save();
    canvas.clipRect(gridRect);

    final entrySpan = rows * (rowSlide + rowPause);
    final exitStart = entrySpan + holdAll;

    for (int row = 0; row < rows; row++) {
      final entryStart = row * (rowSlide + rowPause);
      final exitStartRow = exitStart + row * (rowSlide + rowPause);

      double dx;
      if (t < entrySpan) {
        final k = _progress(t, entryStart, rowSlide);
        dx = -gridW + gridW * k;
      } else if (t >= exitStart) {
        final k = _progress(t, exitStartRow, rowSlide);
        dx = gridW * k;
      } else {
        dx = 0;
      }

      final y = oy + row * rowHeight;

      for (int col = 0; col < cols; col++) {
        final x = ox + col * (cell + gap) + dx;

        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, rowHeight),
          paint,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HorizontalShutterGridBarsPainter old) =>
      old.t != t || old.color != color;
}
