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

  /// The duration of the transition.
  final Duration transitionDuration;

  /// Whether to show transition animation upon value change.
  final bool transitionOnChange;

  /// Builder that may be used to customize the default thumb.
  final Widget Function(BuildContext)? thumbBuilder;

  // --------------------------------------------------
  const MaterialWaveSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    required this.onChanged,
    this.height = 48.0,
    this.amplitude,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.transitionOnChange = true,
    this.thumbBuilder,
  }) : super(key: key);

  @override
  State<MaterialWaveSlider> createState() => MaterialWaveSliderState();
}

class MaterialWaveSliderState extends State<MaterialWaveSlider> {
  double get _amplitude => widget.amplitude ?? (widget.height / 12.0);
  double get _percent =>
      ((_current ?? widget.value) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double? _current;
  bool _running = true;

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

  void onPointerDown(PointerDownEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        _running = false;
        _current = e.localPosition.dx /
            constraints.maxWidth *
            (widget.max - widget.min);
      });
    }
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        _running = false;
        _current = e.localPosition.dx /
            constraints.maxWidth *
            (widget.max - widget.min);
      });
    }
  }

  void onPointerUp(PointerUpEvent e, BoxConstraints constraints) {
    if (widget.onChanged != null) {
      setState(() {
        _running = true;
        _current = null;
      });
      widget.onChanged?.call(
        e.localPosition.dx / constraints.maxWidth * (widget.max - widget.min),
      );
    }
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
          onPointerDown: (e) => onPointerDown(e, constraints),
          onPointerMove: (e) => onPointerMove(e, constraints),
          onPointerUp: (e) => onPointerUp(e, constraints),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSlide(
                  width: constraints.maxWidth * _percent - 6.0,
                  height: widget.height,
                  repeat: (constraints.maxWidth / widget.height).ceil(),
                  velocity: widget.height / 48.0 * 24.0,
                  builder: (context) => TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _amplitude,
                      end: _running ? _amplitude : 0.0,
                    ),
                    duration: widget.transitionDuration,
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      return CustomPaint(
                        painter: SinePainter(
                          amplitude: value,
                          strokeWidth: activeTrackHeight,
                          delta: widget.height / (100.0 / 3.0),
                          color: activeTrackColor,
                        ),
                        size: Size(
                          widget.height,
                          widget.height,
                        ),
                      );
                    },
                  ),
                ),
                widget.thumbBuilder?.call(context) ??
                    Container(
                      width: 6.0,
                      height: widget.height * 0.75,
                      decoration: BoxDecoration(
                        color: thumbColor,
                        borderRadius: BorderRadius.circular(3.0),
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
class AnimatedSlide extends StatefulWidget {
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
  State<AnimatedSlide> createState() => AnimatedSlideState();
}

class AnimatedSlideState extends State<AnimatedSlide> {
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
    // TODO(alexmercerind): Possibly use snapshot after first render.
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
              child: ListView.builder(
                cacheExtent: 0.0,
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, _) => Row(
                  children: [
                    for (int i = 0; i < widget.repeat; i++)
                      widget.builder.call(context),
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
