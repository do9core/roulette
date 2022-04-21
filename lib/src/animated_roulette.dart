/// Copyright 2022 do9core
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

import 'package:flutter/material.dart';

import 'roulette_controller.dart';
import 'roulette_paint.dart';
import 'roulette_style.dart';

/// This is an animatable roulette widget.
/// You need to present a [RouletteController] to controll this widget.
class AnimatedRoulette extends StatelessWidget {
  const AnimatedRoulette({
    Key? key,
    required this.controller,
    this.style = const RouletteStyle(),
  }) : super(key: key);

  /// Controls the roulette.
  final RouletteController controller;

  /// The display style of the roulette.
  final RouletteStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => AnimatedBuilder(
        animation: controller.animation,
        builder: (context, _) => RoulettePaint(
          rotation: controller.animation.value,
          style: style,
          group: controller.group,
        ),
      ),
    );
  }
}
