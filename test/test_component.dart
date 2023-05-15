import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roulette/roulette.dart';

class RouletteWidgetTest extends StatefulWidget {
  const RouletteWidgetTest({
    Key? key,
    required this.group,
  }) : super(key: key);

  final RouletteGroup group;

  @override
  RouletteWidgetTestState createState() => RouletteWidgetTestState();
}

class RouletteWidgetTestState extends State<RouletteWidgetTest>
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
    view.physicalSize = size;
    view.devicePixelRatio = pixelDensity;
  }
}
