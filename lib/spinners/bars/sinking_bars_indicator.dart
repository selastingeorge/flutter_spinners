import 'package:flutter/material.dart';

class SinkingBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const SinkingBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<SinkingBarsIndicator> createState() => _SinkingBarsIndicatorState();
}

class _SinkingBarsIndicatorState extends State<SinkingBarsIndicator> with SingleTickerProviderStateMixin {
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _SinkingBarsPainter(t: _controller.value, color: widget.color, size: widget.size),
          );
        },
      ),
    );
  }
}

class _SinkingBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _SinkingBarsPainter({required this.t, required this.color, required this.size});

  static const double cell = 6.0;
  static const double gap = 6.0;
  static const double rowHeight = 10.0;
  static const int cols = 3;
  static const int rows = 3;
  static const double rowFill = 0.08;
  static const double rowPause = 0.04;
  static const double holdAll = 0.12;

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
  double _progress(double t, double start, double length) => _clamp01((t - start) / length);

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

    final entrySpan = rows * (rowFill + rowPause);
    final exitStart = entrySpan + holdAll;

    for (int row = 0; row < rows; row++) {
      final entryStart = row * (rowFill + rowPause);
      final exitStartRow = exitStart + row * (rowFill + rowPause);

      double h;

      if (t < entrySpan) {
        final k = _progress(t, entryStart, rowFill);
        h = rowHeight * k;
      } else if (t >= exitStart) {
        final k = _progress(t, exitStartRow, rowFill);
        h = rowHeight * (1 - k);
      } else {
        h = rowHeight;
      }

      if (h <= 0) continue;

      final yBottom = oy + (row + 1) * rowHeight;

      for (int col = 0; col < cols; col++) {
        final x = ox + col * (cell + gap);

        canvas.drawRect(Rect.fromLTWH(x, yBottom - h, cell, h), paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SinkingBarsPainter old) => old.t != t || old.color != color;
}
