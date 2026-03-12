import 'dart:async';

import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'roulette_group.dart';
import '../utils/constants.dart';

@internal
@sealed
abstract class RouletteEvent {}

/// Configuration for roulette roll animation behavior.
///
/// See also:
/// - [CurveAnimationConfig], which drives the animation with a [Curve] over
///   a fixed [Duration].
/// - [PhysicsAnimationConfig], which drives the animation with a
///   friction-based physics simulation whose duration is determined by drag.
@sealed
abstract class AnimationConfig {}

/// An [AnimationConfig] that uses a [Curve] to ease the rotation over a
/// fixed [duration].
///
/// When no [AnimationConfig] is provided to [RouletteController.rollTo],
/// a default [CurveAnimationConfig] is used.
class CurveAnimationConfig implements AnimationConfig {
  const CurveAnimationConfig({
    this.curve = Curves.fastOutSlowIn,
    this.duration = defaultDuration,
  });

  /// The easing curve applied to the animation. Defaults to
  /// [Curves.fastOutSlowIn].
  final Curve curve;

  /// Total time the animation takes to complete.
  final Duration duration;
}

/// An [AnimationConfig] that simulates physical friction to decelerate the
/// roulette wheel naturally.
///
/// The animation duration is not fixed — it is determined by [drag].
/// A lower [drag] value produces stronger friction and a shorter spin,
/// while a higher value produces weaker friction and a longer spin.
class PhysicsAnimationConfig implements AnimationConfig {
  const PhysicsAnimationConfig({
    this.drag = 0.3,
  }) : assert(drag > 0 && drag < 1);

  /// Friction coefficient in the range (0, 1) exclusive.
  ///
  /// Values closer to 0 decelerate faster (stronger friction).
  /// Values closer to 1 decelerate slower (weaker friction).
  final double drag;
}

@internal
class RouletteRollEvent implements RouletteEvent {
  RouletteRollEvent(
    this.targetIndex, {
    this.animationConfig,
    this.minRotateCircles = defaultMinRotateCircles,
    this.clockwise = true,
    this.offset = 0,
  });

  final int targetIndex;
  final int minRotateCircles;
  final bool clockwise;
  final double offset;
  final AnimationConfig? animationConfig;
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

  /// Rolls the roulette to the item at [targetIndex].
  ///
  /// The wheel spins at least [minRotateCircles] full rotations before
  /// settling. Set [clockwise] to `false` to spin counter-clockwise.
  /// Use [offset] to shift the final stop position within the target
  /// sector (0 = sector start, 1 = sector end).
  ///
  /// Pass an [animationConfig] to control how the animation is driven:
  /// - [CurveAnimationConfig] — curve-based easing over a fixed duration
  ///   (used by default when [animationConfig] is `null`).
  /// - [PhysicsAnimationConfig] — friction-based deceleration whose
  ///   duration is determined by the drag coefficient.
  ///
  /// Returns `true` if the animation completes normally, or `false` if it
  /// is cancelled (e.g. by [stop] or another [rollTo] call).
  Future<bool> rollTo(
    int targetIndex, {
    int minRotateCircles = defaultMinRotateCircles,
    bool clockwise = true,
    double offset = 0,
    AnimationConfig? animationConfig,
  }) {
    final completer = Completer<bool>();
    final event = RouletteRollEvent(
      targetIndex,
      minRotateCircles: minRotateCircles,
      clockwise: clockwise,
      animationConfig: animationConfig,
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
