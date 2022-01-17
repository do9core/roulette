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
import 'package:roulette/src/decoration/roulette_decoration.dart';

import 'roulette_unit.dart';
import 'helpers.dart' show DoubleSum, IndexBuilder;

/// Describe a total roulette
class RouletteGroup {
  /// Create a roulette group with given [units].
  RouletteGroup(this.units);

  /// Helper function to create a even [RouletteGroup].
  /// [itemCount] is the number of items in the group.
  /// [textBuilder] is a function that return the text of the unit.
  /// [colorBuilder] is a function that return the color of the unit.
  /// [textStyleBuilder] is a function that return the text style of the unit.
  factory RouletteGroup.uniform(
    int itemCount, {
    IndexBuilder<String?>? textBuilder,
    @Deprecated("use decorationBuilder instead")
    IndexBuilder<Color>? colorBuilder,
    IndexBuilder<UnitDecoration>? decorationBuilder,
    IndexBuilder<TextStyle?>? textStyleBuilder,
  }) {
    final units = List.generate(
      itemCount,
      (index) => RouletteUnit(
        text: textBuilder?.call(index),
        textStyle: textStyleBuilder?.call(index),
        decoration: decorationBuilder?.call(index) ??
            const ColorDecoration(Colors.blue),
        weight: 1,
      ),
    );
    return RouletteGroup(units);
  }

  /// [RouletteUnit]s of this group
  final List<RouletteUnit> units;

  /// Total weights count of the [units]
  late final totalWeights = units.sum((unit) => unit.weight);

  /// Parts count of [units].
  int get divide => units.length;
}
