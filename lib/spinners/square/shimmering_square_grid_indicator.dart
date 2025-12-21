import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class ShimmeringSquareGridIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const ShimmeringSquareGridIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<ShimmeringSquareGridIndicator> createState() =>
      _ShimmeringSquareGridIndicatorState();
}

class _ShimmeringSquareGridIndicatorState
    extends State<ShimmeringSquareGridIndicator>
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
            painter: _ShimmeringSquareGridPainter(
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

class _ShimmeringSquareGridPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;

  _ShimmeringSquareGridPainter({
    required this.t,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size s) {
    final gridSize = size * 0.7;
    final spacing = gridSize / 3;
    final squareSize = spacing * 0.7;

    final offset = Offset(
      (size - gridSize) / 2,
      (size - gridSize) / 2,
    );

    final shimmerPos = lerpDouble(-1, 5, t)!;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final diagonalIndex = row + col;
        final dist = (diagonalIndex - shimmerPos).abs();
        final intensity = math.exp(-dist * dist * 1.6);
        final alpha = (70 + intensity * 185).round().clamp(0, 255);

        final paint = Paint()
          ..color = color.withAlpha(alpha);

        final dx = offset.dx + col * spacing + (spacing - squareSize) / 2;
        final dy = offset.dy + row * spacing + (spacing - squareSize) / 2;

        canvas.drawRect(
          Rect.fromLTWH(dx, dy, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ShimmeringSquareGridPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
