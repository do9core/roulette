import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roulette/roulette.dart';
import 'package:roulette/src/roulette_paint.dart';

import 'test_component.dart';

void main() {
  group('widget display tests', () {
    testWidgets(
      'ensure roulette displayed',
      (WidgetTester tester) async {
        final group = RouletteGroup.uniform(
          5,
          textBuilder: (index) => '$index',
          colorBuilder: (index) => Colors.pink,
        );
        final controller = RouletteController(group: group, vsync: tester);
        await tester.pumpWidget(Roulette(controller: controller));
        expect(find.byType(RoulettePaint), findsOneWidget);
      },
    );

    group('golden tests', () {
      testWidgets(
        'ensure roulette span uniform',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final group = RouletteGroup.uniform(
            5,
            textBuilder: (index) => '$index',
            colorBuilder: (index) => Colors.pinkAccent,
          );
          await tester.pumpWidget(RouletteWidgetTest(group: group));
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
            RouletteUnit(color: Colors.red, weight: 1),
            RouletteUnit(color: Colors.green, weight: 2),
            RouletteUnit(color: Colors.cyan, weight: 3),
          ]);
          await tester.pumpWidget(RouletteWidgetTest(group: group));
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.weight.based.display.png'),
          );
        },
      );

      testWidgets('ensure roulette with icons displayed', (tester) async {
        final group = RouletteGroup.uniformIcons(
          5,
          iconBuilder: (index) => Icons.message,
          colorBuilder: (index) => Colors.teal,
          // TODO: iconColorBuilder: (index) => Colors.black,
        );
        await tester.pumpWidget(RouletteWidgetTest(group: group));
        await expectLater(
          find.byType(Roulette),
          matchesGoldenFile('golden_test/test.uniform.icons.display.png'),
        );
      });

      testWidgets(
        'ensure roulette settle at expected position',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final group = RouletteGroup(const [
            RouletteUnit.noText(color: Colors.red),
            RouletteUnit.noText(color: Colors.green),
            RouletteUnit.noText(color: Colors.cyan),
            RouletteUnit.noText(color: Colors.indigo),
            RouletteUnit.noText(color: Colors.yellow),
          ]);
          await tester.pumpWidget(RouletteWidgetTest(group: group));
          // Ensure initial state
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.uniform.rollTo.initial.png'),
          );
          final state = tester
              .state<RouletteWidgetTestState>(find.byType(RouletteWidgetTest));
          state.controller.rollTo(3, minRotateCircles: 1);
          await tester.pumpAndSettle();
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.uniform.rollTo.end.png'),
          );
        },
      );
    });
  });
}
