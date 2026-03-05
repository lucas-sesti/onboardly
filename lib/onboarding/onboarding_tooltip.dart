import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'onboarding_step.dart';

/// Widget that displays an onboarding tooltip with description and action buttons.
///
/// The tooltip appears near the highlighted target widget and can be positioned
/// above, below, or at the center of the screen.
class OnboardingTooltip extends StatefulWidget {
  /// The onboarding step configuration.
  final OnboardingStep step;

  /// The screen rectangle of the target widget being highlighted.
  final Rect targetRect;

  /// Whether to show the tooltip above the target (true) or below (false).
  final bool showAbove;

  /// Whether this is the last step in the onboarding flow.
  final bool isLastStep;

  /// Callback invoked when the user taps the "Next" or "OK" button.
  final VoidCallback onNext;

  /// Callback invoked when the user taps the "Skip" button.
  final VoidCallback onSkip;

  /// Text displayed on the next/confirm button. Defaults to 'OK'.
  final String nextText;

  /// Text displayed on the skip button. Defaults to 'Skip'.
  final String skipText;

  /// Text displayed on the finish button (last step). Defaults to 'Finish'.
  final String finishText;

  /// Optional callback that provides the tooltip's path for spotlight cutouts.
  final void Function(Path combinedPath)? onLayout;

  /// Creates an onboarding tooltip.
  const OnboardingTooltip({
    super.key,
    required this.targetRect,
    required this.showAbove,
    required this.isLastStep,
    required this.step,
    required this.onNext,
    required this.onSkip,
    this.onLayout,
    this.nextText = 'OK',
    this.skipText = 'Skip',
    this.finishText = 'Finish',
  });

  @override
  State<OnboardingTooltip> createState() => _OnboardingTooltipState();
}

class _OnboardingTooltipState extends State<OnboardingTooltip> {
  Path? _lastReportedPath;
  Path? _tooltipPath;
  Path? _skipButtonPath;
  bool _hasMeasured = false;

  void _tryReportCombinedPath() {
    if (_tooltipPath == null) return;

    Path combinedPath = _tooltipPath!;
    if (_skipButtonPath != null) {
      combinedPath =
          Path.combine(PathOperation.union, combinedPath, _skipButtonPath!);
    }

    final newBounds = combinedPath.getBounds();
    final lastBounds = _lastReportedPath?.getBounds();

    if (newBounds == lastBounds) return;

    _lastReportedPath = combinedPath;
    if (widget.onLayout != null) {
      widget.onLayout!(combinedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaSize = MediaQuery.of(context).size;
        final screenWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaSize.width;
        final screenHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mediaSize.height;

        const spacing = 12.0;
        const arrowHeight = 10.0;
        const arrowWidth = 20.0;
        const arrowSidePadding = 24.0;
        const horizontalPadding = 16.0;
        const cardBorderRadius = 16.0;
        const skipButtonPadding = 16.0;

        final bool isCenter =
            widget.step.position == OnboardingTooltipPosition.center;

        final List<GlobalKey>? anchorKeys = widget.step.arrowAnchorKeys;

        List<ArrowPosition> effectiveArrowPositions;
        if (isCenter) {
          effectiveArrowPositions = const [];
        } else if (widget.step.arrowPositions != null &&
            widget.step.arrowPositions!.isNotEmpty) {
          effectiveArrowPositions = widget.step.arrowPositions!;
        } else {
          final isWideTarget = widget.targetRect.width > screenWidth * 0.6;
          final targetCenterX = widget.targetRect.center.dx;
          ArrowPosition autoPosition;
          if (widget.showAbove) {
            if (isWideTarget) {
              autoPosition = ArrowPosition.bottomRight;
            } else {
              autoPosition = targetCenterX < screenWidth / 2
                  ? ArrowPosition.bottomLeft
                  : ArrowPosition.bottomRight;
            }
          } else {
            if (isWideTarget) {
              autoPosition = ArrowPosition.topLeft;
            } else {
              autoPosition = targetCenterX < screenWidth / 2
                  ? ArrowPosition.topLeft
                  : ArrowPosition.topRight;
            }
          }
          effectiveArrowPositions = [autoPosition];
        }

        final double rawOffset = widget.step.tooltipVerticalOffset;
        final double maxNegativeOffset = -(spacing + arrowHeight);
        final double extraOffset =
            rawOffset < maxNegativeOffset ? maxNegativeOffset : rawOffset;
        final double topOffset =
            widget.targetRect.bottom + (spacing + arrowHeight) + extraOffset;
        final double bottomOffset = screenHeight -
            widget.targetRect.top +
            (spacing + arrowHeight) +
            extraOffset;

        // debugPrint("- screenHeight: $screenHeight");
        // debugPrint("- targetTop: ${widget.targetRect.top}");
        // debugPrint("- targetBottom: ${widget.targetRect.bottom}");
        // debugPrint("- spacing: $spacing");
        // debugPrint("- arrowHeight: $arrowHeight");
        // debugPrint("- extraOffset: $extraOffset");
        // debugPrint("- bottomOffset: $bottomOffset");

        Widget descriptionContent = widget.step.descriptionWidget ??
            Text(
              widget.step.description ?? '',
              style: const TextStyle(fontSize: 14, height: 1.4),
            );

        Widget card = Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardBorderRadius),
            boxShadow: const [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: descriptionContent),
              if (widget.step.showNext)
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: GestureDetector(
                    onTap: widget.onNext,
                    child: Text(
                      widget.nextText,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );

        if (!_hasMeasured) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _hasMeasured = true;
          });
        }

        return SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: [
              if (widget.step.showSkip)
                Positioned(
                  top: skipButtonPadding,
                  right: skipButtonPadding,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: Builder(
                        builder: (skipContext) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            final box =
                                skipContext.findRenderObject() as RenderBox?;
                            if (box == null || !box.hasSize) return;
                            final offset = box.localToGlobal(Offset.zero);
                            final size = box.size;
                            final skipRect = offset & size;
                            final newSkipPath = Path()
                              ..addRRect(RRect.fromRectAndRadius(
                                skipRect,
                                const Radius.circular(24),
                              ));

                            final newBounds = newSkipPath.getBounds();
                            final oldBounds = _skipButtonPath?.getBounds();
                            if (newBounds != oldBounds) {
                              _skipButtonPath = newSkipPath;
                              _tryReportCombinedPath();
                            }
                          });

                          final isLastStep =
                              widget.isLastStep || widget.step.showNext == false;

                          return GestureDetector(
                            onTap: isLastStep ? widget.onNext : widget.onSkip,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 1,
                                    spreadRadius: 2,
                                    color: Colors.black.withAlpha(90),
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                isLastStep ? widget.finishText : widget.skipText,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (isCenter)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: horizontalPadding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight - 32,
                      ),
                      child: _TooltipCard(
                        card: card,
                        cardBorderRadius: cardBorderRadius,
                        arrowPositions: const [],
                        arrowHeight: arrowHeight,
                        arrowWidth: arrowWidth,
                        arrowSidePadding: arrowSidePadding,
                        anchorKeys: anchorKeys,
                        onPath: (path) {
                          _tooltipPath = path;
                          _tryReportCombinedPath();
                        },
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: widget.showAbove ? null : topOffset,
                  bottom: widget.showAbove ? bottomOffset : null,
                  child: SafeArea(
                    top: widget.showAbove,
                    bottom: !widget.showAbove,
                      child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: (() {
                          final available = widget.showAbove
                              ? widget.targetRect.top -
                                  (spacing + arrowHeight + extraOffset) -
                                  32
                              : screenHeight - topOffset - 16;
                          return available < 0 ? 0.0 : available;
                        })(),
                      ),
                      child: _TooltipCard(
                        card: card,
                        cardBorderRadius: cardBorderRadius,
                        arrowPositions: effectiveArrowPositions,
                        arrowHeight: arrowHeight,
                        arrowWidth: arrowWidth,
                        arrowSidePadding: arrowSidePadding,
                        anchorKeys: anchorKeys,
                        onPath: (path) {
                          final newBounds = path.getBounds();
                          final oldBounds = _tooltipPath?.getBounds();
                          if (newBounds != oldBounds) {
                            _tooltipPath = path;
                            _tryReportCombinedPath();
                          }
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TooltipCard extends StatefulWidget {
  const _TooltipCard({
    required this.card,
    required this.cardBorderRadius,
    required this.arrowPositions,
    required this.arrowHeight,
    required this.arrowWidth,
    required this.arrowSidePadding,
    required this.onPath,
    this.anchorKeys,
  });

  final Widget card;
  final double cardBorderRadius;
  final List<ArrowPosition> arrowPositions;
  final double arrowHeight;
  final double arrowWidth;
  final double arrowSidePadding;
  final List<GlobalKey>? anchorKeys;
  final void Function(Path path) onPath;

  @override
  State<_TooltipCard> createState() => _TooltipCardState();
}

class _TooltipCardState extends State<_TooltipCard> {
  final GlobalKey _cardKey = GlobalKey();
  Map<int, double> _arrowLeftByIndex = {};
  Path? _tooltipPath;
  bool _geometryScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleGeometryUpdate();
  }

  @override
  void didUpdateWidget(covariant _TooltipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleGeometryUpdate();
  }

  void _scheduleGeometryUpdate() {
    if (_geometryScheduled) return;
    _geometryScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geometryScheduled = false;
      if (!mounted) return;
      _updateGeometry();
    });
  }

  bool _isArrowOnTop(ArrowPosition pos) {
    return pos == ArrowPosition.topLeft ||
        pos == ArrowPosition.topCenter ||
        pos == ArrowPosition.topRight;
  }

  double _computeArrowLeftGlobal(
    ArrowPosition pos,
    Offset offset,
    Size size,
    int index,
  ) {
    double? anchoredLeft;
    final keys = widget.anchorKeys;
    if (keys != null &&
        index < keys.length &&
        keys[index].currentContext != null) {
      final render =
          keys[index].currentContext!.findRenderObject() as RenderBox?;
      if (render != null && render.hasSize) {
        final targetCenter =
            render.localToGlobal(Offset.zero).dx + render.size.width / 2;
        anchoredLeft = targetCenter - (widget.arrowWidth / 2);
      }
    }

    double fallbackLeft;
    switch (pos) {
      case ArrowPosition.topLeft:
      case ArrowPosition.bottomLeft:
        fallbackLeft = offset.dx + widget.arrowSidePadding;
        break;
      case ArrowPosition.topCenter:
      case ArrowPosition.bottomCenter:
        fallbackLeft = offset.dx + (size.width - widget.arrowWidth) / 2;
        break;
      case ArrowPosition.topRight:
      case ArrowPosition.bottomRight:
        fallbackLeft = offset.dx +
            size.width -
            widget.arrowSidePadding -
            widget.arrowWidth;
        break;
    }

    return (anchoredLeft ?? fallbackLeft).clamp(
      offset.dx + widget.arrowSidePadding,
      offset.dx + size.width - widget.arrowSidePadding - widget.arrowWidth,
    );
  }

  Path _buildArrowPath(
    ArrowPosition pos,
    double arrowLeftGlobal,
    Offset offset,
    Size size,
  ) {
    final arrowOnTop = _isArrowOnTop(pos);
    final path = Path();
    if (arrowOnTop) {
      path.moveTo(arrowLeftGlobal, offset.dy);
      path.lineTo(
        arrowLeftGlobal + widget.arrowWidth / 2,
        offset.dy - widget.arrowHeight,
      );
      path.lineTo(
        arrowLeftGlobal + widget.arrowWidth,
        offset.dy,
      );
    } else {
      path.moveTo(arrowLeftGlobal, offset.dy + size.height);
      path.lineTo(
        arrowLeftGlobal + widget.arrowWidth / 2,
        offset.dy + size.height + widget.arrowHeight,
      );
      path.lineTo(
        arrowLeftGlobal + widget.arrowWidth,
        offset.dy + size.height,
      );
    }
    path.close();
    return path;
  }

  void _updateGeometry() {
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    Map<int, double> newArrowLefts = {};
    Path tooltipPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          offset & size,
          Radius.circular(widget.cardBorderRadius),
        ),
      );

    for (var i = 0; i < widget.arrowPositions.length; i++) {
      final pos = widget.arrowPositions[i];
      final arrowLeftGlobal = _computeArrowLeftGlobal(pos, offset, size, i);
      final arrowPath = _buildArrowPath(pos, arrowLeftGlobal, offset, size);
      tooltipPath = Path.combine(
        PathOperation.union,
        tooltipPath,
        arrowPath,
      );
      newArrowLefts[i] = arrowLeftGlobal - offset.dx;
    }

    final boundsChanged = _tooltipPath == null ||
        _tooltipPath!.getBounds() != tooltipPath.getBounds();
    final arrowChanged = !mapEquals(_arrowLeftByIndex, newArrowLefts);

    if (boundsChanged || arrowChanged) {
      _tooltipPath = tooltipPath;
      _arrowLeftByIndex = newArrowLefts;
      widget.onPath(tooltipPath);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _scheduleGeometryUpdate();

    return Material(
      key: _cardKey,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.card,
          ...List.generate(widget.arrowPositions.length, (i) {
            final left = _arrowLeftByIndex[i];
            if (left == null) return const SizedBox.shrink();
            final pos = widget.arrowPositions[i];
            final arrowOnTop = _isArrowOnTop(pos);
            return Positioned(
              top: arrowOnTop ? -widget.arrowHeight : null,
              bottom: arrowOnTop ? null : -widget.arrowHeight,
              left: left,
              child: TooltipArrow(
                pointUp: arrowOnTop,
                color: Colors.white,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// A triangular arrow widget used to point from tooltip to target.
class TooltipArrow extends StatelessWidget {
  /// Whether the arrow points upward (true) or downward (false).
  final bool pointUp;

  /// The color of the arrow.
  final Color color;

  /// Creates a tooltip arrow.
  const TooltipArrow({
    super.key,
    required this.pointUp,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 10),
      painter: _TrianglePainter(color: color, pointUp: pointUp),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointUp;

  _TrianglePainter({required this.color, required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (pointUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
