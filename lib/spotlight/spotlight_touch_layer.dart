import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'spotlight_target.dart';

class SpotlightTouchLayer extends SingleChildRenderObjectWidget {
  const SpotlightTouchLayer({
    Key? key,
    required this.holes,
    Widget? child,
  }) : super(key: key, child: child);

  final List<SpotlightHole> holes;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _SpotlightTouchRender(holes: holes);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _SpotlightTouchRender renderObject) {
    renderObject.holes = holes;
  }
}

class _SpotlightTouchRender extends RenderBox {
  _SpotlightTouchRender({required List<SpotlightHole> holes}) : _holes = holes;

  List<SpotlightHole> _holes;

  set holes(List<SpotlightHole> value) {
    _holes = value;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) {
      return false;
    }

    for (final hole in _holes) {
      if (hole.path.contains(position)) {
        // If the hole allows touches through, skip capturing so events reach
        // the underlying content. Otherwise, absorb the touch.
        if (hole.allowTouchThrough) {
          return false;
        }
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }

    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  @override
  void handleEvent(PointerEvent event, covariant HitTestEntry entry) {
    // Intentionally empty: absorbing touches outside the spotlight.
  }
}
