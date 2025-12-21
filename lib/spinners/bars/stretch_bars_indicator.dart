import 'dart:math' as math;
import 'package:flutter/material.dart';

class StretchBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const StretchBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<StretchBarsIndicator> createState() => _StretchBarsIndicatorState();
}

class _StretchBarsIndicatorState extends State<StretchBarsIndicator>
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
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _StretchBarsPainter(
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

class _StretchBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;
  final double borderRadius;
  final int gap = 6;

  _StretchBarsPainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  static const double bar = 6.0;

  double _ease(double t) => math.sin(t * math.pi / 2);
  double _seg(double t, double a, double b) {
    if (t <= a) return 0;
    if (t >= b) return 1;
    return (t - a) / (b - a);
  }

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    final layoutW = bar * 3 + gap * 2;
    final layoutH = bar * 3 + gap * 2;
    final ox = (size - layoutW) / 2;
    final oy = (size - layoutH) / 2;


    final baseX = [ox, ox + bar + gap, ox + (bar + gap) * 2];
    final baseY = [oy, oy + bar + gap, oy + (bar + gap) * 2];
    final vExpand = _ease(_seg(t, 0.00, 0.15));
    final vCollapse = _ease(_seg(t, 0.22, 0.37));
    final hExpand = _ease(_seg(t, 0.44, 0.59));
    final hCollapse = _ease(_seg(t, 0.66, 0.81));
    final vLen = layoutH;
    final hLen = layoutW;

    for (int i = 0; i < 3; i++) {
      double dx = baseX[i];
      double dy = baseY[i];
      double w = bar;
      double h = bar;

      if (vExpand > 0 && vCollapse == 0) {
        final k = vExpand;
        h = bar + (vLen - bar) * k;
        dy = baseY[i] - (vLen - bar) * k * (i / 2.0);
      } else if (vCollapse > 0) {
        final k = 1 - vCollapse;
        h = bar + (vLen - bar) * k;
        dy = baseY[i] - (vLen - bar) * k * (i / 2.0);
      }

      if (hExpand > 0 && hCollapse == 0) {
        final k = hExpand;
        w = bar + (hLen - bar) * k;
        dx = baseX[i] - (hLen - bar) * k * (i / 2.0);
      } else if (hCollapse > 0) {
        final k = 1 - hCollapse;
        w = bar + (hLen - bar) * k;
        dx = baseX[i] - (hLen - bar) * k * (i / 2.0);
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(dx, dy, w, h), Radius.circular(borderRadius)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StretchBarsPainter old) => old.t != t || old.color != color;
}
