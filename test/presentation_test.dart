import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roulette/roulette.dart';

import 'test_component.dart';

void main() {
  group('widget display tests', () {
    group('golden tests', () {
      testWidgets(
        'ensure roulette span uniform',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final group = RouletteGroup.builder(
            5,
            textBuilder: (index) => '$index',
            decorationBuilder: (index) =>
                const UnitDecoration(color: Colors.pinkAccent),
          );
          await tester.pumpWidget(Roulette(group: group));
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.uniform.display.png'),
          );
        },
      );

      testWidgets(
        'ensure roulette span weight',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final group = RouletteGroup(const [
            RouletteUnit(
              decoration: UnitDecoration(color: Colors.red),
              weight: 1,
            ),
            RouletteUnit(
              decoration: UnitDecoration(color: Colors.green),
              weight: 2,
            ),
            RouletteUnit(
              decoration: UnitDecoration(color: Colors.cyan),
              weight: 3,
            ),
          ]);
          await tester.pumpWidget(Roulette(group: group));
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.weight.based.display.png'),
          );
        },
      );

      testWidgets(
        'ensure roulette settle at expected position',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final group = RouletteGroup(const [
            RouletteUnit.noText(
              decoration: UnitDecoration(color: Colors.red),
            ),
            RouletteUnit.noText(
              decoration: UnitDecoration(color: Colors.green),
            ),
            RouletteUnit.noText(
              decoration: UnitDecoration(color: Colors.cyan),
            ),
            RouletteUnit.noText(
              decoration: UnitDecoration(color: Colors.indigo),
            ),
            RouletteUnit.noText(
              decoration: UnitDecoration(color: Colors.yellow),
            ),
          ]);
          await tester.pumpWidget(RouletteWidgetTest(group: group));
          // Ensure initial state
          await expectLater(
            find.byType(AnimatedRoulette),
            matchesGoldenFile('golden_test/test.uniform.rollTo.initial.png'),
          );
          final state = tester
              .state<RouletteWidgetTestState>(find.byType(RouletteWidgetTest));
          state.controller.rollTo(3, minRotateCircles: 1);
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(AnimatedRoulette),
            matchesGoldenFile('golden_test/test.uniform.rollTo.end.png'),
          );
        },
      );
    });
  });
}
