import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'roulette_group.dart';
import '../utils/constants.dart';

@internal
abstract class RouletteEvent {}

@internal
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

@internal
class RouletteStopEvent implements RouletteEvent {
  const RouletteStopEvent();
}

@internal
class InfiniteRollEvent implements RouletteEvent {
  const InfiniteRollEvent({
    required this.clockwise,
    this.period = defaultPeriod,
    this.curve,
  });

  final bool clockwise;
  final Duration period;
  final Curve? curve;
}

@internal
class RouletteResetEvent implements RouletteEvent {
  const RouletteResetEvent();
}

@internal
abstract class RouletteCallbackEvent {}

@internal
class OnRollEndEvent implements RouletteCallbackEvent {
  OnRollEndEvent(this.event);

  final RouletteEvent event;
}

@internal
class OnRollCancelledEvent implements RouletteCallbackEvent {
  OnRollCancelledEvent(this.event);

  final RouletteEvent event;
}

/// Controller for [Roulette] widget.
///
/// [Roulette] widget use [RouletteController] to control the rotate animation
/// and [Roulette]'s display [RouletteGroup].
class RouletteController {
  final _eventStreamController = StreamController<RouletteEvent>.broadcast();
  final _callbackStreamController =
      StreamController<RouletteCallbackEvent>.broadcast();

  @internal
  Stream<RouletteEvent> get onEvent => _eventStreamController.stream;

  @internal
  void invokeCallback(RouletteCallbackEvent event) {
    _callbackStreamController.add(event);
  }

  /// Reset animation to initial state
  void resetAnimation() {
    _eventStreamController.add(RouletteResetEvent());
  }

  /// Stop current running animation.
  /// No animation will be performed, the roulette will
  /// stop at current position directly.
  ///
  /// If you want your roulette to stop with an animation,
  /// use [rollTo] instead.
  void stop() {
    _eventStreamController.add(RouletteStopEvent());
  }

  /// Start an animation to [targetIndex], [targetIndex] item must be in [group].
  /// The [duration] is the animation duration.
  /// The [clockwise] determin whether the animator should run in closewise didrection.
  /// Config [minRotateCircles] to determine the minimum rotate before settle.
  /// Provide a [curve] to update the animation curve.
  /// Provide a [offset] for roulette stop position, by default, 0 indicates the start of the part.
  ///
  /// Returning a [Future] which indicates whether the animation is completed or cancelled.
  /// Return value true indicates the animation is completed.
  Future<bool> rollTo(
    int targetIndex, {
    Duration duration = defaultDuration,
    int minRotateCircles = defaultMinRotateCircles,
    bool clockwise = true,
    Curve? curve = Curves.fastOutSlowIn,
    double offset = 0,
  }) {
    final completer = Completer<bool>();
    final event = RouletteRollEvent(
      targetIndex,
      duration: duration,
      minRotateCircles: minRotateCircles,
      clockwise: clockwise,
      curve: curve,
      offset: offset,
    );
    _eventStreamController.add(event);

    StreamSubscription? subscription;
    subscription = _callbackStreamController.stream.listen((e) {
      if (e is OnRollEndEvent && e.event == event) {
        completer.complete(true);
        subscription?.cancel();
      }

      if (e is OnRollCancelledEvent && e.event == event) {
        completer.complete(false);
        subscription?.cancel();
      }
    });

    return completer.future;
  }

  /// Start rolling the roulette indefinitely until a
  /// [rollTo], [rollInfinitely] or [stop] is called.
  /// The [clockwise] determine whether the animator should run in clockwise direction.
  /// Config [period] to update the roll period for one circle.
  /// If you want to change the cycle animation behavior, try [curve],
  /// but it may make the animation look wired.
  ///
  /// Returning a [Future], when the animation is completed(cancelled actually)
  /// the future resolved.
  Future<void> rollInfinitely({
    bool clockwise = true,
    Duration period = defaultPeriod,
    Curve? curve,
  }) {
    final completer = Completer<void>();
    final event = InfiniteRollEvent(clockwise: clockwise, period: period);
    _eventStreamController.add(event);

    StreamSubscription? subscription;
    subscription = _callbackStreamController.stream.listen((e) {
      if (e is OnRollCancelledEvent && e.event == event) {
        completer.complete();
        subscription?.cancel();
      }
    });

    return completer.future;
  }

  void dispose() {
    _eventStreamController.close();
    _callbackStreamController.close();
  }
}
