import 'dart:math';
import 'package:flutter/material.dart';

/// {@template material_wave_slider}
///
/// MaterialWaveSlider
/// ------------------
/// Material Design 3 / Material You inspired waveform slider.
///
/// [SliderTheme] & [SliderThemeData] may be used to customize the visual appearance of the slider.
///
/// {@endtemplate}
class MaterialWaveSlider extends StatefulWidget {
  // --------------------------------------------------

  /// The current value of the slider.
  final double value;

  /// The minimum value the user can select.
  final double min;

  /// The maximum value the user can select.
  final double max;

  /// Called during a drag when the user is selecting a new value for the slider by dragging.
  final void Function(double)? onChanged;

  // --------------------------------------------------

  /// The height of the slider.
  final double height;

  /// The amplitude of the wave.
  final double? amplitude;

  /// The velocity of the wave.
  final double velocity;

  /// The [Curve] of the amplitude change transition.
  final Curve transitionCurve;

  /// The [Duration] of the amplitude change transition.
  final Duration transitionDuration;

  /// Whether to show amplitude change transition upon value change.
  final bool transitionOnChange;

  /// Builder that may be used to customize the default thumb.
  final Widget Function(BuildContext)? thumbBuilder;

  /// The width of the default thumb.
  final double thumbWidth;

  // --------------------------------------------------

  /// {@macro material_wave_slider}
  const MaterialWaveSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.height = 48.0,
    this.velocity = 2400.0,
    this.amplitude,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionOnChange = true,
    this.thumbBuilder,
    this.thumbWidth = 6.0,
  }) : super(key: key);

  @override
  State<MaterialWaveSlider> createState() => MaterialWaveSliderState();
}

class MaterialWaveSliderState extends State<MaterialWaveSlider>
    with SingleTickerProviderStateMixin {
  double get _amplitude => widget.amplitude ?? (widget.height / 12.0);
  double get _percent =>
      ((_current ?? widget.value) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double? _current;
  bool _running = true;

  // [AnimationController] for animating the phase change of the each wave segment.
  // This makes the wave appear to be moving.
  late final AnimationController _animation = AnimationController(
    vsync: this,
    lowerBound: 0.0,
    upperBound: 2 * pi,
    duration: Duration(
      milliseconds: widget.velocity.round(),
    ),
  );

  void pause() {
    setState(() {
      _running = false;
    });
  }

  void resume() {
    setState(() {
      _running = true;
    });
  }

  void _onPointerDown(PointerDownEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange) {
          _running = false;
        }
        _current = e.localPosition.dx /
            constraints.maxWidth *
            (widget.max - widget.min);
      });
    }
  }

  void _onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange) {
          _running = false;
        }
        _current = e.localPosition.dx /
            constraints.maxWidth *
            (widget.max - widget.min);
      });
    }
  }

  void _onPointerUp(PointerUpEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        if (widget.transitionOnChange) {
          _running = true;
        }
        _current = null;
      });
      final value =
          e.localPosition.dx / constraints.maxWidth * (widget.max - widget.min);
      widget.onChanged?.call(value.clamp(widget.min, widget.max));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animation.repeat();
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sliderTheme = SliderTheme.of(context);

    final trackHeight = sliderTheme.trackHeight ?? 2.0;
    final activeTrackHeight = trackHeight * 1.0;
    final inactiveTrackHeight = trackHeight * 1.0;

    // https://m3.material.io/components/sliders/specs
    final activeTrackColor = widget.onChanged == null
        ? (sliderTheme.disabledActiveTrackColor ??
            theme.colorScheme.onSurface.withOpacity(0.38))
        : (sliderTheme.activeTrackColor ?? theme.colorScheme.primary);
    final inactiveTrackColor = widget.onChanged == null
        ? (sliderTheme.activeTrackColor ??
            theme.colorScheme.onSurface.withOpacity(0.12))
        : (sliderTheme.activeTrackColor ?? theme.colorScheme.primaryContainer);
    final thumbColor = widget.onChanged == null
        ? (sliderTheme.disabledActiveTrackColor ??
            theme.colorScheme.onSurface.withOpacity(0.38))
        : (sliderTheme.activeTrackColor ?? theme.colorScheme.primary);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          onPointerDown: (e) => _onPointerDown(e, constraints),
          onPointerMove: (e) => _onPointerMove(e, constraints),
          onPointerUp: (e) => _onPointerUp(e, constraints),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: (constraints.maxWidth * _percent).clamp(
                    widget.thumbWidth,
                    constraints.maxWidth,
                  ),
                  height: widget.height,
                  child: Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth <= 0.0) {
                              return const SizedBox.shrink();
                            }
                            return AnimatedSlide(
                              width: constraints.maxWidth,
                              height: widget.height,
                              repeat:
                                  (constraints.maxWidth / widget.height).ceil(),
                              velocity: widget.height / 48.0 * 24.0,
                              builder: (context) =>
                                  // [TweenAnimationBuilder] for animating the amplitude change of the each wave segment.
                                  TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: _running ? _amplitude : 0.0,
                                  end: _running ? _amplitude : 0.0,
                                ),
                                curve: widget.transitionCurve,
                                duration: widget.transitionDuration,
                                builder: (context, value, _) {
                                  return AnimatedBuilder(
                                    animation: _animation,
                                    builder: (context, _) => CustomPaint(
                                      painter: SinePainter(
                                        amplitude: value,
                                        phase: _animation.value,
                                        strokeWidth: activeTrackHeight,
                                        delta: widget.height / 25.0,
                                        color: activeTrackColor,
                                      ),
                                      size: Size(
                                        widget.height,
                                        widget.height,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      widget.thumbBuilder?.call(context) ??
                          Container(
                            width: widget.thumbWidth,
                            height: widget.height * 0.75,
                            decoration: BoxDecoration(
                              color: thumbColor,
                              borderRadius: BorderRadius.circular(
                                widget.thumbWidth / 2.0,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: inactiveTrackColor,
                    height: inactiveTrackHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// {@template animated_slide}
///
/// AnimatedSlide
/// ------------
/// Animated sliding horizontally from right to left.
///
/// {@endtemplate}
class AnimatedSlide extends StatelessWidget {
  /// The [CustomPaint] to draw the sine wave.
  final Widget Function(BuildContext) builder;

  /// The width of the wave.
  final double width;

  /// The height of the wave.
  final double height;

  /// The velocity of the wave.
  final double velocity;

  /// The number of times the wave segment should be drawn.
  final int repeat;

  /// {@macro animated_sine}
  const AnimatedSlide({
    Key? key,
    required this.builder,
    required this.width,
    required this.height,
    this.velocity = 64.0,
    this.repeat = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: height * repeat,
              height: height,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (int i = 0; i < repeat; i++) builder.call(context),
                ],
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
    for (double x = 0.0; x <= size.width + delta; x += delta) {
      final y =
          size.height / 2.0 + amplitude * sin(x / size.width * 2 * pi + phase);
      if (x == 0.0) {
        path.moveTo(x, y);
      }
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
