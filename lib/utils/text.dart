import 'dart:ui' as ui;

import 'package:flutter/material.dart';

extension TextStyleCast on TextStyle {
  ui.TextStyle asUiTextStyle() => ui.TextStyle(
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        textBaseline: textBaseline,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        background: background,
        foreground: foreground,
        shadows: shadows,
        fontFeatures: fontFeatures,
      );
}
