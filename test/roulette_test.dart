import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roulette/roulette.dart';
import 'package:roulette/src/helpers.dart';
import 'package:roulette/src/roulette_paint.dart';

void main() {
  group('helpers tests', () {
    group('calculate end rotate test', () {
      test('ensure end rotate on target unit with no offset, clockwise', () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, true, 0);
        expect(actual, 4 / 5 * pi * 2);
      });

      test('ensure end rotate on target unit with offset, clockwise', () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, true, 0, offset: 1);
        expect(actual, pi * 2);
      });

      test('ensure end rotate on target unit with no offset, not clockwise',
          () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, false, 0);
        expect(actual, 0.0);
      });

      test('ensure end rotate on target unit with offset, not clockwise', () {
        final group = RouletteGroup.uniform(5);
        final actual = calculateEndRotate(group, 0, true, 0, offset: 1);
        expect(actual, pi * 2);
      });
    });
  });

  group('controller tests', () {
    testWidgets(
      'ensure rollTo settle at target index',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          RouletteWidgetTest(group: RouletteGroup.uniform(5)),
        );
        final state = tester
            .state<_RouletteWidgetTestState>(find.byType(RouletteWidgetTest));
        const minCircles = 3;
        state.controller.rollTo(1, minRotateCircles: minCircles);
        await tester.pumpAndSettle();
        final animation = state.controller.animation;
        expect(animation.value, (minCircles + 3 / 5) * pi * 2);
      },
    );

    testWidgets(
      'ensure rollTo settle at target index with offset',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          RouletteWidgetTest(group: RouletteGroup.uniform(5)),
        );
        final state = tester
            .state<_RouletteWidgetTestState>(find.byType(RouletteWidgetTest));
        const minCircles = 1;
        state.controller.rollTo(1, minRotateCircles: minCircles, offset: 1);
        await tester.pumpAndSettle();
        final animation = state.controller.animation;
        expect(animation.value, (minCircles + 4 / 5) * pi * 2);
      },
    );

    testWidgets(
      'ensure reset to initial state when update group',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          RouletteWidgetTest(group: RouletteGroup.uniform(5)),
        );
        final state = tester
            .state<_RouletteWidgetTestState>(find.byType(RouletteWidgetTest));
        state.controller.rollTo(1);
        await tester.pumpAndSettle();
        state.controller.group = RouletteGroup.uniform(6);
        expect(state.controller.animation.value, 0);
      },
    );
  });

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
              .state<_RouletteWidgetTestState>(find.byType(RouletteWidgetTest));
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

class RouletteWidgetTest extends StatefulWidget {
  const RouletteWidgetTest({
    Key? key,
    required this.group,
  }) : super(key: key);

  final RouletteGroup group;

  @override
  _RouletteWidgetTestState createState() => _RouletteWidgetTestState();
}

class _RouletteWidgetTestState extends State<RouletteWidgetTest>
    with SingleTickerProviderStateMixin {
  late RouletteController controller;

  @override
  void initState() {
    controller = RouletteController(
      group: widget.group,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Roulette(controller: controller),
      ),
    );
  }
}

extension ScreenSize on WidgetTester {
  Future<void> configScreenSize({
    double width = 500,
    double height = 500,
    double pixelDensity = 1,
  }) async {
    final size = Size(width, height);
    await binding.setSurfaceSize(size);
    binding.window.physicalSizeTestValue = size;
    binding.window.devicePixelRatioTestValue = pixelDensity;
  }
}
