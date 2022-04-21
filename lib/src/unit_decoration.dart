import 'package:flutter/material.dart';

enum UnitImageDirection {
  radialIn, // radial from border to center
  radialOut, // radial from center to border
  ltr, // left to right
  rtl, // right to left
  ttb, // top to bottom
  btt, // bottom to top
}

@immutable
class UnitImage {
  const UnitImage({
    required this.image,
    this.direction = UnitImageDirection.radialIn,
    this.onError,
    this.colorFilter,
    this.fit,
    this.alignment = Alignment.center,
    this.centerSlice,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.scale = 1.0,
    this.opacity = 1.0,
    this.filterQuality = FilterQuality.low,
    this.invertColors = false,
    this.isAntiAlias = false,
  });

  final ImageProvider image;
  final BoxFit? fit;
  final UnitImageDirection direction;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final double scale;
  final double opacity;
  final FilterQuality filterQuality;
  final bool invertColors;
  final bool isAntiAlias;
  final ImageErrorListener? onError;
  final ColorFilter? colorFilter;
}

@immutable
class UnitBorder {
  const UnitBorder({this.edge, this.arc});

  const UnitBorder.all(BorderSide side)
      : edge = side,
        arc = side;

  const UnitBorder.none()
      : edge = null,
        arc = null;

  final BorderSide? edge;
  final BorderSide? arc;
}

@immutable
class UnitDecoration {
  const UnitDecoration({
    this.color,
    this.image,
    this.border = defaultBorder,
    this.gradient,
    this.backgroundBlendMode,
  }) : assert(
          backgroundBlendMode == null || color != null || gradient != null,
          "backgroundBlendMode applies to UnitDecoration's background color or "
          'gradient, but no color or gradient was provided.',
        );

  final Color? color;
  final UnitImage? image;
  final UnitBorder border;
  final Gradient? gradient;
  final BlendMode? backgroundBlendMode;

  static const defaultBorder =
      UnitBorder.all(BorderSide(width: 5, color: Colors.white));
}
