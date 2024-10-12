[![Pub](https://img.shields.io/pub/v/roulette.svg)](https://pub.dev/packages/roulette)
[![Verify & Test](https://github.com/do9core/roulette/actions/workflows/verify_and_test.yml/badge.svg)](https://github.com/do9core/roulette/actions/workflows/verify_and_test.yml)
[![License](https://img.shields.io/github/license/do9core/roulette)](https://www.apache.org/licenses/LICENSE-2.0)

This is a Flutter library that provides a simple wheel widget for lottery usage.

## Features

* Quickly build customizable roulettes
* Support roulettes with different sized parts based on specified weight
* Easily control the roll animation and settle position
* Support text, icons and images for roulette parts

There are various types of roulette provided by this package (text is optional):

* Uniformed roulette:

  <img alt="Uniformed with no text" src="https://raw.githubusercontent.com/do9core/roulette/main/README.assets/uniform_no_text.png" width="300">

* Weight-based roulette:

  <img alt="Weight based with text" src="https://raw.githubusercontent.com/do9core/roulette/main/README.assets/weight_based_with_text.png" width="300">

* IconData roulette (available in 0.1.4):

  <img alt="Icon roulette" src="https://raw.githubusercontent.com/do9core/roulette/main/README.assets/uniform_icons.png" width="300">

* Image roulette (available in 0.1.5):

  <img alt="Icon roulette" src="https://raw.githubusercontent.com/do9core/roulette/main/README.assets/image_some_text.png" width="300">

## Getting started

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  roulette: ^0.1.5
```

## Usage

### Create a RouletteController

First, create a `RouletteController` instance:

```dart
// Create roulette units
final units = [
  RouletteUnit.noText(color: Colors.red),
  RouletteUnit.noText(color: Colors.green),
  // ...other units
];

// Initialize controller
final controller = RouletteController();
```

For uniformed roulette from a list, use the builder:

```dart
// Source data
final values = <int>[1, 2, 3, 4];

// Build uniformed group
final group = RouletteGroup.uniform(
  values.length,
  colorBuilder: (index) => Colors.blue,
  textBuilder: (index) => values[index].toString(),
  textStyleBuilder: (index) {
    // Customize text style, don't forget to return it
  },
);

// Create controller
controller = RouletteController();
```

### Add Roulette Widget

With the controller, add a `Roulette` widget:

```dart
@override
Widget build(BuildContext context) {
  return Roulette(
    group: group,
    controller: controller,
    style: RouletteStyle(
      // Customize appearance
    ),
  );
}
```

### Control the Animation

Use `rollTo` method to spin the roulette:

```dart
ElevatedButton(
  onPressed: () async {
    // Spin to index 2
    await controller.rollTo(2);
    // Do something after settled
  },
  child: Text('Roll!'),
);
```

`rollTo` allows options like randomizing stop position:

```dart
// Generate random offset
final random = Random();
final offset = random.nextDouble();

// Spin with offset
await controller.rollTo(2, offset: offset);
```

Please refer to API documentation for more details.

For more complete examples, please check the example app.

## Legal Statement

The creators of this library do not endorse or encourage any illegal gambling activities. Please use this library responsibly and comply with all applicable laws in your local jurisdiction. The authors assume no liability for any misuse of this software.
