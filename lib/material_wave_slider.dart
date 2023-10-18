import 'dart:math';
import 'package:flutter/material.dart';

/// {@template animated_sine}
///
/// AnimatedSine
/// ------------
/// Animated sine wave sliding horizontally from right to left.
///
/// {@endtemplate}
class AnimatedSine extends StatefulWidget {
  /// The [SinePainter] to draw the sine wave.
  final SinePainter painter;

  /// The width of the wave.
  final double width;

  /// The height of the wave.
  final double height;

  /// The velocity of the wave.
  final double velocity;

  /// The number of times the wave segment should be drawn.
  final int repeat;

  const AnimatedSine({
    Key? key,
    required this.painter,
    required this.width,
    required this.height,
    this.velocity = 64.0,
    this.repeat = 3,
  }) : super(key: key);

  @override
  State<AnimatedSine> createState() => AnimatedSineState();
}

class AnimatedSineState extends State<AnimatedSine> {
  final PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.animateTo(
        widget.velocity * const Duration(days: 1024).inSeconds,
        duration: const Duration(days: 1024),
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      painter: widget.painter,
      size: Size(
        widget.height,
        widget.height,
      ),
    );
    return Stack(
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: widget.height * widget.repeat,
              height: widget.height,
              child: PageView.builder(
                controller: controller,
                pageSnapping: false,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, _) => Row(
                  children: [
                    for (int i = 0; i < widget.repeat; i++) paint,
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: ColoredBox(color: Colors.transparent),
        ),
      ],
    );
  }
}

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
    this.phase = pi,
    this.amplitude = 16.0,
    this.strokeCap = StrokeCap.butt,
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
    for (double x = 0.0; x <= size.width + delta; x += delta) {
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
