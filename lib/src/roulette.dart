import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roulette/utils/helpers.dart';

import 'roulette_group.dart';
import 'roulette_style.dart';
import 'roulette_controller.dart';
import 'roulette_paint.dart';

/// This is an animatable roulette widget.
/// You need to present a [RouletteController] to control this widget.
class Roulette extends StatefulWidget {
  /// Creates a [Roulette] widget.
  const Roulette({
    Key? key,
    required RouletteGroup group,
    required RouletteController controller,
    RouletteStyle style = const RouletteStyle(),
  }) : this._internal(
          key: key,
          group: group,
          controller: controller,
          style: style,
        );

  /// Internal constructor that accepts an [onRotationChanged] callback.
  ///
  /// This is used by [TappableRoulette] to observe the current rotation
  /// angle without exposing rotation tracking on [RouletteController].
  const Roulette._internal({
    Key? key,
    required this.group,
    required this.controller,
    this.style = const RouletteStyle(),
    this.onRotationChanged,
  }) : super(key: key);

  /// Controls the roulette.
  final RouletteController controller;

  /// The display style of the roulette.
  final RouletteStyle style;

  /// The [RouletteGroup] to display.
  final RouletteGroup group;

  /// Called on every frame with the current rotation angle in radians.
  @internal
  final ValueChanged<double>? onRotationChanged;

  @override
  State<Roulette> createState() => RouletteState();
}

@visibleForTesting
class RouletteState extends State<Roulette>
    with SingleTickerProviderStateMixin {
  final _imageInfoNotifier = ValueNotifier(<int, ImageInfo>{});

  @visibleForTesting
  final rotateAnimation =
      ValueNotifier<Animation<double>>(AlwaysStoppedAnimation(0));

  late final AnimationController _animationController;
  StreamSubscription? _subscription;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    _subscription = widget.controller.onEvent.listen(_onAnimationEvent);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _updateImageInfo();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Roulette oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      _updateImageInfo();
    }

    if (oldWidget.controller != widget.controller) {
      _subscription?.cancel();
      _subscription = widget.controller.onEvent.listen(_onAnimationEvent);
    }
  }

  void _onAnimationEvent(RouletteEvent event) {
    if (event is RouletteRollEvent) {
      _handleRoll(event);
    } else if (event is RouletteStopEvent) {
      _handleStop();
    } else if (event is RouletteResetEvent) {
      _handleReset();
    }
  }

  void _reportEvent(RouletteCallbackEvent e) {
    widget.controller.invokeCallback(e);
  }

  void _handleRoll(RouletteRollEvent event) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    final rotate = calculateEndRotate(
      widget.group,
      event.targetIndex,
      event.clockwise,
      event.minRotateCircles,
      offset: event.offset,
    );

    final initialValue = rotateAnimation.value.value;
    final animationConfig = event.animationConfig;

    TickerFuture tickerFuture;

    if (animationConfig is PhysicsAnimationConfig) {
      rotateAnimation.value = makeAnimation(
        _animationController,
        rotate,
        null,
        initialValue: initialValue,
      );
      final simulation =
          NormalizedFrictionSimulation(drag: animationConfig.drag);
      tickerFuture = _animationController.animateWith(simulation);
    } else {
      final curveConfig = animationConfig is CurveAnimationConfig
          ? animationConfig
          : const CurveAnimationConfig();
      rotateAnimation.value = makeAnimation(
        _animationController,
        rotate,
        curveConfig.curve,
        initialValue: initialValue,
      );
      _animationController.duration = curveConfig.duration;
      tickerFuture = _animationController.forward(from: 0);
    }

    tickerFuture.orCancel
        .then((_) => _reportEvent(OnRollEndEvent(event)))
        .catchError((_) => _reportEvent(OnRollCancelledEvent(event)));
  }

  void _handleStop() {
    _animationController.stop();
  }

  void _handleReset() {
    _animationController.reset();
  }

  void _updateImageInfo() {
    final units = widget.group.units;
    if (units.isEmpty) {
      _imageInfoNotifier.value.forEach((_, value) => value.dispose());
      _imageInfoNotifier.value = {};
      return;
    }

    final imageConfiguration = createLocalImageConfiguration(context);
    for (int i = 0; i < units.length; i++) {
      final provider = units[i].image;
      if (provider != null) {
        final stream = provider.resolve(imageConfiguration);
        stream.addListener(
          ImageStreamListener(
            (image, synchronousCall) {
              WidgetsBinding.instance.endOfFrame.then((_) {
                _replaceImage(i, image);
              });
            },
            onError: (exception, stackTrace) {
              assert(() {
                log('image load error',
                    error: exception, stackTrace: stackTrace);
                WidgetsBinding.instance.endOfFrame.then((_) {
                  _replaceImage(i, _createErrorImage(const Size(400, 400)));
                });
                return true;
              }());
            },
          ),
        );
      }
    }
  }

  void _replaceImage(int i, ImageInfo imageInfo) {
    final imageInfoLookup = _imageInfoNotifier.value;
    imageInfoLookup[i]?.dispose();
    if (mounted) {
      _imageInfoNotifier.value = {
        ...imageInfoLookup,
        i: imageInfo,
      };
    }
  }

  @override
  void dispose() {
    final imageInfoLookup = _imageInfoNotifier.value;
    imageInfoLookup.forEach((_, value) => value.dispose());
    imageInfoLookup.clear();
    _imageInfoNotifier.dispose();
    _subscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _imageInfoNotifier,
      builder: (context, Map<int, ImageInfo> images, _) {
        return ValueListenableBuilder(
          valueListenable: rotateAnimation,
          builder: (context, Animation<double> animation, _) {
            widget.onRotationChanged?.call(animation.value);
            return RoulettePaint(
              key: widget.key,
              animation: animation,
              style: widget.style,
              group: widget.group,
              imageInfos: images,
            );
          },
        );
      },
    );
  }
}

ImageInfo _createErrorImage(Size size) {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final paint = Paint();

  paint.color = Colors.red[900]!;
  paint.style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  textPainter.text = TextSpan(
    text: '!ERROR!',
    style: TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: math.min(size.width, size.height) * 0.15,
      color: Colors.white,
    ),
  );
  textPainter.layout(maxWidth: size.width);
  textPainter.paint(
    canvas,
    Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 5,
    ),
  );

  final picture = recorder.endRecording();
  return ImageInfo(
    image: picture.toImageSync(
      size.width.toInt(),
      size.height.toInt(),
    ),
  );
}

/// A callback invoked when a sector of the roulette is tapped.
///
/// [index] is the 0-based index of the tapped [RouletteUnit] within the
/// [RouletteGroup].
typedef SectorTapCallback = void Function(int index);

/// A tappable variant of [Roulette].
///
/// This widget wraps [Roulette] with hit-testing so that taps on the wheel
/// report back which sector was tapped via [onTap]. The hit-test respects
/// the current rotation of the wheel and variable sector sizes due to
/// differing [RouletteUnit.weight] values.
///
/// Taps that land outside the wheel circle or inside the center sticker
/// (controlled by [RouletteStyle.centerStickSizePercent]) are ignored.
class TappableRoulette extends StatefulWidget {
  const TappableRoulette({
    Key? key,
    required this.group,
    required this.controller,
    this.style = const RouletteStyle(),
    this.onTap,
  }) : super(key: key);

  /// Controls the roulette animation.
  final RouletteController controller;

  /// The display style of the roulette.
  final RouletteStyle style;

  /// The [RouletteGroup] to display.
  final RouletteGroup group;

  /// Called when a sector is tapped. The callback receives the 0-based
  /// index of the tapped sector.
  final SectorTapCallback? onTap;

  @override
  State<TappableRoulette> createState() => _TappableRouletteState();
}

class _TappableRouletteState extends State<TappableRoulette> {
  double _currentRotation = 0;

  void _onRotationChanged(double rotation) {
    _currentRotation = rotation;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The Roulette uses AspectRatio(1.0), so width == height.
        final size = Size(constraints.maxWidth, constraints.maxWidth);
        return GestureDetector(
          onTapUp: (details) => _handleTapUp(details, size),
          child: Roulette._internal(
            group: widget.group,
            controller: widget.controller,
            style: widget.style,
            onRotationChanged: _onRotationChanged,
          ),
        );
      },
    );
  }

  void _handleTapUp(TapUpDetails details, Size size) {
    final callback = widget.onTap;
    if (callback == null) return;

    final index = hitTestSector(
      size: size,
      group: widget.group,
      rotation: _currentRotation,
      localPosition: details.localPosition,
      centerStickerPercent: widget.style.centerStickSizePercent,
    );

    if (index != null) {
      callback(index);
    }
  }
}
