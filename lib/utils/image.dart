import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

extension ToDartImage on Image {
  /// Obtient une [ui.Image] à partir d'une [Image].
  /// [onError] est appelé si une erreur survient lors de la conversion et permet de renvoyer une image par défaut.
  Future<ui.Image> toDartImage({Image Function()? onError}) async {
    var completer = Completer<ImageInfo>();

    try {
      image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((info, _) {
        completer.complete(info);
      }));
    } catch (e) {
      completer.completeError(AssertionError(e.toString()));
      if (onError != null) {
        return onError().toDartImage();
      }
      rethrow;
    }

    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }
}
