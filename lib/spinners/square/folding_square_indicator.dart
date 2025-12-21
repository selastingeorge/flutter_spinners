import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A folding square loading animation widget with 3D perspective using CustomPainter
class FoldingSquareIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const FoldingSquareIndicator({
    super.key,
    this.size = 40.0,
    this.color = const Color(0xFF333333),
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<FoldingSquareIndicator> createState() => _FoldingSquareIndicatorState();
}

class _FoldingSquareIndicatorState extends State<FoldingSquareIndicator>
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
        builder: (_, __) {
          return CustomPaint(
            painter: _FoldingSquarePainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _FoldingSquarePainter extends CustomPainter {
  final double progress;
  final Color color;

  static const double _gridFraction = 0.85;
  static const double _perspective = 0.009;
  static const double _overdraw = 0.6;

  _FoldingSquarePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = (size.width * _gridFraction).floorToDouble();
    final cubeSize = gridSize / 2;
    final offset = (size.width - gridSize) / 2;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi / 4);
    canvas.translate(-size.width / 2, -size.height / 2);

    _drawCube(canvas, Offset(offset, offset), cubeSize, 0.0, 0.0);
    _drawCube(canvas, Offset(offset + cubeSize, offset), cubeSize, math.pi / 2, 0.3);
    _drawCube(canvas, Offset(offset, offset + cubeSize), cubeSize, 3 * math.pi / 2, 0.9);
    _drawCube(canvas, Offset(offset + cubeSize, offset + cubeSize), cubeSize, math.pi, 0.6);

    canvas.restore();
  }

  void _drawCube(
      Canvas canvas,
      Offset position,
      double size,
      double rotation,
      double delay,
      ) {
    canvas.save();

    canvas.translate(position.dx + size / 2, position.dy + size / 2);
    canvas.rotate(rotation);
    canvas.translate(-size / 2, -size / 2);

    final normalizedDelay = delay / 2.4;
    double t = (progress - normalizedDelay) % 1.0;
    if (t < 0) t += 1.0;

    final anim = _getAnimationData(t);
    if (anim.opacity <= 0) {
      canvas.restore();
      return;
    }

    final matrix = _create3DMatrix(anim.rotateX, anim.rotateY, size);

    final corners = [
      Offset(-_overdraw, -_overdraw),
      Offset(size + _overdraw, -_overdraw),
      Offset(size + _overdraw, size + _overdraw),
      Offset(-_overdraw, size + _overdraw),
    ];

    final transformed = corners.map((p) => _transformPoint(p, matrix)).toList();

    final path = Path()
      ..moveTo(transformed[0].dx, transformed[0].dy)
      ..lineTo(transformed[1].dx, transformed[1].dy)
      ..lineTo(transformed[2].dx, transformed[2].dy)
      ..lineTo(transformed[3].dx, transformed[3].dy)
      ..close();

    final paint = Paint()
      ..color = color.withAlpha((anim.opacity * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  Matrix4 _create3DMatrix(double rx, double ry, double size) {
    final m = Matrix4.identity()..setEntry(3, 2, _perspective);

    m.multiply(Matrix4.translationValues(size, size, 0));
    if (rx != 0) m.rotateX(rx);
    if (ry != 0) m.rotateY(ry);
    m.multiply(Matrix4.translationValues(-size, -size, 0));

    return m;
  }

  Offset _transformPoint(Offset p, Matrix4 m) {
    final s = m.storage;
    final x = p.dx;
    final y = p.dy;

    final tx = s[0] * x + s[4] * y + s[12];
    final ty = s[1] * x + s[5] * y + s[13];
    final tw = s[3] * x + s[7] * y + s[15];

    final invW = tw != 0 ? 1 / tw : 1;
    return Offset(tx * invW, ty * invW);
  }

  _AnimData _getAnimationData(double p) {
    if (p < 0.10) {
      return const _AnimData(0, -math.pi, 0);
    } else if (p < 0.25) {
      final t = (p - 0.10) / 0.15;
      return _AnimData(t, -math.pi * (1 - t), 0);
    } else if (p < 0.75) {
      return const _AnimData(1, 0, 0);
    } else if (p < 0.90) {
      final t = (p - 0.75) / 0.15;
      return _AnimData(1 - t, 0, math.pi * t);
    } else {
      return const _AnimData(0, 0, math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant _FoldingSquarePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _AnimData {
  final double opacity;
  final double rotateX;
  final double rotateY;

  const _AnimData(this.opacity, this.rotateX, this.rotateY);
}
