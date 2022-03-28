import 'package:flutter/widgets.dart';

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
class UnitDecoration {
  final Color? color;
  final UnitImage? image;
  final BoxBorder? border;
  final Gradient? gradient;
  final BlendMode? backgroundBlendMode;

  const UnitDecoration({
    this.color,
    this.image,
    this.border,
    this.gradient,
    this.backgroundBlendMode,
  }) : assert(
          backgroundBlendMode == null || color != null || gradient != null,
          "backgroundBlendMode applies to ZDecoration's background color or "
          'gradient, but no color or gradient was provided.',
        );
}
