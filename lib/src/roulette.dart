/// Copyright 2021 do9core
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'roulette_style.dart';
import 'roulette_controller.dart';
import 'roulette_paint.dart';

/// This is an animatable roulette widget.
/// You need to present a [RouletteController] to controll this widget.
class Roulette extends StatefulWidget {
  const Roulette({
    Key? key,
    required this.controller,
    this.style = const RouletteStyle(),
  }) : super(key: key);

  /// Controls the roulette.
  final RouletteController controller;

  /// The display style of the roulette.
  final RouletteStyle style;

  @override
  State<Roulette> createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> {
  final _imageInfoNotifier = ValueNotifier(<int, ImageInfo>{});

  @override
  void initState() {
    widget.controller.addListener(_updateImageInfo);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _updateImageInfo();
    super.didChangeDependencies();
  }

  void _updateImageInfo() {
    final units = widget.controller.group?.units;
    if (units == null || units.isEmpty) {
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
    widget.controller.removeListener(_updateImageInfo);
    final imageInfoLookup = _imageInfoNotifier.value;
    imageInfoLookup.forEach((_, value) => value.dispose());
    imageInfoLookup.clear();
    _imageInfoNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.controller, _imageInfoNotifier]),
      builder: (context, child) {
        return RoulettePaint(
          key: widget.key,
          animation: widget.controller.animation,
          style: widget.style,
          group: widget.controller.group!,
          imageInfos: _imageInfoNotifier.value,
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
