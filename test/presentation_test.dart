import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roulette/roulette.dart';
import 'package:roulette/src/roulette_paint.dart';

import 'asset/image_data.dart';
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
        final controller = RouletteController();
        await tester.pumpWidget(Roulette(
          group: group,
          controller: controller,
          style: testRouletteStyle,
        ));
        expect(find.byType(RoulettePaint), findsOneWidget);
      },
    );

    group('golden tests', () {
      testWidgets(
        'ensure roulette span uniform',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final controller = RouletteController();
          final group = RouletteGroup.uniform(
            5,
            textBuilder: (index) => '$index',
            colorBuilder: (index) => Colors.pinkAccent,
          );
          await tester.pumpWidget(RouletteWidgetTest(
            group: group,
            controller: controller,
          ));
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
          final controller = RouletteController();
          final group = RouletteGroup(const [
            RouletteUnit(color: Colors.red, weight: 1),
            RouletteUnit(color: Colors.green, weight: 2),
            RouletteUnit(color: Colors.cyan, weight: 3),
          ]);
          await tester.pumpWidget(RouletteWidgetTest(
            group: group,
            controller: controller,
          ));
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.weight.based.display.png'),
          );
        },
      );

      testWidgets('ensure roulette with icons displayed', (tester) async {
        await tester.configScreenSize();
        final group = RouletteGroup.uniformIcons(
          5,
          iconBuilder: (index) => Icons.message,
          colorBuilder: (index) => Colors.teal,
          styleBuilder: (index) => const TextStyle(color: Colors.black),
        );
        final controller = RouletteController();
        await tester.pumpWidget(RouletteWidgetTest(
          group: group,
          controller: controller,
        ));
        final comparator = goldenFileComparator as LocalFileComparator;
        goldenFileComparator = _IconGoldenComparator(
          comparator.basedir.resolve('presentation_test.dart'),
        );
        addTearDown(() => goldenFileComparator = comparator);
        await expectLater(
          find.byType(Roulette),
          matchesGoldenFile('golden_test/test.uniform.icons.display.png'),
        );
      });

      testWidgets('ensure roulette with image displayed', (tester) async {
        await tester.configScreenSize();
        final image = MemoryImage(Uint8List.fromList(kBluePortraitPng));
        final controller = RouletteController();
        final group = RouletteGroup.uniformImages(
          5,
          imageBuilder: (index) => image,
          styleBuilder: (index) => const TextStyle(color: Colors.black),
          colorBuilder: (index) => Colors.black,
        );

        await tester.pumpWidget(RouletteWidgetTest(
          group: group,
          controller: controller,
        ));
        final Element element = tester.element(find.byType(Roulette));
        await tester.runAsync(() async {
          await precacheImage(image, element);
        });
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Roulette),
          matchesGoldenFile('golden_test/test.uniform.images.display.png'),
        );
      });

      testWidgets(
        'ensure roulette settle at expected position',
        (WidgetTester tester) async {
          await tester.configScreenSize();
          final controller = RouletteController();
          final group = RouletteGroup(const [
            RouletteUnit.noText(color: Colors.red),
            RouletteUnit.noText(color: Colors.green),
            RouletteUnit.noText(color: Colors.cyan),
            RouletteUnit.noText(color: Colors.indigo),
            RouletteUnit.noText(color: Colors.yellow),
          ]);
          await tester.pumpWidget(RouletteWidgetTest(
            group: group,
            controller: controller,
          ));
          // Ensure initial state
          await expectLater(
            find.byType(Roulette),
            matchesGoldenFile('golden_test/test.uniform.rollTo.initial.png'),
          );
          controller.rollTo(3, minRotateCircles: 1);
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

class _IconGoldenComparator extends LocalFileComparator {
  _IconGoldenComparator(Uri testFile) : super(testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    try {
      // The two macOS renders differed by 72 of 250,000 pixels, with at
      // most 5 levels of difference per color channel at the glyph edges.
      if (result.passed ||
          (result.diffPercent <= 0.0003 &&
              await _hasSmallChannelDiffs(result))) {
        return true;
      }
      throw FlutterError(await generateFailureOutput(result, golden, basedir));
    } finally {
      result.dispose();
    }
  }

  Future<bool> _hasSmallChannelDiffs(ComparisonResult result) async {
    final actual = (await result.diffs!['testImage']!.toByteData())!;
    final expected = (await result.diffs!['masterImage']!.toByteData())!;
    for (var offset = 0; offset < actual.lengthInBytes; offset++) {
      if ((actual.getUint8(offset) - expected.getUint8(offset)).abs() > 5) {
        return false;
      }
    }
    return true;
  }
}
