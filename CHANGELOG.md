## 0.1.2 - 2022/06/25
  * Update Flutter version to latest (3.0.3)
  * Update lint to 2.0.1 and fix lint warnings
  * Fix `rollTo` method's document, there's no `random` parameter but `offset`
  * Clean up the example
  * Add more detail usage to `README.md`
  * ⚠ If this update break your build because of the SDK upgrade, please feel free to [raise a issue](https://github.com/do9core/roulette/issues).

## 0.1.1 - 2022/05/31
  * Fix a bug which causes the full-width characters layout incorrectly. (Thanks for [@SeeLog](https://github.com/SeeLog)'s contribution!)

## 0.1.0+1 - 2022/01/15
  * Readme document snapshot resource fix.

## 0.1.0 - 2022/01/11

### ⚠ Breaking changes:
  * The `RouletteController` parameter `clockwise` has been removed since it does nothing. If you want to control the roll direction, use `clockwise` in `RouletteController.rollTo` instead.

### Normal changes:
  * The `RouletteController` public constructor is now a factory constructor.

### Others:
  * Add some new test case
  * Fix some document
  * Update some example codes

## 0.0.1+2 - 2021/12/14

* Fix some document

## 0.0.1+1 - 2021/12/13

* Change min sdk version to 2.12.0(The first SDK that supports null safety)
* Fix some pub score warnings

## 0.0.1 - 2021/12/12

* Initial release of the roulette package!
* Please check the [home page](https://github.com/do9core/roulette) for package information
