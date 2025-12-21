import 'package:flutter/material.dart';
import 'dart:math' as math;

class DoubleRowBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const DoubleRowBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<DoubleRowBarsIndicator> createState() =>
      _DoubleRowBarsIndicatorState();
}

class _DoubleRowBarsIndicatorState
    extends State<DoubleRowBarsIndicator> with SingleTickerProviderStateMixin {
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
      height: widget.size * 0.8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _DoubleRowBarsPainter(
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

class _DoubleRowBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;
  final double borderRadius;

  _DoubleRowBarsPainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    final barWidth = size * 0.10;
    final gap = barWidth;
    final totalBarsWidth = barWidth * 3 + gap * 2;
    final startX = (size - totalBarsWidth) / 2;
    final xPositions = [
      startX,
      startX + barWidth + gap,
      startX + 2 * (barWidth + gap),
    ];
    final containerHeight = size * 0.55;
    final barMaxHeight = containerHeight;
    final topRowY = (size * 0.8 - containerHeight) / 2;
    final bottomRowBase = topRowY + containerHeight;

    const nCols = 3;
    final segment = t * nCols;
    final activeColumn = segment.floor() % nCols;
    final localT = segment % 1.0;

    final smoothT = 0.5 - 0.5 * math.cos(localT * math.pi);

    for (int i = 0; i < nCols; i++) {
      final x = xPositions[i];
      final heightFactor = (i == activeColumn) ? smoothT : 0.2;
      final barHeight = barMaxHeight * heightFactor;

      final rectTop = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, topRowY, barWidth, barHeight),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rectTop, paint);

      final rectBottom = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, bottomRowBase - barHeight, barWidth, barHeight),
        Radius.circular(borderRadius),
      );
      canvas.drawRRect(rectBottom, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DoubleRowBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
