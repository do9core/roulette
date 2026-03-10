import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roulette/roulette.dart';
import 'package:roulette/src/roulette.dart';
import 'package:roulette/utils/helpers.dart';
import 'package:roulette/src/roulette_paint.dart';

import 'test_component.dart';

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

    testWidgets('continuos rotation test', (WidgetTester tester) async {
      final controller = RouletteController();
      await tester.pumpWidget(RouletteWidgetTest(
        group: RouletteGroup.uniform(5),
        controller: controller,
      ));
      final widgetState = tester.state<RouletteState>(find.byType(Roulette));
      controller.rollTo(1, minRotateCircles: 0, offset: 1);
      await tester.pumpAndSettle();
      var animation = widgetState.rotateAnimation.value;
      expect(animation.value, 4 / 5 * pi * 2);

      controller.rollTo(2, minRotateCircles: 0, offset: 1);
      animation = widgetState.rotateAnimation.value;
      expect(animation.value, 4 / 5 * pi * 2);
    });

    testWidgets(
      'ensure rollTo settle at target index with offset',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const minCircles = 1;
        controller.rollTo(1, minRotateCircles: minCircles, offset: 1);
        await tester.pumpAndSettle();
        final animation = widgetState.rotateAnimation.value;
        expect(animation.value, (minCircles + 4 / 5) * pi * 2);
      },
    );
  });

  group('controller tests', () {
    testWidgets(
      'ensure rollTo settle at target index',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const minCircles = 3;
        controller.rollTo(1, minRotateCircles: minCircles);
        await tester.pumpAndSettle();
        final animation = widgetState.rotateAnimation.value;
        expect(animation.value, (minCircles + 3 / 5) * pi * 2);
      },
    );

    testWidgets(
      'ensure rollTo completes and returns true',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final future = controller.rollTo(2, minRotateCircles: 1);
        await tester.pumpAndSettle();
        expect(await future, isTrue);
      },
    );

    testWidgets(
      'ensure stop cancels rollTo and returns false',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final future = controller.rollTo(2, minRotateCircles: 3);
        await tester.pump(const Duration(milliseconds: 500));
        controller.stop();
        await tester.pumpAndSettle();
        expect(await future, isFalse);
      },
    );
  });

  group('CurveAnimationConfig tests', () {
    testWidgets(
      'ensure rollTo with CurveAnimationConfig settles at target',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const minCircles = 2;
        controller.rollTo(
          3,
          minRotateCircles: minCircles,
          animationConfig: const CurveAnimationConfig(
            curve: Curves.easeInOut,
            duration: Duration(seconds: 3),
          ),
        );
        await tester.pumpAndSettle();
        final animation = widgetState.rotateAnimation.value;
        expect(animation.value, closeTo((minCircles + 1 / 5) * pi * 2, 1e-10));
      },
    );

    testWidgets(
      'ensure rollTo with CurveAnimationConfig completes and returns true',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final future = controller.rollTo(
          1,
          minRotateCircles: 1,
          animationConfig: const CurveAnimationConfig(
            curve: Curves.linear,
            duration: Duration(seconds: 2),
          ),
        );
        await tester.pumpAndSettle();
        expect(await future, isTrue);
      },
    );

    testWidgets(
      'continuous rotation with CurveAnimationConfig preserves position',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        controller.rollTo(
          1,
          minRotateCircles: 0,
          offset: 1,
          animationConfig: const CurveAnimationConfig(),
        );
        await tester.pumpAndSettle();
        final first = widgetState.rotateAnimation.value.value;
        expect(first, 4 / 5 * pi * 2);

        controller.rollTo(
          2,
          minRotateCircles: 0,
          offset: 1,
          animationConfig: const CurveAnimationConfig(),
        );
        final second = widgetState.rotateAnimation.value.value;
        expect(second, first);
      },
    );
  });

  group('PhysicsAnimationConfig tests', () {
    testWidgets(
      'ensure rollTo with PhysicsAnimationConfig settles at target',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const minCircles = 2;
        controller.rollTo(
          3,
          minRotateCircles: minCircles,
          animationConfig: const PhysicsAnimationConfig(drag: 0.3),
        );
        await tester.pumpAndSettle();
        final animation = widgetState.rotateAnimation.value;
        expect(animation.value, closeTo((minCircles + 1 / 5) * pi * 2, 0.05));
      },
    );

    testWidgets(
      'ensure rollTo with PhysicsAnimationConfig completes and returns true',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final future = controller.rollTo(
          2,
          minRotateCircles: 1,
          animationConfig: const PhysicsAnimationConfig(drag: 0.5),
        );
        await tester.pumpAndSettle();
        expect(await future, isTrue);
      },
    );

    testWidgets(
      'ensure stop cancels PhysicsAnimationConfig rollTo',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final future = controller.rollTo(
          2,
          minRotateCircles: 3,
          animationConfig: const PhysicsAnimationConfig(drag: 0.5),
        );
        await tester.pump(const Duration(seconds: 1));
        controller.stop();
        await tester.pumpAndSettle();
        expect(await future, isFalse);
      },
    );

    testWidgets(
      'continuous rotation with PhysicsAnimationConfig preserves position',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        controller.rollTo(
          1,
          minRotateCircles: 0,
          offset: 1,
          animationConfig: const PhysicsAnimationConfig(drag: 0.3),
        );
        await tester.pumpAndSettle();
        final first = widgetState.rotateAnimation.value.value;
        expect(first, closeTo(4 / 5 * pi * 2, 0.05));

        controller.rollTo(
          2,
          minRotateCircles: 0,
          offset: 1,
          animationConfig: const PhysicsAnimationConfig(drag: 0.3),
        );
        final second = widgetState.rotateAnimation.value.value;
        expect(second, closeTo(first, 0.05));
      },
    );

    testWidgets(
      'different drag values both settle at correct target',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));
        const expected = 1 * 2 * pi + 3 / 5 * 2 * pi;

        controller.rollTo(
          1,
          minRotateCircles: 1,
          animationConfig: const PhysicsAnimationConfig(drag: 0.2),
        );
        await tester.pumpAndSettle();
        expect(
          widgetState.rotateAnimation.value.value,
          closeTo(expected, 0.05),
        );

        controller.resetAnimation();
        await tester.pump();

        controller.rollTo(
          1,
          minRotateCircles: 1,
          animationConfig: const PhysicsAnimationConfig(drag: 0.8),
        );
        await tester.pumpAndSettle();
        expect(
          widgetState.rotateAnimation.value.value,
          closeTo(expected, 0.05),
        );
      },
    );
  });

  group('rollInfinitely tests', () {
    testWidgets(
      'ensure rollInfinitely starts animation',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));

        controller.rollInfinitely();
        await tester.pump(); // process async stream event delivery
        await tester.pump(); // register the ticker's initial frame
        await tester.pump(const Duration(milliseconds: 100));

        // Animation value should have changed from 0
        final value = widgetState.rotateAnimation.value.value;
        expect(value, isNot(0.0));

        // Clean up
        controller.stop();
        await tester.pump();
      },
    );

    testWidgets(
      'ensure rollInfinitely is continuous (animation keeps running)',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));

        controller.rollInfinitely();
        await tester.pump(const Duration(milliseconds: 200));
        final firstValue = widgetState.rotateAnimation.value.value;

        await tester.pump(const Duration(milliseconds: 200));
        final secondValue = widgetState.rotateAnimation.value.value;

        // Should have advanced further
        expect(secondValue, greaterThan(firstValue));

        controller.stop();
        await tester.pump();
      },
    );

    testWidgets(
      'ensure stop cancels rollInfinitely and future resolves',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );

        final future = controller.rollInfinitely();
        await tester.pump(const Duration(milliseconds: 500));
        controller.stop();
        await tester.pump();

        // The future should resolve (not hang)
        await future;
      },
    );

    testWidgets(
      'ensure rollTo cancels rollInfinitely and settles at target',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));

        final infiniteFuture = controller.rollInfinitely();
        await tester.pump(const Duration(milliseconds: 500));

        // Now rollTo should cancel the infinite roll
        const minCircles = 1;
        final rollToResult = controller.rollTo(1, minRotateCircles: minCircles);
        await tester.pumpAndSettle();

        // Infinite roll future should have resolved
        await infiniteFuture;

        // rollTo should complete successfully
        expect(await rollToResult, isTrue);

        // Should have settled at the expected target position
        final animation = widgetState.rotateAnimation.value;
        expect(
          animation.value,
          closeTo((minCircles + 3 / 5) * pi * 2, 1e-10),
        );
      },
    );

    testWidgets(
      'ensure another rollInfinitely cancels the previous one',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );

        final firstFuture = controller.rollInfinitely();
        await tester.pump(const Duration(milliseconds: 500));

        // Start a second infinite roll
        final secondFuture = controller.rollInfinitely();
        await tester.pump(const Duration(milliseconds: 100));

        // First future should have resolved (cancelled)
        await firstFuture;

        // Second one should still be running; clean up
        controller.stop();
        await tester.pump();
        await secondFuture;
      },
    );

    testWidgets(
      'ensure rollInfinitely counter-clockwise rotates negatively',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));

        controller.rollInfinitely(clockwise: false);
        await tester.pump(); // process async stream event delivery
        await tester.pump(); // register the ticker's initial frame
        await tester.pump(const Duration(milliseconds: 200));

        final value = widgetState.rotateAnimation.value.value;
        expect(value, lessThan(0.0));

        controller.stop();
        await tester.pump();
      },
    );

    testWidgets(
      'ensure rollInfinitely with custom period works',
      (WidgetTester tester) async {
        final controller = RouletteController();
        await tester.pumpWidget(
          RouletteWidgetTest(
            group: RouletteGroup.uniform(5),
            controller: controller,
          ),
        );
        final widgetState = tester.state<RouletteState>(find.byType(Roulette));

        // Use a shorter period for faster rotation
        controller.rollInfinitely(
          period: const Duration(milliseconds: 500),
        );
        await tester.pump(); // process async stream event delivery
        await tester.pump(); // register the ticker's initial frame
        await tester.pump(const Duration(milliseconds: 250));

        final value = widgetState.rotateAnimation.value.value;
        // At half the period, animation should be roughly halfway through one cycle
        expect(value, greaterThan(0.0));
        expect(value, closeTo(pi, 0.1));

        controller.stop();
        await tester.pump();
      },
    );
  });

  group('other unit tests', () {
    test('conflict when set text and icon simultaneously', () {
      expect(
        () => RouletteUnit(
          text: 'TEST',
          icon: Icons.message,
          weight: 1,
          color: Colors.red,
        ),
        throwsAssertionError,
      );
    });
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
        final controller = RouletteController();
        await tester.pumpWidget(Roulette(group: group, controller: controller));
        expect(find.byType(RoulettePaint), findsOneWidget);
      },
    );
  });
}
