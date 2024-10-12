import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:roulette/utils/helpers.dart';

import 'roulette_group.dart';
import 'roulette_style.dart';
import 'roulette_controller.dart';
import 'roulette_paint.dart';

/// This is an animatable roulette widget.
/// You need to present a [RouletteController] to controll this widget.
class Roulette extends StatefulWidget {
  const Roulette({
    Key? key,
    required this.group,
    required this.controller,
    this.style = const RouletteStyle(),
  }) : super(key: key);

  /// Controls the roulette.
  final RouletteController controller;

  /// The display style of the roulette.
  final RouletteStyle style;

  /// The [RouletteGroup] to display.
  final RouletteGroup group;

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

  void _handleRoll(RouletteRollEvent event) {
    final rotate = calculateEndRotate(
      widget.group,
      event.targetIndex,
      event.clockwise,
      event.minRotateCircles,
      offset: event.offset,
    );
    _animationController.duration = event.duration;
    final animation = makeAnimation(_animationController, rotate, event.curve);
    rotateAnimation.value = animation;
    _animationController.forward();
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
