/// Copyright 2021 do9core
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

import 'dart:math';
import 'dart:ui' as ui;

import 'roulette_style.dart';
import 'roulette_group.dart';

/// Animated roulette core
class RoulettePaint extends StatelessWidget {
  const RoulettePaint({
    Key? key,
    required this.rotation,
    required this.style,
    required this.group,
  }) : super(key: key);

  final RouletteStyle style;
  final RouletteGroup group;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: side,
          height: side,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _RoulettePainter(
                rotate: rotation,
                style: style,
                group: group,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoulettePainter extends CustomPainter {
  _RoulettePainter({
    required this.style,
    required this.rotate,
    required this.group,
  });

  final double rotate;
  final RouletteStyle style;
  final RouletteGroup group;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();
    canvas.rotate(-pi / 2 + rotate);

    _drawBackground(canvas, radius, rect);
    _drawText(canvas, radius);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, double radius, Rect rect) {
    _paint.strokeWidth = 0;
    _paint.style = ui.PaintingStyle.fill;

    double drewSweep = 0;
    final gradientRect = Rect.fromCircle(
      center: Offset(radius / 2, 0),
      radius: radius / 2,
    );

    for (var i = 0; i < group.divide; i++) {
      final unit = group.units[i];
      final sweep = 2 * pi * unit.weight / group.totalWeights;

      final decoration = unit.decoration;
      if (decoration == null) {
        drewSweep += sweep;
        continue;
      }

      canvas.save();
      canvas.rotate(drewSweep);

      // Draw the background color
      final color = decoration.color;
      if (color != null) {
        _paint.color = color;
      }

      // Draw the background gradient
      final gradient = decoration.gradient;
      if (gradient != null) {
        _paint.shader = gradient.createShader(gradientRect);
      }

      _paint.strokeWidth = 0;
      _paint.style = ui.PaintingStyle.fill;
      canvas.drawArc(rect, 0, sweep, true, _paint);

      // TODO: Draw other decorations

      canvas.restore();
      drewSweep += sweep;
    }

    drewSweep = 0;
    for (var i = 0; i < group.divide; i++) {
      final unit = group.units[i];
      final sweep = 2 * pi * unit.weight / group.totalWeights;

      final decoration = unit.decoration;
      if (decoration == null) {
        drewSweep += sweep;
        continue;
      }

      canvas.save();
      canvas.rotate(drewSweep);

      // Draw the section border
      final arc = decoration.border.arc;
      if (arc != null) {
        canvas.drawArc(rect, 0, sweep, false, arc.toPaint());
      }

      final edge = decoration.border.edge;
      if (edge != null) {
        canvas.drawLine(Offset.zero, Offset(radius, 0), edge.toPaint());
      }

      canvas.restore();
      drewSweep += sweep;
    }
  }

  void _drawText(Canvas canvas, double radius) {
    double drewSweep = 0.0; // Drew sweep angle
    for (var i = 0; i < group.divide; i++) {
      // Draw each section with unit
      final unit = group.units[i];
      final sweep = 2 * pi * unit.weight / group.totalWeights;

      final text = unit.text;
      if (text == null) {
        drewSweep += sweep;
        continue;
      }

      canvas.save();
      canvas.rotate(drewSweep + pi / 2 + sweep / 2);

      final textStyle = unit.textStyle ?? style.textStyle;
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle())
        ..pushStyle(textStyle.asUiTextStyle())
        ..addText(text);

      final p = pb.build();
      p.layout(const ui.ParagraphConstraints(width: double.infinity));

      canvas.drawParagraph(
          p, Offset(-p.minIntrinsicWidth / 2, -radius * style.textLayoutBias));
      canvas.restore();

      drewSweep += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RoulettePainter oldDelegate) =>
      oldDelegate.rotate != rotate ||
      oldDelegate.group != group ||
      oldDelegate.style != style;
}

extension _Cast on TextStyle {
  ui.TextStyle asUiTextStyle() => ui.TextStyle(
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        textBaseline: textBaseline,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        background: background,
        foreground: foreground,
        shadows: shadows,
        fontFeatures: fontFeatures,
      );
}
