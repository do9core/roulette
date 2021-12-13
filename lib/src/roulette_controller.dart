import 'package:flutter/material.dart';

import 'roulette_group.dart';
import 'constants.dart';
import 'helpers.dart' hide DoubleSum;

/// Controller for [Roulette] widget.
///
/// [Roulette] widget use [RouletteController] to control the rotate animation
/// and [Roulette]'s display [RouletteGroup].
class RouletteController with ChangeNotifier {
  RouletteController({
    required RouletteGroup group,
    required TickerProvider vsync,
    bool clockwise = true,
  })  : _controller = AnimationController(vsync: vsync),
        _group = group;

  RouletteGroup _group;
  Animation<double>? _animation;
  final AnimationController _controller;

  /// Current rotate animation
  Animation<double> get animation =>
      _animation ?? _controller.drive(Tween(begin: 0, end: 0));

  /// Retrieve current displaying [RouletteGroup]
  RouletteGroup get group => _group;

  /// Set the [RouletteGroup] to refresh widget
  set group(RouletteGroup value) {
    _animation = null;
    _group = value;
    notifyListeners();
    _controller.reset();
  }

  /// Reset animation to initial state
  void resetAnimation() {
    _animation = null;
    notifyListeners();
    _controller.reset();
  }

  /// Stop current running animation
  void stop({bool canceled = true}) {
    _controller.stop(canceled: canceled);
  }

  /// Start an animation to [targetIndex], [targetIndex] item must be in [group].
  /// The [duration] is the animation duration.
  /// The [clockwise] determin whether the animator should run in closewise didrection.
  /// Config [minRotateCircles] to determine the minimum rotate before settle.
  /// Provide a [random] for randomization.
  /// Provide a [curve] to update the animation curve.
  Future<void> rollTo(
    int targetIndex, {
    Duration duration = defaultDuration,
    int minRotateCircles = defaultMinRotateCircles,
    bool clockwise = true,
    Curve? curve = Curves.fastOutSlowIn,
    double offset = 0,
  }) async {
    final targetRotate = calculateEndRotate(
      group,
      targetIndex,
      clockwise,
      minRotateCircles,
      offset: offset,
    );
    _controller.duration = duration;
    _animation = makeAnimation(_controller, targetRotate, curve);
    notifyListeners();
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
