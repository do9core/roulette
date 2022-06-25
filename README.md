[![Pub](https://img.shields.io/pub/v/roulette.svg)](https://pub.dev/packages/roulette)
[![Verify & Test](https://github.com/do9core/roulette/actions/workflows/verify_and_test.yml/badge.svg)](https://github.com/do9core/roulette/actions/workflows/verify_and_test.yml)
[![License](https://img.shields.io/github/license/do9core/roulette)](https://www.apache.org/licenses/LICENSE-2.0)

This is a library provide a simple roulette widget which usually used for lottery.

## Features

* Quickly build roulettes
* Build roulettes with different parts depends on the weight
* Easily control the roll animation and settle position
* There are two types of roulette provided by this package (text is optional):

  * Uniformed roulette:

    <img alt="Uniformed with no text" src="README.assets/uniform_no_text.png" width="400">

  * Weight-based roulette:

    <img alt="Weight based with text" src="README.assets/weight_based_with_text.png" width="400">

## Getting started

## Usage

### Build a Roulette widget

First, you need to create a `RouletteController` instance.

```dart
RouletteController(
  group: RouletteGroup([
    RouletteUnit.noText(color: Colors.red),
    RouletteUnit.noText(color: Colors.green),
    // ...other units
  ]),
  vsync: this // provide a TickerProvider here (usually by SingleTickerProviderStateMixin)
);
```

If you want to map some list data into a uniformed `RouletteGroup`, try the builder:

```dart
final values = <int>[ /* Some value */ ];
final group = RouletteGroup.uniform(
  values.length,
  colorBuilder: Colors.blue,
  textBuilder: (index) => (index + 1).toString(),
  textStyleBuilder: (index) {
    // Set the text style here!
  },
);

controller = RouletteController(group: group, vsync: this);
```

Once you have a controller, you could add a `Roulette` widget into your widget tree:

```dart
@override
Widget build(BuildContext context) {
  return Roulette(
    controller: controller, // provide your controller here
    style: RouletteStyle(
      // config the roulette's appearance here
    ),
  );
}
```

### Run the Roulette

Use roll method to run the roulette where you need to.

```dart
ElevatedButton(
  onPressed: () => controller.rollTo(2), // provide the index you want to settle
  child: const Text('Roll!'),
);
```

You could await the `rollTo` method's finish and then make some other actions.

```dart
ElevatedButton(
  onPressed: () async {
    await controller.rollTo(2);
    // TODO: Do something when roulette stopped here.
  },
  child: const Text('Roll!'),
);
```

The `rollTo` method provides many options for you to control the rolling behavior, such as randomize the stop position:

```dart

final random = Random();

// ...

ElevatedButton(
  onPressed: () async {
    await controller.rollTo(2, offset: random.nextDouble());
    // TODO: Do something when roulette stopped here.
  },
  child: const Text('Roll!'),
);
```

For other options, please check the document for more information.

For detailed usage sample, please check the example.
