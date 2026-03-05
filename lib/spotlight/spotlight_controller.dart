import 'package:flutter/material.dart';

import 'spotlight_overlay.dart';
import 'spotlight_target.dart';

/// Service that manages spotlight overlays to highlight specific UI elements.
///
/// The spotlight creates a dimmed overlay with transparent holes around
/// target widgets, drawing user attention to specific parts of the interface.
class SpotlightService extends ChangeNotifier {
  GlobalKey<SpotlightOverlayState>? _overlayKey;
  OverlayEntry? _overlayEntry;

  /// Whether a spotlight overlay is currently being displayed.
  bool get isShowing => _overlayEntry != null;

  /// Shows a spotlight overlay highlighting the given [targets].
  ///
  /// The [context] is used to insert the overlay. You can optionally provide
  /// [extraHoles] or [extraHolePaths] to create additional transparent areas,
  /// and customize the appearance with [style].
  ///
  /// If a spotlight is already showing, this method returns early without
  /// making changes.
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

  /// Hides the currently displayed spotlight with an animation.
  ///
  /// If no spotlight is showing, this method returns early.
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
