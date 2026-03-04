import 'package:flutter/material.dart';

import 'spotlight_overlay.dart';
import 'spotlight_target.dart';

class SpotlightService extends ChangeNotifier {
  GlobalKey<SpotlightOverlayState>? _overlayKey;
  OverlayEntry? _overlayEntry;

  bool get isShowing => _overlayEntry != null;

  Future<void> show(
    BuildContext context, {
    required List<SpotlightTarget> targets,
    List<Rect>? extraHoles,
    List<Path>? extraHolePaths,
    SpotlightStyle style = const SpotlightStyle(),
  }) async {
    if (_overlayEntry != null) {
      return;
    }
    if (targets.isEmpty) {
      return;
    }

    await _removeCurrentOverlay(animate: false);

    final overlayState = _findOverlayState(context);
    if (overlayState == null) {
      return;
    }

    _overlayKey = GlobalKey<SpotlightOverlayState>();
    _overlayEntry = OverlayEntry(
      builder: (_) => SpotlightOverlay(
        key: _overlayKey,
        targets: targets,
        extraHoles: extraHoles,
        extraHolePaths: extraHolePaths,
        style: style,
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  Future<void> hide() async {
    if (_overlayEntry == null) {
      return;
    }
    await _removeCurrentOverlay(animate: true);
  }

  Future<void> _removeCurrentOverlay({required bool animate}) async {
    final entry = _overlayEntry;
    if (entry == null) return;

    if (animate) {
      await _overlayKey?.currentState?.hide();
    }

    entry.remove();
    _overlayEntry = null;
    _overlayKey = null;
  }

  OverlayState? _findOverlayState(BuildContext context) {
    return Overlay.of(context, rootOverlay: true);
  }
}
