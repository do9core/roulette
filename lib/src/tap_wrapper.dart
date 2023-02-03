/// Copyright 2023 do9core
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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';

typedef RouletteBuilder = Widget Function(
  BuildContext context,
  RouletteController controller,
);

typedef RouletteTapCallback = void Function(int index);

class RouletteTapWrapper extends StatefulWidget {
  const RouletteTapWrapper({
    Key? key,
    required this.controller,
    required this.builder,
    this.onTap,
  }) : super(key: key);

  final RouletteController controller;
  final RouletteTapCallback? onTap;
  final RouletteBuilder builder;

  @override
  State<RouletteTapWrapper> createState() => _RouletteTapWrapperState();
}

class _RouletteTapWrapperState extends State<RouletteTapWrapper> {
  final GlobalKey _rouletteKey = GlobalKey();
  TapDownDetails? _lastTapDown;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTapDown: widget.onTap == null ? null : (d) => _lastTapDown = d,
          onTapUp: widget.onTap == null ? null : _handleTapUp,
          onTapCancel: widget.onTap == null ? null : () => _lastTapDown = null,
          child: SizedBox(
            key: _rouletteKey,
            child: widget.builder(context, widget.controller),
          ),
        );
      },
    );
  }

  void _handleTapUp(TapUpDetails details) {
    final d = _lastTapDown;
    if (d == null) return;
    _lastTapDown = null;

    final contentContext = _rouletteKey.currentContext;
    if (contentContext == null) return;

    final contentSize = (contentContext as Element).size;
    if (contentSize == null) return;

    final downPos = d.localPosition;
    final center = Offset(contentSize.width / 2, contentSize.height / 2);
    final offset = downPos - center;

    double angle = 0;
    final tan = offset.dy / offset.dx;
    if (offset.dx > 0) {
      angle = math.pi / 2 + math.atan(tan);
    } else {
      angle = math.pi / 2 * 3 + math.atan(tan);
    }
    // TODO: Check distance to center to prevent out of bound tap responding

    // debugPrint('angle: $angle');

    final divides = widget.controller.group.divide;
    final single = 2 * math.pi / divides;
    final rotation = widget.controller.animation.value;
    final ranges = List.generate(
      divides,
      (index) {
        final b1 = (single * index + rotation) % (2 * math.pi);
        var b2 = (single * (index + 1) + rotation) % (2 * math.pi);
        if (b2 == 0) b2 = 2 * math.pi;
        return [math.min(b1, b2), math.max(b1, b2)];
      },
    );

    // debugPrint('Stops: $ranges');
    for (int i = 0; i < ranges.length; i++) {
      final range = ranges[i];
      if (angle >= range[0] && angle < range[1]) {
        widget.onTap?.call(i);
        break;
      }
    }
  }
}
