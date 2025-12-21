import 'package:flutter/material.dart';

class ShrinkSwapBarsIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final double borderRadius;

  const ShrinkSwapBarsIndicator({
    super.key,
    this.size = 60,
    this.color = Colors.black,
    this.duration = const Duration(seconds: 1),
    this.borderRadius = 0,
  });

  @override
  State<ShrinkSwapBarsIndicator> createState() => _ShrinkSwapBarsIndicatorState();
}

class _ShrinkSwapBarsIndicatorState extends State<ShrinkSwapBarsIndicator>
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
      height: widget.size * 0.8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return CustomPaint(
            painter: _ShrinkSwapBarsPainter(
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

class _ShrinkSwapBarsPainter extends CustomPainter {
  final double t;
  final Color color;
  final double size;
  final double borderRadius;

  _ShrinkSwapBarsPainter({
    required this.t,
    required this.color,
    required this.size,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final paint = Paint()..color = color;
    canvas.save();
    canvas.translate(0, size * 0.2);

    final barWidth = size * 0.10;
    final gap = barWidth;
    final totalWidth = barWidth * 3 + gap * 2;
    final startX = (size - totalWidth) / 2;
    final baseX = [startX, startX + barWidth + gap, startX + 2 * (barWidth + gap)];
    final rotatedX = [baseX[2], baseX[0], baseX[1]];

    final maxHeight = size * 0.55;
    final minHeight = maxHeight * 0.5;

    late List<double> heights;
    late List<double> xs;

    if (t < 1 / 3) {
      final p = t * 3;
      heights = [
        maxHeight - (maxHeight - minHeight) * p,
        maxHeight - (maxHeight - minHeight) * p,
        maxHeight - (maxHeight - minHeight) * p,
      ];

      xs = baseX;
    } else if (t < 2 / 3) {
      final p = (t - 1 / 3) * 3;
      heights = List.filled(3, minHeight);
      xs = List.generate(3, (i) => baseX[i] + (rotatedX[i] - baseX[i]) * p);
    } else {
      final p = (t - 2 / 3) * 3;
      heights = List.generate(3, (_) => minHeight + (maxHeight - minHeight) * p);
      xs = rotatedX;
    }

    for (int i = 0; i < 3; i++) {
      final isTopShrink = i == 0;

      final y = isTopShrink ? 0.0 : maxHeight - heights[i];

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(xs[i], y, barWidth, heights[i]),
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rect, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShrinkSwapBarsPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.borderRadius != borderRadius;
}
