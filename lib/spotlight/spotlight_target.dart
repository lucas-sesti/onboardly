import 'package:flutter/material.dart';

/// Represents a widget to be highlighted by the spotlight effect.
///
/// The spotlight creates a transparent hole around the target widget,
/// allowing it to stand out against a dimmed background.
class SpotlightTarget {
  /// Creates a spotlight target from a [GlobalKey].
  ///
  /// The [padding] adds space around the widget, [borderRadius] rounds
  /// the corners, and [allowTouchThrough] controls whether touches on
  /// the target pass through to the widget beneath.
  const SpotlightTarget.fromKey(
    this.key, {
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 16,
    this.customBorderRadius,
    this.customPath,
    this.maxHeight,
    this.customWidth,
    this.allowTouchThrough = true,
  });

  /// The key of the widget to highlight.
  final GlobalKey key;

  /// Padding around the target widget.
  final EdgeInsets padding;

  /// Border radius for the spotlight hole (ignored if [customBorderRadius] is set).
  final double borderRadius;

  /// Custom border radius for more control (overrides [borderRadius]).
  final BorderRadius? customBorderRadius;

  /// Custom path shape for the spotlight hole.
  final Path? customPath;

  /// Maximum height constraint for the spotlight hole.
  final double? maxHeight;

  /// Custom width for the spotlight hole.
  final double? customWidth;

  /// When false, touches inside this target hole will be absorbed by the overlay.
  final bool allowTouchThrough;
}

/// Visual styling configuration for the spotlight overlay.
class SpotlightStyle {
  /// Blur intensity for the dimmed background.
  final double blurSigma;

  /// Color of the dimmed overlay (scrim) around the spotlight.
  final Color scrimColor;

  /// Duration of the spotlight show/hide animations.
  final Duration animationDuration;

  /// Creates a spotlight style with the given visual properties.
  const SpotlightStyle({
    this.blurSigma = 2,
    this.scrimColor = const Color.fromARGB(60, 0, 0, 0),
    this.animationDuration = const Duration(milliseconds: 300),
  });
}

/// Represents a transparent hole in the spotlight overlay.
///
/// Holes allow specific UI elements to remain visible and interactive
/// while the rest of the screen is dimmed.
class SpotlightHole {
  /// Creates a spotlight hole with the given [rect] and [path].
  const SpotlightHole({
    required this.rect,
    required this.path,
    this.allowTouchThrough = true,
  });

  /// The bounding rectangle of this hole.
  final Rect rect;

  /// The path shape of this hole.
  final Path path;

  /// Whether touches inside this hole pass through to widgets beneath.
  final bool allowTouchThrough;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpotlightHole &&
          rect == other.rect &&
          allowTouchThrough == other.allowTouchThrough;

  @override
  int get hashCode => Object.hash(rect, allowTouchThrough);
}
