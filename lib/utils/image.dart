import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

extension ToDartImage on Image {
  /// Obtient une [ui.Image] à partir d'une [Image].
  Future<ui.Image> toDartImage() async {
    var completer = Completer<ImageInfo>();

    image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((info, _) {
      completer.complete(info);
    }));

    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }
}
