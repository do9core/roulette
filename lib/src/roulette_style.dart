import 'package:flutter/material.dart';

import 'roulette_unit.dart';

/// Determines how a background image is laid out within each roulette section.
///
/// When a [RouletteUnit] has an image set, this mode controls
/// how the image is transformed and positioned inside the arc-shaped section.
enum SectionImageLayout {
  /// The image is rotated to align with the section's bisector angle,
  /// then scaled to cover the section area.
  ///
  /// This produces a visually centered result where the image appears
  /// to follow the section's orientation.
  rotatedFit,

  /// The image is scaled to fill the section's axis-aligned bounding box
  /// without any rotation.
  ///
  /// This produces a simpler mapping where the image stretches to cover
  /// the rectangular bounds of the section path.
  boundingBoxFit,
}

/// Describe the render style of roulette.
class RouletteStyle {
  /// Default section text style
  static const defaultTextStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: "Sans",
  );

  /// Default section icon style
  static const defaultIconStyle = TextStyle(
    fontSize: 40,
    color: Colors.white,
  );

  const RouletteStyle({
    this.dividerThickness = 5,
    this.dividerColor = Colors.white,
    this.centerStickerColor = Colors.blue,
    this.centerStickSizePercent = 0.1,
    this.textLayoutBias = 0.85,
    this.textStyle = defaultTextStyle,
    this.sectionImageLayout = SectionImageLayout.rotatedFit,
  });

  /// The thickness of divider between each parts
  final double dividerThickness;

  /// The color of divider between each parts
  final Color dividerColor;

  /// The color of the circle at center
  final Color centerStickerColor;

  /// The size percent of the circle at center
  final double centerStickSizePercent;

  /// The text layout offset, used to determin where to draw the text
  final double textLayoutBias;

  /// The text style of the [Roulette], can be override by the [RouletteUnit]'s textStyle.
  final TextStyle textStyle;

  /// Controls how background images are rendered within each section.
  ///
  /// When a [RouletteUnit] specifies an image, this determines
  /// the transformation applied to fit the image into the section's arc shape.
  ///
  /// Defaults to [SectionImageLayout.rotatedFit].
  ///
  /// See also:
  ///  * [SectionImageLayout.rotatedFit], which rotates and scales the image
  ///    to align with the section.
  ///  * [SectionImageLayout.boundingBoxFit], which scales the image into the
  ///    section's bounding rectangle without rotation.
  final SectionImageLayout sectionImageLayout;
}
