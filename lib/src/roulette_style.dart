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
