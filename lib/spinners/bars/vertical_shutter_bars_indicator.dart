import 'package:flutter/material.dart';

class VerticalShutterBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const VerticalShutterBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<VerticalShutterBarsIndicator> createState() =>
      _VerticalShutterBarsIndicatorState();
}

class _VerticalShutterBarsIndicatorState
    extends State<VerticalShutterBarsIndicator>
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
            painter: _VerticalShutterBarsPainter(
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

class _VerticalShutterBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _VerticalShutterBarsPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  static const double cell = 6.0;
  static const double gap = 6.0;
  static const double rowHeight = 7.0;
  static const int cols = 3;
  static const int rows = 4;

  static const double rowDrop = 0.12;
  static const double rowPause = 0.05;
  static const double holdAll = 0.12;

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
  double _progress(double t, double start, double len) =>
      _clamp01((t - start) / len);

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;

    final gridW = cols * cell + (cols - 1) * gap;
    final gridH = rows * rowHeight;

    final ox = (size - gridW) / 2;
    final oy = (size - gridH) / 2;

    final step = rowDrop + rowPause;
    final entrySpan = rows * step;
    final exitSpan = rows * step;
    final totalSpan = entrySpan + holdAll + exitSpan;

    final time = (t * totalSpan) % totalSpan;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(ox, oy, gridW, gridH));

    if (time < entrySpan) {
      for (int i = 0; i < rows; i++) {
        final start = i * step;
        if (time < start) break;

        final k = _progress(time, start, rowDrop);
        final targetRow = rows - 1 - i;
        final y = oy - rowHeight + gridH * k * ((targetRow + 1) / rows);

        _drawRow(canvas, paint, ox, y);
      }
    }
    else if (time < entrySpan + holdAll) {
      for (int i = 0; i < rows; i++) {
        final targetRow = rows - 1 - i;
        final y = oy + targetRow * rowHeight;
        _drawRow(canvas, paint, ox, y);
      }
    }
    else {
      final exitTime = time - (entrySpan + holdAll);

      for (int i = 0; i < rows; i++) {
        final start = i * step;
        final targetRow = rows - 1 - i;
        final baseY = oy + targetRow * rowHeight;

        if (exitTime < start) {
          _drawRow(canvas, paint, ox, baseY);
        } else {
          final k = _progress(exitTime, start, rowDrop);
          final y = baseY + gridH * k * ((targetRow + 1) / rows);
          if (k < 1) {
            _drawRow(canvas, paint, ox, y);
          }
        }
      }
    }

    canvas.restore();
  }

  void _drawRow(Canvas canvas, Paint paint, double ox, double y) {
    for (int col = 0; col < cols; col++) {
      final x = ox + col * (cell + gap);
      canvas.drawRect(
        Rect.fromLTWH(x, y, cell, rowHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalShutterBarsPainter old) =>
      old.t != t || old.color != color;
}

