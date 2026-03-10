import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

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

/// A [Simulation] that wraps [FrictionSimulation] and normalizes its output
/// to the 0.0 -> 1.0 range.
///
/// The initial velocity is calculated from [drag] so that the simulation
/// converges exactly to 1.0 as time approaches infinity.
class NormalizedFrictionSimulation extends Simulation {
  NormalizedFrictionSimulation({required double drag})
      : assert(drag > 0 && drag < 1),
        _inner = FrictionSimulation(drag, 0.0, -log(drag));

  final FrictionSimulation _inner;

  @override
  double x(double time) => _inner.x(time).clamp(0.0, 1.0);

  @override
  double dx(double time) => _inner.dx(time);

  @override
  bool isDone(double time) => _inner.isDone(time);
}

/// Determines which sector of a roulette the given [localPosition] falls in.
///
/// [size] is the widget size (assumed square).
/// [group] is the [RouletteGroup] whose weighted sectors to test against.
/// [rotation] is the current rotation angle in radians applied to the wheel.
/// [centerStickerPercent] is the radius fraction of the center sticker
/// (taps inside this circle return `null`).
///
/// Returns the 0-based sector index, or `null` if the tap is outside the
/// wheel circle or inside the center sticker.
int? hitTestSector({
  required Size size,
  required RouletteGroup group,
  required double rotation,
  required Offset localPosition,
  double centerStickerPercent = 0,
}) {
  final radius = size.width / 2;
  final center = Offset(size.width / 2, size.height / 2);
  final delta = localPosition - center;
  final distance = delta.distance;

  // Outside the circle.
  if (distance > radius) return null;

  // Inside the center sticker exclusion zone.
  if (centerStickerPercent > 0 && distance < radius * centerStickerPercent) {
    return null;
  }

  // The painter draws starting at angle -π/2 + rotation, so we reverse that
  // to obtain the angle in "sector space".
  final rawAngle = atan2(delta.dy, delta.dx);
  // Subtract the base rotation (-π/2 + rotation) to get the sector-local angle.
  var angle = rawAngle - (-pi / 2 + rotation);
  // Normalize to [0, 2π).
  angle = angle % (2 * pi);
  if (angle < 0) angle += 2 * pi;

  // Walk through sectors and find which one the angle falls in.
  double cumulative = 0;
  for (var i = 0; i < group.divide; i++) {
    final sweep = 2 * pi * group.units[i].weight / group.totalWeights;
    cumulative += sweep;
    if (angle < cumulative) return i;
  }
  // Floating-point edge case – attribute to last sector.
  return group.divide - 1;
}

typedef DoubleSelector<T> = double Function(T source);

extension DoubleSum<T> on Iterable<T> {
  double sum(DoubleSelector selector) =>
      fold(0.0, (previousValue, element) => previousValue + selector(element));
}

typedef IndexBuilder<T> = T Function(int index);
