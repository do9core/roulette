import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roulette/roulette.dart';
import 'package:roulette/utils/helpers.dart';

import 'test_component.dart';

void main() {
  group('hitTestSector', () {
    const size = Size(400, 400); // radius = 200
    const center = Offset(200, 200);

    group('uniform sectors, no rotation', () {
      // 4 uniform sectors, each 90°.
      // Sector 0: 12 o'clock → 3 o'clock (drawn from -π/2 CW)
      final group = RouletteGroup.uniform(4);

      test('top-center (12 o\'clock direction) hits sector 0', () {
        // Slightly above center — in the "up" direction.
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx, center.dy - 100),
        );
        expect(result, 0);
      });

      test('right-center (3 o\'clock direction) hits sector 1', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx + 100, center.dy),
        );
        expect(result, 1);
      });

      test('bottom-center (6 o\'clock direction) hits sector 2', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx, center.dy + 100),
        );
        expect(result, 2);
      });

      test('left-center (9 o\'clock direction) hits sector 3', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx - 100, center.dy),
        );
        expect(result, 3);
      });
    });

    group('uniform sectors, with rotation', () {
      // 4 uniform sectors, rotate by π/2 (90° CW).
      // After rotation the sector layout shifts: sector 0 now starts at
      // angle 0 (3 o'clock) instead of -π/2 (12 o'clock).
      final group = RouletteGroup.uniform(4);
      const rotation = pi / 2; // 90° rotation

      test('top-center hits the last sector after rotation', () {
        // Up direction: the sector that used to cover "right→down" now covers
        // "up" after 90° CW rotation, which is sector 3.
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: rotation,
          localPosition: Offset(center.dx, center.dy - 100),
        );
        expect(result, 3);
      });

      test('right-center hits sector 0 after rotation', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: rotation,
          localPosition: Offset(center.dx + 100, center.dy),
        );
        expect(result, 0);
      });
    });

    group('weighted sectors, no rotation', () {
      // 3 sectors with weights [1, 2, 3] => total 6
      // Sector 0: 60° (π/3)
      // Sector 1: 120° (2π/3)
      // Sector 2: 180° (π)
      // Drawing starts at -π/2.
      final group = RouletteGroup(const [
        RouletteUnit(color: Colors.red, weight: 1),
        RouletteUnit(color: Colors.green, weight: 2),
        RouletteUnit(color: Colors.blue, weight: 3),
      ]);

      test('slightly right of top hits sector 0 (smallest)', () {
        // 15° from top (well within the 60° sector 0)
        final angle = -pi / 2 + pi / 12; // -π/2 + 15°
        final pos = center + Offset(100 * cos(angle), 100 * sin(angle));
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: pos,
        );
        expect(result, 0);
      });

      test('90° from top hits sector 1 (medium)', () {
        // 90° from start = -π/2 + π/2 = 0 → 3 o'clock.
        // Sector 0 covers 0–60°, sector 1 covers 60°–180°.
        // 90° is inside sector 1.
        final angle = -pi / 2 + pi / 2; // 0 rad
        final pos = center + Offset(100 * cos(angle), 100 * sin(angle));
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: pos,
        );
        expect(result, 1);
      });

      test('bottom-center hits sector 2 (largest)', () {
        // 180° from start: inside the 180°-wide sector 2.
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx, center.dy + 100),
        );
        expect(result, 2);
      });
    });

    group('boundary conditions', () {
      final group = RouletteGroup.uniform(4);

      test('outside circle returns null', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: const Offset(0, 0), // corner, distance > radius
        );
        expect(result, isNull);
      });

      test('exactly at edge is still inside', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx, 0), // exactly on top edge
        );
        expect(result, isNotNull);
      });

      test('center sticker exclusion returns null', () {
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: center, // exact center
          centerStickerPercent: 0.1,
        );
        expect(result, isNull);
      });

      test('just outside center sticker returns a sector', () {
        // Center sticker radius = 200 * 0.1 = 20.
        // Place tap at 25px above center.
        final result = hitTestSector(
          size: size,
          group: group,
          rotation: 0,
          localPosition: Offset(center.dx, center.dy - 25),
          centerStickerPercent: 0.1,
        );
        expect(result, isNotNull);
      });
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // TappableRoulette widget tests
  // ──────────────────────────────────────────────────────────────────
  group('TappableRoulette', () {
    testWidgets('tap calls onTap with correct sector index',
        (WidgetTester tester) async {
      await tester.configScreenSize(width: 400, height: 400);

      final controller = RouletteController();
      final group = RouletteGroup.uniform(4);
      int? tappedIndex;

      await tester.pumpWidget(
        SizedBox(
          width: 400,
          height: 400,
          child: TappableRoulette(
            group: group,
            controller: controller,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );

      // Tap the top-center of the 400x400 widget → sector 0.
      // Widget starts at (0,0) in a 400x400 surface.
      await tester.tapAt(const Offset(200, 50));
      await tester.pump();

      expect(tappedIndex, 0);
    });

    testWidgets('tap outside circle does not trigger onTap',
        (WidgetTester tester) async {
      await tester.configScreenSize(width: 400, height: 400);

      final controller = RouletteController();
      final group = RouletteGroup.uniform(4);
      int? tappedIndex;

      await tester.pumpWidget(
        SizedBox(
          width: 400,
          height: 400,
          child: TappableRoulette(
            group: group,
            controller: controller,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );

      // Tap top-left corner of the bounding box → outside the circle.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();

      expect(tappedIndex, isNull);
    });

    testWidgets('tap on right side hits sector 1', (WidgetTester tester) async {
      await tester.configScreenSize(width: 400, height: 400);

      final controller = RouletteController();
      final group = RouletteGroup.uniform(4);
      int? tappedIndex;

      await tester.pumpWidget(
        SizedBox(
          width: 400,
          height: 400,
          child: TappableRoulette(
            group: group,
            controller: controller,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      );

      // Tap right-center → sector 1.
      await tester.tapAt(const Offset(350, 200));
      await tester.pump();

      expect(tappedIndex, 1);
    });
  });
}
