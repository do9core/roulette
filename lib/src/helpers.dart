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

import 'dart:math';

import 'package:flutter/material.dart';

import 'roulette_group.dart';
import 'roulette_unit.dart';

/// Make [Animation] from [controller] to begin rotate effect.
/// Rotate final position is [targetValue].
Animation<double> makeAnimation(
  AnimationController controller,
  double targetValue,
  Curve? curve,
) {
  if (curve != null) {
    final curved = CurvedAnimation(parent: controller, curve: curve);
    return curved.drive(Tween(begin: 0.0, end: targetValue));
  } else {
    return controller.drive(Tween(begin: 0.0, end: targetValue));
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
  assert(units.isNotEmpty);
  assert(targetIndex >= 0 && targetIndex < group.divide);
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
