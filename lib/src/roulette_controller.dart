import 'package:flutter/material.dart';

import 'roulette_group.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart' hide DoubleSum;

/// Controller for [Roulette] widget.
///
/// [Roulette] widget use [RouletteController] to control the rotate animation
/// and [Roulette]'s display [RouletteGroup].
class RouletteController with ChangeNotifier {
  RouletteController._(this._group, this._animation, this._controller);

  /// Create a new RouletteController instance.
  /// [group] is the [RouletteGroup] to display.
  /// [vsync] is the [TickerProvider] to use for the animation.
  factory RouletteController({
    required RouletteGroup group,
    required TickerProvider vsync,
  }) {
    final controller = AnimationController(vsync: vsync);
    final animation = controller.drive(Tween<double>(begin: 0, end: 0));
    return RouletteController._(group, animation, controller);
  }

  RouletteGroup _group;
  Animation<double> _animation;
  final AnimationController _controller;

  /// Current rotate animation
  Animation<double> get animation => _animation;

  /// Retrieve current displaying [RouletteGroup]
  RouletteGroup get group => _group;

  /// Set the [RouletteGroup] to refresh widget
  set group(RouletteGroup value) {
    _animation = _controller.drive(ConstantTween<double>(0));
    _group = value;
    notifyListeners();
    _controller.reset();
  }

  /// Reset animation to initial state
  void resetAnimation() {
    _animation = _controller.drive(ConstantTween<double>(0));
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
    final targetRotate = calculateEndRotate(
      group,
      targetIndex,
      clockwise,
      minRotateCircles,
      offset: offset,
    );
    _controller.duration = duration;
    _animation = makeAnimation(_controller, targetRotate, curve,
        initialValue: animation.value);
    notifyListeners();
    await _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
