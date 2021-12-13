import 'package:flutter/material.dart';

import 'roulette_style.dart';

/// Describe a sector area of a [Roulette]
class RouletteUnit {
  const RouletteUnit({
    this.text,
    this.textStyle,
    required this.color,
    required this.weight,
  });

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

  /// Text content of this section
  final String? text;

  /// Text style of this section
  final TextStyle? textStyle;

  /// Backgroud color of the sector
  final Color color;

  /// Weight of this sector
  final double weight;
}
