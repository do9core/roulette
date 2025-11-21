import 'dart:math';

import 'package:flutter/material.dart';

import 'package:roulette/roulette.dart';
import 'arrow.dart';

void main() {
  runApp(const MyApp());
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
            child: Roulette(
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
            ),
          ),
        ),
        const Arrow(),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final _random = Random();

  final _controller = RouletteController();
  bool _clockwise = true;

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
              FilledButton(
                onPressed: () async {
                  final completed = await _controller.rollTo(
                    3,
                    clockwise: _clockwise,
                    offset: _random.nextDouble(),
                  );

                  if (!context.mounted) return;
                  if (completed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Animation completed')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Animation cancelled')),
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
