import 'dart:math';

import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';

import 'package:roulette/roulette.dart';
import 'arrow.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class MyRoulette extends StatelessWidget {
  const MyRoulette({
    super.key,
    required this.controller,
    required this.group,
  });

  final RouletteGroup group;
  final RouletteController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            // Use Roulette if you don't need onTap callback
            child: TappableRoulette(
              group: group,
              // Provide controller to update its state
              controller: controller,
              // Configure roulette's appearance
              style: const RouletteStyle(
                dividerThickness: 0.0,
                dividerColor: Colors.black,
                centerStickSizePercent: 0.05,
                centerStickerColor: Colors.black,
              ),
              // Only available in TappableRoulette
              onTap: (index) => showTappedSector(context, index),
            ),
          ),
        ),
        const Arrow(),
      ],
    );
  }

  void showTappedSector(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Roulette'),
          content: Text('You tapped $index sector'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            )
          ],
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum AnimationMode { curve, physics }

class _HomePageState extends State<HomePage> {
  static final _random = Random();

  final _controller = RouletteController();
  bool _clockwise = true;
  AnimationMode _animationMode = AnimationMode.curve;
  double _drag = 0.3;

  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
  ];

  final icons = <IconData>[
    Icons.ac_unit,
    Icons.access_alarm,
    Icons.access_time,
    Icons.accessibility,
    Icons.account_balance,
    Icons.account_balance_wallet,
  ];

  final images = <ImageProvider>[
    // Use [AssetImage] if you have 2.0x, 3.0x images,
    // We only have 1 exact image here
    const ExactAssetImage("asset/gradient.jpg"),
    const NetworkImage("https://picsum.photos/seed/example1/400"),
    const ExactAssetImage("asset/gradient.jpg"),
    const NetworkImage("https://bad.link.to.image"),
    const ExactAssetImage("asset/gradient.jpg"),
    const NetworkImage("https://picsum.photos/seed/example5/400"),
    // MemoryImage(...)
    // FileImage(...)
    // ResizeImage(...)
  ];

  late final group = RouletteGroup.uniformImages(
    colors.length,
    colorBuilder: (index) => colors[index],
    imageBuilder: (index) => images[index],
    textBuilder: (index) {
      if (index == 0) return 'Hi';
      return '';
    },
    styleBuilder: (index) {
      return const TextStyle(color: Colors.black);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.pink.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRoulette(
                group: group,
                controller: _controller,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Clockwise: ",
                            style: TextStyle(fontSize: 18),
                          ),
                          Checkbox(
                            value: _clockwise,
                            onChanged: (onChanged) {
                              setState(() {
                                _controller.resetAnimation();
                                _clockwise = !_clockwise;
                              });
                            },
                          ),
                        ],
                      ),
                      SegmentedButton<AnimationMode>(
                        segments: const [
                          ButtonSegment(
                            value: AnimationMode.curve,
                            label: Text('Curve'),
                            icon: Icon(Icons.show_chart),
                          ),
                          ButtonSegment(
                            value: AnimationMode.physics,
                            label: Text('Physics'),
                            icon: Icon(Icons.speed),
                          ),
                        ],
                        selected: {_animationMode},
                        onSelectionChanged: (selected) {
                          setState(() {
                            _animationMode = selected.first;
                          });
                        },
                      ),
                      AnimatedSize(
                        duration: Durations.medium1,
                        curve: Curves.fastOutSlowIn,
                        child: _animationMode == AnimationMode.physics
                            ? Row(
                                key: ValueKey('physics'),
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: _drag,
                                      min: 0.01,
                                      max: 0.99,
                                      onChanged: (value) {
                                        setState(() {
                                          _drag = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Text(_drag.toStringAsFixed(2)),
                                ],
                              )
                            : SizedBox.shrink(key: ValueKey('curve')),
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () async {
                          final AnimationConfig config;
                          switch (_animationMode) {
                            case AnimationMode.curve:
                              config = const CurveAnimationConfig(
                                curve: Curves.fastOutSlowIn,
                                duration: Duration(seconds: 5),
                              );
                            case AnimationMode.physics:
                              config = PhysicsAnimationConfig(drag: _drag);
                          }

                          final completed = await _controller.rollTo(
                            3,
                            clockwise: _clockwise,
                            offset: _random.nextDouble(),
                            animationConfig: config,
                          );

                          if (!context.mounted) return;
                          if (completed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Animation completed')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Animation cancelled')),
                            );
                          }
                        },
                        child: const Text('ROLL'),
                      ),
                      FilledButton(
                        onPressed: () {
                          _controller.stop();
                        },
                        child: const Text('CANCEL'),
                      ),
                      FilledButton(
                        onPressed: () {
                          _controller.resetAnimation();
                        },
                        child: const Text('RESET'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
