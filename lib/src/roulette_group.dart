import 'package:flutter/material.dart';

import 'roulette_unit.dart';
import 'helpers.dart' show DoubleSum, IndexBuilder;

/// Describe a total roulette
class RouletteGroup {
  RouletteGroup(this.units);

  /// Helper function to create a even [RouletteGroup].
  /// [itemCount] is the number of items in the group.
  /// [textBuilder] is a function that return the text of the unit.
  /// [colorBuilder] is a function that return the color of the unit.
  /// [textStyleBuilder] is a function that return the text style of the unit.
  factory RouletteGroup.uniform(
    int itemCount, {
    IndexBuilder<String?>? textBuilder,
    IndexBuilder<Color>? colorBuilder,
    IndexBuilder<TextStyle?>? textStyleBuilder,
  }) {
    final units = List.generate(
      itemCount,
      (index) => RouletteUnit(
        text: textBuilder?.call(index),
        textStyle: textStyleBuilder?.call(index),
        color: colorBuilder?.call(index) ?? Colors.blue,
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
