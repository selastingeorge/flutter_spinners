import 'package:flutter/material.dart';
import 'dart:math' as math;

/// An animated loading indicator with four squares that fold in and out with 3D perspective.
///
/// Four squares arranged in a 2x2 grid (rotated 45 degrees) each fold independently
/// with staggered timing. Each square rotates on the X-axis to fold down flat (becoming
/// invisible), then rotates on the Y-axis to fold back up, creating a complex 3D
/// folding animation with perspective depth.
///
/// Example:
/// ```dart
/// FoldingSquareIndicator(
///   size: 50.0,
///   color: Colors.blue,
///   duration: Duration(milliseconds: 3000),
/// )
/// ```
class FoldingSquareIndicator extends StatefulWidget {
  /// The width and height of the entire indicator (creates a square container).
  ///
  /// Defaults to 40.0.
  final double size;

  /// The color of the squares.
  ///
  /// Defaults to Color(0xFF333333).
  final Color color;

  /// The duration of one complete animation cycle (all squares fold).
  ///
  /// Defaults to 2400 milliseconds.
  final Duration duration;

  /// Creates a folding square loading indicator.
  ///
  /// [size] - The width and height of the indicator (default: 40.0)
  /// [color] - The color of the squares (default: Color(0xFF333333))
  /// [duration] - Animation cycle duration (default: 2400ms)
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
    // Initialize and start the repeating animation
    _controller = AnimationController(vsync: this, duration: widget.duration)
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

/// Custom painter that draws four squares with independent 3D folding animations.
///
/// [progress] - Animation progress value from 0.0 to 1.0
/// [color] - Color of the squares
class _FoldingSquarePainter extends CustomPainter {
  /// Animation progress value from 0.0 to 1.0.
  final double progress;

  /// Color of the squares.
  final Color color;

  /// Grid size as fraction of total size (85%).
  static const double _gridFraction = 0.85;

  /// Perspective depth for 3D effect.
  static const double _perspective = 0.009;

  /// Overdraw amount to prevent gaps during rotation.
  static const double _overdraw = 0.6;

  _FoldingSquarePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate 2x2 grid dimensions
    final gridSize = (size.width * _gridFraction).floorToDouble();
    final cubeSize = gridSize / 2; // Each square is half the grid
    final offset = (size.width - gridSize) / 2; // Center the grid

    // Rotate entire grid by 45 degrees for diamond orientation
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(math.pi / 4); // 45 degree rotation
    canvas.translate(-size.width / 2, -size.height / 2);

    // Draw four squares with different rotations and timing delays
    _drawCube(
      canvas,
      Offset(offset, offset),
      cubeSize,
      0.0,
      0.0,
    ); // Top square, no rotation, no delay
    _drawCube(
      canvas,
      Offset(offset + cubeSize, offset),
      cubeSize,
      math.pi / 2,
      0.3,
    ); // Right square, 90° rotation, 0.3s delay
    _drawCube(
      canvas,
      Offset(offset, offset + cubeSize),
      cubeSize,
      3 * math.pi / 2,
      0.9,
    ); // Left square, 270° rotation, 0.9s delay
    _drawCube(
      canvas,
      Offset(offset + cubeSize, offset + cubeSize),
      cubeSize,
      math.pi,
      0.6,
    ); // Bottom square, 180° rotation, 0.6s delay

    canvas.restore();
  }

  /// Draws a single square with 3D folding animation.
  ///
  /// [canvas] - The canvas to draw on
  /// [position] - Top-left position of the square
  /// [size] - Size of the square
  /// [rotation] - Static Z-axis rotation for positioning
  /// [delay] - Animation delay in seconds
  void _drawCube(
    Canvas canvas,
    Offset position,
    double size,
    double rotation,
    double delay,
  ) {
    canvas.save();

    // Apply rotation around square's center
    canvas.translate(position.dx + size / 2, position.dy + size / 2);
    canvas.rotate(rotation);
    canvas.translate(-size / 2, -size / 2);

    // Normalize delay to 0.0-1.0 range based on 2.4 second base cycle
    final normalizedDelay = delay / 2.4;

    // Calculate animation progress with delay offset
    double t = (progress - normalizedDelay) % 1.0;
    if (t < 0) t += 1.0;

    // Get animation data (opacity and rotation angles) for current time
    final anim = _getAnimationData(t);

    // Skip drawing if fully transparent
    if (anim.opacity <= 0) {
      canvas.restore();
      return;
    }

    // Create 3D transformation matrix
    final matrix = _create3DMatrix(anim.rotateX, anim.rotateY, size);

    // Define square corners with overdraw to prevent gaps
    final corners = [
      Offset(-_overdraw, -_overdraw),
      Offset(size + _overdraw, -_overdraw),
      Offset(size + _overdraw, size + _overdraw),
      Offset(-_overdraw, size + _overdraw),
    ];

    // Transform corners to 3D space
    final transformed = corners.map((p) => _transformPoint(p, matrix)).toList();

    // Create path from transformed corners
    final path = Path()
      ..moveTo(transformed[0].dx, transformed[0].dy)
      ..lineTo(transformed[1].dx, transformed[1].dy)
      ..lineTo(transformed[2].dx, transformed[2].dy)
      ..lineTo(transformed[3].dx, transformed[3].dy)
      ..close();

    // Draw with opacity based on animation state
    final paint = Paint()
      ..color = color.withAlpha((anim.opacity * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  /// Creates a 3D transformation matrix with perspective and rotations.
  ///
  /// [rx] - X-axis rotation (horizontal fold)
  /// [ry] - Y-axis rotation (vertical fold)
  /// [size] - Size of the square (for rotation center)
  Matrix4 _create3DMatrix(double rx, double ry, double size) {
    final m = Matrix4.identity()..setEntry(3, 2, _perspective);

    // Translate to center, rotate, translate back
    m.multiply(Matrix4.translationValues(size, size, 0));
    if (rx != 0) m.rotateX(rx); // Horizontal axis rotation (fold down)
    if (ry != 0) m.rotateY(ry); // Vertical axis rotation (fold up)
    m.multiply(Matrix4.translationValues(-size, -size, 0));

    return m;
  }

  /// Transforms a 2D point through a 3D matrix with perspective division.
  ///
  /// [p] - 2D point to transform
  /// [m] - 3D transformation matrix
  Offset _transformPoint(Offset p, Matrix4 m) {
    final s = m.storage;
    final x = p.dx;
    final y = p.dy;

    // Apply matrix transformation
    final tx = s[0] * x + s[4] * y + s[12];
    final ty = s[1] * x + s[5] * y + s[13];
    final tw = s[3] * x + s[7] * y + s[15];

    // Perspective division
    final invW = tw != 0 ? 1 / tw : 1;
    return Offset(tx * invW, ty * invW);
  }

  /// Calculates animation state (opacity and rotations) for a given time.
  ///
  /// Timeline:
  /// - 0.00-0.10: Invisible (folded flat)
  /// - 0.10-0.25: Fold down on X-axis (becomes visible)
  /// - 0.25-0.75: Fully visible (no rotation)
  /// - 0.75-0.90: Fold up on Y-axis (becomes invisible)
  /// - 0.90-1.00: Invisible (folded flat)
  ///
  /// [p] - Progress value from 0.0 to 1.0
  _AnimData _getAnimationData(double p) {
    if (p < 0.10) {
      // Hidden phase: invisible, rotated on X-axis
      return const _AnimData(0, -math.pi, 0);
    } else if (p < 0.25) {
      // Unfold phase: fade in while rotating from -π to 0 on X-axis
      final t = (p - 0.10) / 0.15;
      return _AnimData(t, -math.pi * (1 - t), 0);
    } else if (p < 0.75) {
      // Visible phase: fully opaque, no rotation
      return const _AnimData(1, 0, 0);
    } else if (p < 0.90) {
      // Fold phase: fade out while rotating from 0 to π on Y-axis
      final t = (p - 0.75) / 0.15;
      return _AnimData(1 - t, 0, math.pi * t);
    } else {
      // Hidden phase: invisible, rotated on Y-axis
      return const _AnimData(0, 0, math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant _FoldingSquarePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Data class for animation state at a given time.
///
/// [opacity] - Opacity value from 0.0 (invisible) to 1.0 (fully visible)
/// [rotateX] - X-axis rotation in radians (horizontal fold)
/// [rotateY] - Y-axis rotation in radians (vertical fold)
class _AnimData {
  final double opacity;
  final double rotateX;
  final double rotateY;

  const _AnimData(this.opacity, this.rotateX, this.rotateY);
}
