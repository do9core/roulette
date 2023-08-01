// Partly stolen from https://gist.github.com/pskink/aa0b0c80af9a986619845625c0e87a67
// By @pksink

import 'dart:math';

import 'package:flutter/material.dart';

/// Functional equivalent of [RSTransform] in [Matrix4] world,
/// check [RSTransform.fromComponents] for more info about the parameters.
Matrix4 composeMatrix({
  double scale = 1,
  double rotation = 0,
  double translateX = 0,
  double translateY = 0,
  double anchorX = 0,
  double anchorY = 0,
}) {
  final double c = cos(rotation) * scale;
  final double s = sin(rotation) * scale;
  final double dx = translateX - c * anchorX + s * anchorY;
  final double dy = translateY - s * anchorX - c * anchorY;

  //  ..[0]  = c       # x scale
  //  ..[1]  = s       # y skew
  //  ..[4]  = -s      # x skew
  //  ..[5]  = c       # y scale
  //  ..[10] = 1       # diagonal "one"
  //  ..[12] = dx      # x translation
  //  ..[13] = dy      # y translation
  //  ..[15] = 1       # diagonal "one"
  return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
}

/// Helper function that uses [Offset] as [translate] and [anchor].
/// See [composeMatrix] for more info.
Matrix4 composeMatrixFromOffsets({
  double scale = 1,
  double rotation = 0,
  Offset translate = Offset.zero,
  Offset anchor = Offset.zero,
}) =>
    composeMatrix(
      scale: scale,
      rotation: rotation,
      translateX: translate.dx,
      translateY: translate.dy,
      anchorX: anchor.dx,
      anchorY: anchor.dy,
    );
