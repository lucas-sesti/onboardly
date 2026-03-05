import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'spotlight_painter.dart';
import 'spotlight_target.dart';
import 'spotlight_touch_layer.dart';

/// Widget that renders a spotlight overlay with dimmed background and highlighted areas.
///
/// The overlay creates transparent "holes" around target widgets, allowing them
/// to stand out while the rest of the screen is dimmed and blurred.
class SpotlightOverlay extends StatefulWidget {
  /// Creates a spotlight overlay.
  const SpotlightOverlay({
    Key? key,
    required this.targets,
    required this.style,
    this.extraHoles,
    this.extraHolePaths,
  }) : super(key: key);

  /// The target widgets to highlight with transparent holes.
  final List<SpotlightTarget> targets;

  /// Visual styling for the spotlight effect.
  final SpotlightStyle style;

  /// Additional rectangular areas to keep transparent.
  final List<Rect>? extraHoles;

  /// Additional custom-shaped areas to keep transparent.
  final List<Path>? extraHolePaths;

  @override
  SpotlightOverlayState createState() => SpotlightOverlayState();
}

/// State for [SpotlightOverlay] that manages animations and hole tracking.
class SpotlightOverlayState extends State<SpotlightOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _blurAnimation;
  final ValueNotifier<List<SpotlightHole>> _holes =
      ValueNotifier<List<SpotlightHole>>(<SpotlightHole>[]);
  List<SpotlightHole> _lastHoles = const [];

  bool _tracking = true;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _blurAnimation = Tween<double>(
      begin: 0,
      end: widget.style.blurSigma,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHoles();
      _controller.forward();
      _startTracking();
    });
  }

  void _startTracking() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!mounted) {
        _updateTimer?.cancel();
        return;
      }
      if (_tracking) {
        _updateHoles();
      }
    });
  }

  void _updateHoles() {
    if (!mounted) return;
    final overlayBox = context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return;

    final resolvedHoles = <SpotlightHole>[];

    for (final target in widget.targets) {
      final targetContext = target.key.currentContext;
      final targetRender = targetContext?.findRenderObject();
      if (targetRender == null) continue;

      Offset topLeft;
      Size targetSize;

      if (targetRender is RenderBox) {
        if (!targetRender.hasSize) continue;
        topLeft = targetRender.localToGlobal(
          Offset.zero,
          ancestor: overlayBox,
        );
        targetSize = targetRender.size;
      } else if (targetRender is RenderSliver) {
        final sliverRect = _measureSliverRect(targetRender, overlayBox);
        if (sliverRect == null) continue;
        topLeft = sliverRect.topLeft;
        targetSize = sliverRect.size;
      } else {
        continue;
      }

      final renderHeight = targetSize.height;
      final targetHeight =
          (target.maxHeight != null && target.maxHeight! < renderHeight)
          ? target.maxHeight!
          : renderHeight;

      Rect rect = Rect.fromLTWH(
        topLeft.dx - target.padding.left,
        topLeft.dy - target.padding.top,
        targetSize.width + target.padding.horizontal,
        targetHeight + target.padding.vertical,
      );

      if (target.customWidth != null) {
        rect = Rect.fromLTWH(
          rect.left,
          rect.top,
          target.customWidth! + target.padding.horizontal,
          rect.height,
        );
      }

      final path = target.customPath != null
          ? target.customPath!.shift(
              Offset(
                topLeft.dx - target.padding.left,
                topLeft.dy - target.padding.top,
              ),
            )
          : (Path()..addRRect(
              RRect.fromRectAndCorners(
                rect,
                topLeft:
                    target.customBorderRadius?.topLeft ??
                    Radius.circular(target.borderRadius),
                topRight:
                    target.customBorderRadius?.topRight ??
                    Radius.circular(target.borderRadius),
                bottomLeft:
                    target.customBorderRadius?.bottomLeft ??
                    Radius.circular(target.borderRadius),
                bottomRight:
                    target.customBorderRadius?.bottomRight ??
                    Radius.circular(target.borderRadius),
              ),
            ));

      resolvedHoles.add(
        SpotlightHole(
          rect: rect,
          path: path,
          allowTouchThrough: target.allowTouchThrough,
        ),
      );
    }

    if (widget.extraHoles != null) {
      for (final rect in widget.extraHoles!) {
        resolvedHoles.add(
          SpotlightHole(
            rect: rect,
            path: Path()
              ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(16))),
            allowTouchThrough: true,
          ),
        );
      }
    }

    if (widget.extraHolePaths != null) {
      for (final path in widget.extraHolePaths!) {
        resolvedHoles.add(
          SpotlightHole(
            rect: path.getBounds(),
            path: path,
            allowTouchThrough: true,
          ),
        );
      }
    }

    if (!listEquals(_lastHoles, resolvedHoles)) {
      _lastHoles = resolvedHoles;
      if (mounted) {
        _holes.value = resolvedHoles;
      }
    }
  }

  Rect? _measureSliverRect(RenderSliver sliver, RenderBox ancestor) {
    final geometry = sliver.geometry;
    if (geometry == null) return null;

    final mainAxisExtent = geometry.paintExtent;
    final crossAxisExtent = sliver.constraints.crossAxisExtent;

    RenderObject? current = sliver.parent;
    Axis axis = Axis.vertical;
    while (current != null) {
      if (current is RenderViewport) {
        axis = current.axis;
        break;
      }
      current = current.parent;
    }

    final paintBounds = Rect.fromLTWH(
      axis == Axis.vertical ? 0 : geometry.paintOrigin,
      axis == Axis.vertical ? geometry.paintOrigin : 0,
      axis == Axis.vertical ? crossAxisExtent : mainAxisExtent,
      axis == Axis.vertical ? mainAxisExtent : crossAxisExtent,
    );

    final matrix = sliver.getTransformTo(ancestor);
    return MatrixUtils.transformRect(matrix, paintBounds);
  }

  /// Hides the spotlight overlay with a reverse animation.
  ///
  /// This method should be called before removing the overlay from the widget tree.
  Future<void> hide() async {
    if (!_tracking) return;
    _tracking = false;
    _updateTimer?.cancel();
    _controller.reverse();
  }

  @override
  void dispose() {
    _tracking = false;
    _updateTimer?.cancel();
    _holes.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SpotlightHole>>(
      valueListenable: _holes,
      builder: (context, holes, _) {
        final size = MediaQuery.of(context).size;
        final screenPath = Path()..addRect(Offset.zero & size);
        var holesPath = Path();
        for (final hole in holes) {
          holesPath = Path.combine(PathOperation.union, holesPath, hole.path);
        }
        final overlayPath = Path.combine(
          PathOperation.difference,
          screenPath,
          holesPath,
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                if (!Platform.isIOS) ...{
                  Positioned.fill(
                    child: ClipPath(
                      clipper: _OverlayPathClipper(overlayPath),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: _blurAnimation.value,
                          sigmaY: _blurAnimation.value,
                        ),
                        child: Container(
                          color: widget.style.scrimColor.withValues(
                            alpha: _opacityAnimation.value * 0.01,
                          ),
                        ),
                      ),
                    ),
                  ),
                },
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: SpotlightPainter(
                        holes: holes,
                        scrimColor: widget.style.scrimColor.withValues(
                          alpha: _opacityAnimation.value * 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: SpotlightTouchLayer(holes: holes)),
              ],
            );
          },
        );
      },
    );
  }
}

class _OverlayPathClipper extends CustomClipper<Path> {
  const _OverlayPathClipper(this.overlayPath);

  final Path overlayPath;

  @override
  Path getClip(Size size) => overlayPath;

  @override
  bool shouldReclip(covariant _OverlayPathClipper oldClipper) =>
      oldClipper.overlayPath != overlayPath;
}
