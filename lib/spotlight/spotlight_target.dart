import 'package:flutter/material.dart';

class SpotlightTarget {
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

  final GlobalKey key;

  final EdgeInsets padding;

  final double borderRadius;

  final BorderRadius? customBorderRadius;

  final Path? customPath;

  final double? maxHeight;

  final double? customWidth;

  /// When false, touches inside this target hole will be absorbed by the overlay.
  final bool allowTouchThrough;
}

class SpotlightStyle {
  final double blurSigma;
  final Color scrimColor;
  final Duration animationDuration;

  const SpotlightStyle({
    this.blurSigma = 2,
    this.scrimColor = const Color.fromARGB(60, 0, 0, 0),
    this.animationDuration = const Duration(milliseconds: 300),
  });
}

class SpotlightHole {
  const SpotlightHole({
    required this.rect,
    required this.path,
    this.allowTouchThrough = true,
  });

  final Rect rect;
  final Path path;
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
