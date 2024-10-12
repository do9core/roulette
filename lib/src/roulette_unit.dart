import 'package:flutter/material.dart';

import 'roulette_style.dart';

/// Describe a sector area of a [Roulette]
class RouletteUnit {
  const RouletteUnit({
    this.text,
    this.textStyle,
    this.icon,
    this.image,
    required this.color,
    required this.weight,
  }) : assert(
          text == null || icon == null,
          'RouletteUnit cannot have both text and icon',
        );

  /// Create a sector with text
  const RouletteUnit.text(
    String text, {
    TextStyle textStyle = RouletteStyle.defaultTextStyle,
    Color color = Colors.blue,
    double weight = 1.0,
  }) : this(text: text, textStyle: textStyle, color: color, weight: weight);

  /// Create a sector with only color but no text
  const RouletteUnit.noText({
    Color color = Colors.blue,
    double weight = 1.0,
  }) : this(color: color, weight: weight);

  /// Create a sector with an icon
  const RouletteUnit.icon(
    IconData icon, {
    Color color = Colors.blue,
    double weight = 1.0,
    TextStyle style = RouletteStyle.defaultIconStyle,
  }) : this(color: color, icon: icon, weight: weight, textStyle: style);

  /// Create a sector with an image
  const RouletteUnit.image(
    ImageProvider image, {
    Color color = Colors.blue,
    double weight = 1.0,
    TextStyle style = RouletteStyle.defaultIconStyle,
  }) : this(color: color, image: image, weight: weight, textStyle: style);

  /// Text content of this sector
  final String? text;

  /// Text style of this sector
  final TextStyle? textStyle;

  /// Icon of this sector
  final IconData? icon;

  /// Image of this sector
  final ImageProvider? image;

  /// Backgroud color of the sector
  final Color color;

  /// Weight of this sector
  final double weight;
}
