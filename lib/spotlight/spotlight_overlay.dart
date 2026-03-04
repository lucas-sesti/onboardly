import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'spotlight_painter.dart';
import 'spotlight_target.dart';
import 'spotlight_touch_layer.dart';

class SpotlightOverlay extends StatefulWidget {
  const SpotlightOverlay({
    Key? key,
    required this.targets,
    required this.style,
    this.extraHoles,
    this.extraHolePaths,
  }) : super(key: key);

  final List<SpotlightTarget> targets;
  final SpotlightStyle style;
  final List<Rect>? extraHoles;
  final List<Path>? extraHolePaths;

  @override
  SpotlightOverlayState createState() => SpotlightOverlayState();
}

class SpotlightOverlayState extends State<SpotlightOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _blurAnimation;
  final ValueNotifier<List<SpotlightHole>> _holes =
      ValueNotifier<List<SpotlightHole>>(<SpotlightHole>[]);
  List<SpotlightHole> _lastHoles = const [];

  bool _tracking = true;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHoles();
      _controller.forward();
    });
    SchedulerBinding.instance.addPersistentFrameCallback(_handleFrame);
  }

  void _handleFrame(Duration timestamp) {
    if (!_tracking || !mounted) return;
    _updateHoles();
  }

  void _updateHoles() {
    final overlayBox = context.findRenderObject() as RenderBox?;
    if (overlayBox == null || !overlayBox.hasSize) return;

    final resolvedHoles = <SpotlightHole>[];

    for (final target in widget.targets) {
      final targetContext = target.key.currentContext;
      final targetRender = targetContext?.findRenderObject();
      if (targetRender is! RenderBox || !targetRender.hasSize) continue;

      final topLeft =
          targetRender.localToGlobal(Offset.zero, ancestor: overlayBox);
      final renderHeight = targetRender.size.height;
      final targetHeight =
          (target.maxHeight != null && target.maxHeight! < renderHeight)
              ? target.maxHeight!
              : renderHeight;

      Rect rect = Rect.fromLTWH(
        topLeft.dx - target.padding.left,
        topLeft.dy - target.padding.top,
        targetRender.size.width + target.padding.horizontal,
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
          : (Path()
            ..addRRect(
              RRect.fromRectAndCorners(
                rect,
                topLeft: target.customBorderRadius?.topLeft ??
                    Radius.circular(target.borderRadius),
                topRight: target.customBorderRadius?.topRight ??
                    Radius.circular(target.borderRadius),
                bottomLeft: target.customBorderRadius?.bottomLeft ??
                    Radius.circular(target.borderRadius),
                bottomRight: target.customBorderRadius?.bottomRight ??
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
      debugPrint(
        '[SPOTLIGHT] _updateHoles -> targets=${widget.targets.length} extra=${widget.extraHoles?.length ?? 0} holes=${resolvedHoles.length}',
      );
      _lastHoles = resolvedHoles;
      _holes.value = resolvedHoles;

      // Only request a new frame when something actually changed
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  Future<void> hide() async {
    if (!_tracking) return;
    _tracking = false;
    if (_controller.isAnimating) {
      await _controller.reverse();
      return;
    }
    try {
      await _controller.reverse();
    } catch (_) {}
  }

  @override
  void dispose() {
    _tracking = false;
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
          holesPath = Path.combine(
            PathOperation.union,
            holesPath,
            hole.path,
          );
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
                          color: widget.style.scrimColor
                              .withOpacity(_opacityAnimation.value * 0.01),
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
                        scrimColor: widget.style.scrimColor.withOpacity(
                          _opacityAnimation.value * 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SpotlightTouchLayer(
                    holes: holes,
                  ),
                ),
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
