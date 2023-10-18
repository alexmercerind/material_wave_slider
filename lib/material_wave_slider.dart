import 'dart:math';
import 'package:flutter/material.dart';

/// {@template sine_painter}
///
/// SinePainter
/// -----------
/// A [CustomPainter] to draw a sine wave.
///
/// {@endtemplate}
class SinePainter extends CustomPainter {
  /// The color of the wave.
  final Color color;

  /// The delta used to calculate the [sin] value when drawing the path.
  final double delta;

  /// The phase of the wave.
  final double phase;

  /// The amplitude of the wave.
  final double amplitude;

  /// The stroke-cap of the wave.
  final StrokeCap strokeCap;

  /// The stroke-width of the wave.
  final double strokeWidth;

  /// {@macro sine_painter}
  const SinePainter({
    required this.color,
    this.delta = 2.0,
    this.phase = 0.0,
    this.amplitude = 16.0,
    this.strokeCap = StrokeCap.round,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = strokeCap
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0.0, size.height / 2.0);
    for (double x = 0.0; x <= size.width; x += delta) {
      path.lineTo(
        x,
        sin(x / size.width * 2 * pi + phase) * amplitude + size.height / 2.0,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
