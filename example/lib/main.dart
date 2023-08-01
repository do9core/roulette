import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:roulette/roulette.dart';
import 'package:roulette/utils/image.dart';
import 'arrow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
    Key? key,
    required this.controller,
  }) : super(key: key);

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
              // Provide controller to update its state
              controller: controller,
              // Configure roulette's appearance
              style: const RouletteStyle(
                dividerThickness: 4,
                textLayoutBias: .8,
                centerStickerColor: Color(0xFF45A3FA),
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
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static final _random = Random();

  late RouletteController _controller;
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

  @override
  void initState() {
    super.initState();

    assert(colors.length == icons.length);

    _controller = RouletteController(vsync: this);
  }

  Future<List<ui.Image>> getImages() async {
    return Future.wait([
      Image.network("https://picsum.photos/400?${DateTime.now().millisecondsSinceEpoch.toString()}").toDartImage(),
      Image.network("https://picsum.photos/400?${DateTime.now().millisecondsSinceEpoch.toString()}").toDartImage(),
      Image.network("https://picsum.photos/400?${DateTime.now().millisecondsSinceEpoch.toString()}").toDartImage(),
      Image.network("https://picsum.photos/400?${DateTime.now().millisecondsSinceEpoch.toString()}").toDartImage(),
      Image.network("https://picsum.photos/400?${DateTime.now().millisecondsSinceEpoch.toString()}").toDartImage(),
      Image.network("https://picsum.photos/400?${DateTime.now().millisecondsSinceEpoch.toString()}").toDartImage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the controller

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Clockwise: ",
                    style: TextStyle(fontSize: 18),
                  ),
                  Switch(
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
              FutureBuilder<List<ui.Image>>(
                future: getImages(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator.adaptive();
                  }

                  final group = RouletteGroup.uniformImages(
                    colors.length,
                    colorBuilder: colors.elementAt,
                    imageBuilder: (index) => snapshot.data![index],
                    styleBuilder: (index) => const TextStyle(color: Colors.black),
                  );
                  _controller.group = group;
                  return MyRoulette(controller: _controller);
                },
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Use the controller to run the animation with rollTo method
        onPressed: () => _controller.rollTo(
          3,
          clockwise: _clockwise,
          offset: _random.nextDouble(),
        ),
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
