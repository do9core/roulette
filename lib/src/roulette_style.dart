import 'package:flutter/material.dart';

/// Describe the render style of roulette.
class RouletteStyle {
  /// Default section text style
  static const defaultTextStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: "Sans",
  );

  /// Default section icon style
  static const defaultIconStyle = TextStyle(
    fontSize: 40,
    color: Colors.white,
  );

  const RouletteStyle({
    this.dividerThickness = 5,
    this.dividerColor = Colors.white,
    this.centerStickerColor = Colors.blue,
    this.centerStickSizePercent = 0.1,
    this.textLayoutBias = 0.85,
    this.textStyle = defaultTextStyle,
  });

  /// The thickness of divider between each parts
  final double dividerThickness;

  /// The color of divider between each parts
  final Color dividerColor;

  /// The color of the circle at center
  final Color centerStickerColor;

  /// The size percent of the circle at center
  final double centerStickSizePercent;

  /// The text layout offset, used to determin where to draw the text
  final double textLayoutBias;

  /// The text style of the [Roulette], can be override by the [RouletteUnit]'s textStyle.
  final TextStyle textStyle;
}
