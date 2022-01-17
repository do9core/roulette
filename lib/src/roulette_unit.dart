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

import 'package:flutter/material.dart';
import 'package:roulette/src/decoration/color_decoration.dart';

import 'decoration/roulette_decoration.dart';
import 'roulette_style.dart';

/// Describe a sector area of a [Roulette]
class RouletteUnit {
  const RouletteUnit({
    this.text,
    this.textStyle,
    @Deprecated("use decoration instead") this.color,
    required this.weight,
    required this.decoration,
  });

  /// Create a sector with text
  const RouletteUnit.text(
    String text, {
    TextStyle textStyle = RouletteStyle.defaultTextStyle,
    @Deprecated("use decoration instead") Color color = Colors.blue,
    double weight = 1.0,
    UnitDecoration decoration = const ColorDecoration(Colors.blue),
  }) : this(
          text: text,
          textStyle: textStyle,
          decoration: decoration,
          weight: weight,
        );

  /// Create a sector with only color but no text
  const RouletteUnit.noText({
    @Deprecated("use ColorDecoration instead") Color color = Colors.blue,
    UnitDecoration decoration = const ColorDecoration(Colors.blue),
    double weight = 1.0,
  }) : this(decoration: decoration, weight: weight);

  /// Text content of this sector
  final String? text;

  /// Text style of this sector
  final TextStyle? textStyle;

  /// Backgroud color of the sector
  @Deprecated("use decoration instead.")
  final Color? color;

  /// Background decoration of the sector
  final UnitDecoration decoration;

  /// Weight of this sector
  final double weight;
}
