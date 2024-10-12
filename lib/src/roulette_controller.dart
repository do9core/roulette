import 'dart:async';

import 'package:flutter/material.dart';

import 'roulette_group.dart';
import '../utils/constants.dart';

abstract class RouletteEvent {}

class RouletteRollEvent implements RouletteEvent {
  RouletteRollEvent(
    this.targetIndex, {
    this.duration = defaultDuration,
    this.minRotateCircles = defaultMinRotateCircles,
    this.clockwise = true,
    this.curve = Curves.fastOutSlowIn,
    this.offset = 0,
  });

  final int targetIndex;
  final Duration duration;
  final int minRotateCircles;
  final bool clockwise;
  final Curve? curve;
  final double offset;
}

class RouletteStopEvent implements RouletteEvent {
  const RouletteStopEvent();
}

class RouletteResetEvent implements RouletteEvent {
  const RouletteResetEvent();
}

/// Controller for [Roulette] widget.
///
/// [Roulette] widget use [RouletteController] to control the rotate animation
/// and [Roulette]'s display [RouletteGroup].
class RouletteController {
  /// Create a new RouletteController instance.
  /// [group] is the [RouletteGroup] to display.
  RouletteController();

  final _controller = StreamController<RouletteEvent>.broadcast();

  /// Stream of [RouletteEvent] for controlling widget animations.
  ///
  /// As a user of this package, you don't need to listen to this stream.
  Stream<RouletteEvent> get onEvent => _controller.stream;

  /// Reset animation to initial state
  void resetAnimation() {
    _controller.add(RouletteResetEvent());
  }

  /// Stop current running animation
  void stop({bool canceled = true}) {
    _controller.add(RouletteStopEvent());
  }

  /// Start an animation to [targetIndex], [targetIndex] item must be in [group].
  /// The [duration] is the animation duration.
  /// The [clockwise] determin whether the animator should run in closewise didrection.
  /// Config [minRotateCircles] to determine the minimum rotate before settle.
  /// Provide a [curve] to update the animation curve.
  /// Provide a [offset] for roulette stop position, by default, 0 indicates the start of the part.
  Future<void> rollTo(
    int targetIndex, {
    Duration duration = defaultDuration,
    int minRotateCircles = defaultMinRotateCircles,
    bool clockwise = true,
    Curve? curve = Curves.fastOutSlowIn,
    double offset = 0,
  }) async {
    _controller.add(RouletteRollEvent(
      targetIndex,
      duration: duration,
      minRotateCircles: minRotateCircles,
      clockwise: clockwise,
      curve: curve,
      offset: offset,
    ));
  }

  void dispose() {
    _controller.close();
  }
}
