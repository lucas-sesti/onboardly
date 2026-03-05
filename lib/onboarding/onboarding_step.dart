import 'package:flutter/material.dart';

/// Where the tooltip should appear relative to the target.
enum OnboardingTooltipPosition { auto, above, below, center }

/// Position of the tooltip arrow relative to the tooltip container.
enum ArrowPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight
}

/// Represents a single step in the onboarding flow.
///
/// Each step highlights one or more target widgets with a spotlight effect
/// and displays a tooltip with information for the user.
class OnboardingStep {
  /// The primary widget to highlight in this step.
  final GlobalKey targetKey;

  /// Additional widgets to highlight alongside the primary target.
  final List<GlobalKey>? extraTargetKeys;

  /// Text description to display in the tooltip.
  final String? description;

  /// Custom widget to display in the tooltip instead of [description].
  final Widget? descriptionWidget;

  /// Whether to show the "Next" button in the tooltip.
  final bool showNext;

  /// Whether to show the "Skip" button in the tooltip.
  final bool showSkip;

  /// Where the tooltip should appear relative to the target.
  final OnboardingTooltipPosition position;
  final Map<GlobalKey, OnboardingTooltipPosition>? keyPositions;
  final Map<GlobalKey, double>? maxHeights;
  final Map<GlobalKey, double>? customWidths;
  final Map<GlobalKey, BorderRadius>? borderRadii;

  /// Optional horizontal padding applied to spotlight targets for this step.
  /// When null, controller-level default is used.
  final double? spotlightHorizontalPadding;

  /// Extra vertical offset applied to the tooltip relative to the target
  /// when positioned above/below/auto (positive values push it further away).
  final double tooltipVerticalOffset;

  /// Controls whether touches on each target area pass through the overlay.
  /// When omitted or when a key is absent in the map, the target is clickable (passes through).
  final Map<GlobalKey, bool>? targetClickables;

  /// Optional list matching [arrowPositions]; when provided, each arrow will
  /// be horizontally aligned to the center of the corresponding key's widget.
  final List<GlobalKey>? arrowAnchorKeys;
  final List<ArrowPosition>? arrowPositions;

  /// Returns all target keys for this step (primary + extras).
  List<GlobalKey> get allTargetKeys => [targetKey, ...?extraTargetKeys];

  /// Creates an onboarding step with the given configuration.
  ///
  /// Either [description] or [descriptionWidget] must be provided.
  const OnboardingStep({
    required this.targetKey,
    this.extraTargetKeys,
    this.description,
    this.descriptionWidget,
    this.showNext = true,
    this.showSkip = true,
    this.position = OnboardingTooltipPosition.auto,
    this.keyPositions,
    this.maxHeights,
    this.customWidths,
    this.borderRadii,
    this.spotlightHorizontalPadding,
    this.tooltipVerticalOffset = 0,
    this.targetClickables,
    this.arrowAnchorKeys,
    this.arrowPositions,
  }) : assert(description != null || descriptionWidget != null,
            'Either description or descriptionWidget must be provided');

  /// Returns whether the given target key should allow touch-through.
  /// Defaults to `true` when not specified.
  bool isTargetClickable(GlobalKey key) {
    if (targetClickables == null) return true;
    return targetClickables![key] ?? true;
  }
}
