import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roulette/roulette.dart';

class RouletteWidgetTest extends StatelessWidget {
  const RouletteWidgetTest({
    Key? key,
    required this.group,
    required this.controller,
  }) : super(key: key);

  final RouletteController controller;
  final RouletteGroup group;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Roulette(
          group: group,
          controller: controller,
        ),
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
    view.physicalSize = size;
    view.devicePixelRatio = pixelDensity;
  }
}
