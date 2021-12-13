import 'dart:math';

import 'package:flutter/material.dart';

import 'package:roulette/roulette.dart';
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late RouletteController _controller;
  bool _clockwise = true;

  @override
  void initState() {
    final group = RouletteGroup.uniform(
      6,
      colorBuilder: (index) {
        switch (index) {
          case 0:
            return Colors.red.withAlpha(50);
          case 1:
            return Colors.green.withAlpha(30);
          case 2:
            return Colors.blue.withAlpha(70);
          case 3:
            return Colors.yellow.withAlpha(90);
          case 4:
            return Colors.amber.withAlpha(50);
          default:
            return Colors.indigo.withAlpha(70);
        }
      },
    );
    _controller = RouletteController(vsync: this, group: group);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Roulette(
                        // Provide controller to update its state
                        controller: _controller,
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
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.pink.withAlpha(50),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Run the animation with rollTo method
        onPressed: () => _controller.rollTo(
          3,
          clockwise: _clockwise,
          offset: Random().nextDouble(),
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
