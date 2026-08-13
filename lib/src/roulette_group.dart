import 'package:flutter/widgets.dart';
import 'package:roulette/roulette.dart';

import '../utils/helpers.dart' show DoubleSum, IndexBuilder;

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
    required IndexBuilder<Color> colorBuilder,
    IndexBuilder<String?>? textBuilder,
    IndexBuilder<TextStyle?>? textStyleBuilder,
  }) {
    final units = List.generate(
      itemCount,
      (index) => RouletteUnit(
        text: textBuilder?.call(index),
        textStyle: textStyleBuilder?.call(index),
        color: colorBuilder(index),
        weight: 1,
      ),
    );
    return RouletteGroup(units);
  }

  /// Helper function to create a even [RouletteGroup].
  /// [itemCount] is the number of items in the group.
  /// [iconBuilder] is a function that return the icon of the unit.
  /// [colorBuilder] is a function that return the color of the unit.
  factory RouletteGroup.uniformIcons(
    int itemCount, {
    required IndexBuilder<IconData> iconBuilder,
    required IndexBuilder<Color> colorBuilder,
    IndexBuilder<TextStyle>? styleBuilder,
  }) {
    final units = List.generate(
      itemCount,
      (index) => RouletteUnit(
        icon: iconBuilder(index),
        color: colorBuilder(index),
        textStyle:
            RouletteStyle.defaultIconStyle.merge(styleBuilder?.call(index)),
        weight: 1,
      ),
    );
    return RouletteGroup(units);
  }

  /// Helper function to create a even [RouletteGroup].
  /// [itemCount] is the number of items in the group.
  /// [imageBuilder] is a function that return the image of the unit.
  /// [colorBuilder] is a function that return the color of the unit.
  factory RouletteGroup.uniformImages(
    int itemCount, {
    required IndexBuilder<ImageProvider> imageBuilder,
    IndexBuilder<Color>? colorBuilder,
    IndexBuilder<String?>? textBuilder,
    IndexBuilder<TextStyle>? styleBuilder,
  }) {
    final units = <RouletteUnit>[];

    for (int i = 0; i < itemCount; i += 1) {
      units.add(
        RouletteUnit(
          text: textBuilder?.call(i),
          image: imageBuilder.call(i),
          color: colorBuilder?.call(i) ?? Color.fromRGBO(0, 0, 0, 0),
          textStyle:
              RouletteStyle.defaultIconStyle.merge(styleBuilder?.call(i)),
          weight: 1,
        ),
      );
    }

    return RouletteGroup(units);
  }

  /// [RouletteUnit]s of this group
  final List<RouletteUnit> units;

  /// Total weights count of the [units]
  late final totalWeights = units.sum((unit) => unit.weight);

  /// Parts count of [units].
  int get divide => units.length;
}
