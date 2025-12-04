import 'dart:math';

import 'package:flutter/material.dart';

import '../src/roulette_group.dart';
import '../src/roulette_unit.dart';

/// Make [Animation] from [controller] to begin rotate effect.
/// Rotate final position is [targetValue].
Animation<double> makeAnimation(
  AnimationController controller,
  double targetValue,
  Curve? curve, {
  double initialValue = 0,
}) {
  final begin = initialValue % (2 * pi);
  if (curve != null) {
    final curved = CurvedAnimation(parent: controller, curve: curve);
    return curved.drive(Tween(begin: begin, end: targetValue));
  } else {
    return controller.drive(Tween(begin: begin, end: targetValue));
  }
}

/// Make [Animation] from [controller] to begin infinite roll effect.
Animation<double> makeInfiniteRollAnimation(
  AnimationController controller, {
  required bool clockwise,
  double initialValue = 0,
  Curve? curve,
}) {
  final begin = initialValue % (2 * pi);
  final end = begin + 2 * pi * (clockwise ? 1 : -1);
  final tween = Tween(begin: begin, end: end);
  if (curve != null) {
    final curved = CurvedAnimation(parent: controller, curve: curve);
    return curved.drive(tween);
  } else {
    return controller.drive(tween);
  }
}

/// Calculate the end rotate value by [targetIndex].
/// The returned value contains the circles to roll.
/// Make sure when you run this method the [group] has at least one [RouletteUnit].
///
/// [group] is the [RouletteGroup] to run rotate animation.
/// [targetIndex] is the end index in the [group].
/// [clockwise] determin whether the animator should run in closewise didrection.
/// [minRotateCircles] circles rolled before.
/// [random] Provide a random number generator for randomization, default null and no random value.
double calculateEndRotate(
  RouletteGroup group,
  int targetIndex,
  bool clockwise,
  int minRotateCircles, {
  double offset = 0,
}) {
  final units = group.units;
  assert(units.isNotEmpty, "You cannot roll an empty roulette.");
  assert(
    targetIndex >= 0 && targetIndex < group.divide,
    "targetIndex is out of group range.",
  );
  final passUnits = clockwise
      ? units.reversed.take(group.divide - targetIndex - 1)
      : units.take(targetIndex);
  final preRotation = minRotateCircles * 2 * pi;
  final totalRotateWeight =
      passUnits.sum((unit) => unit.weight); // Weights should rotate
  final targetRotate = 2 * pi * totalRotateWeight / group.totalWeights;
  final targetCoverRotate =
      2 * pi * units[targetIndex].weight / group.totalWeights;
  var offsetValue = offset * targetCoverRotate; // Random rotate out
  final totalRotate = preRotation + targetRotate + offsetValue;
  return clockwise ? totalRotate : -totalRotate;
}

typedef DoubleSelector<T> = double Function(T source);

extension DoubleSum<T> on Iterable<T> {
  double sum(DoubleSelector selector) =>
      fold(0.0, (previousValue, element) => previousValue + selector(element));
}

typedef IndexBuilder<T> = T Function(int index);
