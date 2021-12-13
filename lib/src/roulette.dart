import 'package:flutter/material.dart';

import 'roulette_style.dart';
import 'roulette_controller.dart';
import 'roulette_paint.dart';

/// ルーレット(Roulette) Widget
///
/// This is an animatable widget.
/// You need to present a [RouletteController] to controll this widget.
class Roulette extends StatefulWidget {
  const Roulette({
    Key? key,
    required this.controller,
    this.style = const RouletteStyle(),
  }) : super(key: key);

  /// Controls the roulette.
  final RouletteController controller;

  /// The display style of the roulette.
  final RouletteStyle style;

  @override
  _RouletteState createState() => _RouletteState();
}

class _RouletteState extends State<Roulette> {
  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RoulettePaint(
      key: widget.key,
      animation: widget.controller.animation,
      style: widget.style,
      group: widget.controller.group,
    );
  }
}
