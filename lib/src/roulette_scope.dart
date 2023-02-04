import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';

class _RouletteScope extends InheritedWidget {
  const _RouletteScope({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final RouletteController controller;

  @override
  bool updateShouldNotify(covariant _RouletteScope oldWidget) {
    return !identical(oldWidget.controller, controller);
  }
}

class RouletteScope extends StatelessWidget {
  const RouletteScope({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final RouletteController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _RouletteScope(
      controller: controller,
      child: child,
    );
  }

  static RouletteController? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_RouletteScope>();
    if (scope == null) return null;

    return scope.controller;
  }
}
