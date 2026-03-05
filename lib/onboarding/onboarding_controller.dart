import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../spotlight/spotlight_controller.dart';
import '../spotlight/spotlight_target.dart';
import 'onboarding_skip_sheet.dart';
import 'onboarding_step.dart';
import 'onboarding_tooltip.dart';

/// Service that manages the onboarding flow with spotlight effects and tooltips.
///
/// This service orchestrates the display of onboarding steps, each with a
/// spotlight effect highlighting specific UI elements and tooltips providing
/// contextual information to users.
class OnboardingService {
  /// Creates an [OnboardingService] with the given [spotlight] service.
  OnboardingService(this.spotlight);

  /// The spotlight service used to highlight target widgets during onboarding.
  final SpotlightService spotlight;
  static const double _kDefaultSpotlightHorizontalPadding = 8;
  static const double _kDefaultSpotlightVerticalPadding = 8;

  int _currentIndex = 0;
  bool _isActive = false;
  BuildContext? _context;
  void Function(int index)? _onStepChanged;
  VoidCallback? _onFinish;
  VoidCallback? _onSkip;

  // Skip sheet customization
  String? _skipSheetTitle;
  String? _skipSheetContinueButtonText;
  String? _skipSheetSkipButtonText;

  String _nextText = 'OK';
  String _skipText = 'Skip';
  String _finishText = 'Finish';

  OverlayEntry? _tooltipEntry;

  late List<OnboardingStep> steps;

  /// Returns the current onboarding step being displayed.
  OnboardingStep get currentStep => steps[_currentIndex];

  /// Whether the onboarding flow is currently active.
  bool get isActive => _isActive;

  Path? _tooltipPath;
  Rect? _currentTargetRect;
  bool _isSpotlightTransitioning = false;
  bool _hasPendingSpotlightRefresh = false;
  bool _isSkipSheetOpen = false;
  double _defaultSpotlightHorizontalPadding =
      _kDefaultSpotlightHorizontalPadding;
  FlutterExceptionHandler? _originalOnError;

  /// The current target widget's rectangle on screen, or null if not measured.
  Rect? get currentTargetRect => _currentTargetRect;

  /// Whether the skip confirmation sheet is currently open.
  bool get isSkipSheetOpen => _isSkipSheetOpen;

  /// Starts the onboarding flow with the given [onboardingSteps].
  ///
  /// The [context] is used to insert overlay entries for tooltips and spotlights.
  /// Optional callbacks can be provided:
  /// - [onStepChanged]: Called when the user moves to a different step
  /// - [onFinish]: Called when the user completes all steps
  /// - [onSkip]: Called when the user skips the onboarding
  ///
  /// You can customize the skip confirmation sheet with [skipSheetTitle],
  /// [skipSheetContinueButtonText], and [skipSheetSkipButtonText].
  void start(
    BuildContext context,
    List<OnboardingStep> onboardingSteps, {
    void Function(int index)? onStepChanged,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
    double defaultSpotlightHorizontalPadding =
        _kDefaultSpotlightHorizontalPadding,
    String? skipSheetTitle,
    String? skipSheetContinueButtonText,
    String? skipSheetSkipButtonText,
    String nextText = 'OK',
    String skipText = 'Skip',
    String finishText = 'Finish',
  }) {
    // Clean any previous onboarding to avoid duplicate GlobalKeys/overlays.
    dismissSilently();
    _log('start() called with ${onboardingSteps.length} steps');
    if (onboardingSteps.isNotEmpty) {
      _logKeyState('firstStepKey', onboardingSteps.first.targetKey);
    }

    _context = context;
    _onStepChanged = onStepChanged;
    _onFinish = onFinish;
    _onSkip = onSkip;
    _defaultSpotlightHorizontalPadding = defaultSpotlightHorizontalPadding;
    _skipSheetTitle = skipSheetTitle;
    _skipSheetContinueButtonText = skipSheetContinueButtonText;
    _skipSheetSkipButtonText = skipSheetSkipButtonText;
    _nextText = nextText;
    _skipText = skipText;
    _finishText = finishText;
    steps = onboardingSteps;
    if (steps.isEmpty) return;

    _currentIndex = 0;
    _isActive = true;
    _installGlobalKeyDebugHook();
    _currentTargetRect = _measureTargetRect(currentStep.targetKey);
    if (_currentTargetRect != null) {
      _insertTooltipOverlay();
    } else {
      _waitForTargetAndShow();
    }
  }

  void _waitForTargetAndShow() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isActive) return;
      _currentTargetRect = _measureTargetRect(currentStep.targetKey);
      if (_currentTargetRect != null) {
        _insertTooltipOverlay();
      } else {
        // Target still not laid out, retry next frame.
        _waitForTargetAndShow();
      }
    });
  }

  /// Advances to the next onboarding step, or finishes if on the last step.
  void next() {
    if (_currentIndex < steps.length - 1) {
      _tooltipPath = null;
      _currentIndex++;
      _log('next() -> index ${_currentIndex}');
      _onStepChanged?.call(_currentIndex);
      _rebuildTooltip();
    } else {
      finish();
    }
  }

  /// Shows the skip confirmation sheet to the user.
  void skip() => showSkipConfirmation();

  Future<void> showSkipConfirmation() async {
    if (_context == null) return;

    _removeTooltip();
    await spotlight.hide();
    _isSkipSheetOpen = true;

    final bool? shouldSkip = await showModalBottomSheet<bool>(
      context: _context!,
      isScrollControlled: true,
      builder: (context) => OnboardingSkipSheet(
        title: _skipSheetTitle,
        continueButtonText: _skipSheetContinueButtonText,
        skipButtonText: _skipSheetSkipButtonText,
      ),
    );

    _isSkipSheetOpen = false;

    if (!_isActive) return;

    if (shouldSkip == true) {
      _onSkip?.call();
      _cleanup();
    } else {
      final frame = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) => frame.complete());
      await frame.future;

      _currentTargetRect = await _waitForTargetRect(
        currentStep.targetKey,
        maxFrames: 60,
      );
      if (_currentTargetRect == null) {
        _log(
          'showSkipConfirmation(): target not ready after cancel skip, waiting asynchronously',
        );
        _waitForTargetAndShow();
        return;
      }
      _insertTooltipOverlay();
      await _refreshSpotlight();
    }
  }

  /// Completes the onboarding flow and calls the [onFinish] callback.
  void finish() {
    _log('finish() called. active=$_isActive tooltipEntry=$_tooltipEntry');
    _cleanup();
    final callback = _onFinish;
    _onFinish = null;
    _onSkip = null;
    _onStepChanged = null;
    callback?.call();
  }

  /// Dismisses the onboarding without calling any callbacks.
  ///
  /// This is useful for cleaning up state when starting a new onboarding
  /// or when the user navigates away. Set [shouldCleanSkip] to false to
  /// preserve the skip callback.
  void dismissSilently({bool shouldCleanSkip = true}) {
    _log(
      'dismissSilently() called. active=$_isActive tooltipEntry=$_tooltipEntry',
    );
    _cleanup();
    _onFinish = null;
    if (shouldCleanSkip) {
      _onSkip = null;
    }
    _onStepChanged = null;
  }

  void _cleanup() {
    _hideSpotlight();
    _removeTooltip();
    _isActive = false;
    _tooltipPath = null;
    _isSpotlightTransitioning = false;
    _hasPendingSpotlightRefresh = false;
    _context = null;
  }

  void _insertTooltipOverlay() {
    final overlay = _findOverlayState();
    if (overlay == null) return;

    // Ensure we don't insert multiple tooltip entries with the same key.
    _removeTooltip();

    _log('_insertTooltipOverlay(): creating tooltip overlay entry');

    _tooltipEntry = OverlayEntry(
      builder: (ctx) {
        final rect = _currentTargetRect;
        if (rect == null) return const SizedBox.shrink();
        return OnboardingTooltip(
          step: currentStep,
          targetRect: rect,
          showAbove: _decideShowAbove(rect),
          isLastStep: _currentIndex == steps.length - 1,
          onNext: next,
          onSkip: skip,
          onLayout: _updateTooltipRectFromContext,
          nextText: _nextText,
          skipText: _skipText,
          finishText: _finishText,
        );
      },
    );

    overlay.insert(_tooltipEntry!);
  }

  OverlayState? _findOverlayState() {
    if (_context == null) return null;
    return Overlay.of(_context!, rootOverlay: true);
  }

  void _rebuildTooltip() {
    _log('_rebuildTooltip(): entry exists=${_tooltipEntry != null}');
    _currentTargetRect = _measureTargetRect(currentStep.targetKey);
    if (_currentTargetRect != null) {
      _tooltipEntry?.markNeedsBuild();
    } else {
      // New step target not laid out yet, wait for it.
      _waitForTargetAndShow();
    }
  }

  void _removeTooltip() {
    if (_tooltipEntry != null) {
      _log('_removeTooltip(): removing tooltip entry');
    }
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  void _log(String message) {
    // debugPrint('[ONBOARDING] $message');
  }

  void _installGlobalKeyDebugHook() {
    if (_originalOnError != null) return;
    _originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (message.contains('Multiple widgets used the same GlobalKey')) {
        // debugPrint('[SPOTLIGHT][GLOBAL_KEY_ERROR] $message');
        if (details.stack != null) {
          debugPrint('[SPOTLIGHT][GLOBAL_KEY_ERROR] stack:\n${details.stack}');
        }
        // Try to extract more info from diagnostics.
        final exception = details.exception;
        if (exception is FlutterError) {
          for (final diag in exception.diagnostics) {
            debugPrint(
              '[SPOTLIGHT][GLOBAL_KEY_ERROR] diag: ${diag.toStringDeep()}',
            );
          }
        }
        if (details.informationCollector != null) {
          for (final info in details.informationCollector!()) {
            debugPrint(
              '[SPOTLIGHT][GLOBAL_KEY_ERROR] info: ${info.toDescription()}',
            );
          }
        }
        if (steps.isNotEmpty) {
          _logKeyState('currentStepKey', currentStep.targetKey);
        }
      }
      _originalOnError?.call(details);
    };
  }

  void _logKeyState(String name, GlobalKey? key) {
    if (key == null) {
      return;
    }
  }

  Rect? _measureTargetRect(GlobalKey key) {
    final ctx = key.currentContext;
    final renderObject = ctx?.findRenderObject();
    if (renderObject == null) return null;

    if (renderObject is RenderBox) {
      if (!renderObject.hasSize) return null;
      final offset = renderObject.localToGlobal(Offset.zero);
      return offset & renderObject.size;
    } else if (renderObject is RenderSliver) {
      return _measureSliverRect(renderObject);
    } else {
      final ancestorBox = _findAncestorRenderBox(ctx);
      if (ancestorBox != null && ancestorBox.hasSize) {
        final offset = ancestorBox.localToGlobal(Offset.zero);
        return offset & ancestorBox.size;
      }
      return null;
    }
  }

  Rect? _measureSliverRect(RenderSliver sliver) {
    final geometry = sliver.geometry;
    if (geometry == null) return null;

    // debugPrint('geometry: $geometry');
    // debugPrint('sliver: $sliver');

    final viewport = _findAncestorViewport(sliver);
    if (viewport == null) return null;

    // debugPrint('viewport: $viewport');

    final paintOrigin = geometry.paintOrigin;
    final mainAxisExtent = geometry.paintExtent;
    final crossAxisExtent = sliver.constraints.crossAxisExtent;

    // debugPrint('paintOrigin: $paintOrigin');
    // debugPrint('mainAxisExtent: $mainAxisExtent');
    // debugPrint('crossAxisExtent: $crossAxisExtent');

    final paintBounds = Rect.fromLTWH(
      viewport.axis == Axis.vertical ? 0 : paintOrigin,
      viewport.axis == Axis.vertical ? paintOrigin : 0,
      viewport.axis == Axis.vertical ? crossAxisExtent : mainAxisExtent,
      viewport.axis == Axis.vertical ? mainAxisExtent : crossAxisExtent,
    );

    // debugPrint('paintBounds: $paintBounds');

    final matrix = sliver.getTransformTo(null);
    final transformedRect = MatrixUtils.transformRect(matrix, paintBounds);

    // debugPrint('transformedRect: $transformedRect');

    return transformedRect;
  }

  RenderBox? _findAncestorRenderBox(BuildContext? context) {
    if (context == null) return null;
    RenderBox? box;
    context.visitAncestorElements((element) {
      final renderObject = element.renderObject;
      if (renderObject is RenderBox) {
        box = renderObject;
        return false;
      }
      return true;
    });
    return box;
  }

  RenderViewport? _findAncestorViewport(RenderObject renderObject) {
    RenderObject? current = renderObject.parent;
    while (current != null) {
      if (current is RenderViewport) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }

  Future<Rect?> _waitForTargetRect(GlobalKey key, {int maxFrames = 12}) async {
    var rect = _measureTargetRect(key);
    if (rect != null) return rect;

    for (var i = 0; i < maxFrames && _isActive; i++) {
      final frame = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) => frame.complete());
      await frame.future;

      rect = _measureTargetRect(key);
      if (rect != null) return rect;
    }
    return null;
  }

  void _updateTooltipRectFromContext(Path combinedPath) {
    final newBounds = combinedPath.getBounds();
    final lastBounds = _tooltipPath?.getBounds();

    if (newBounds == lastBounds) return;

    _tooltipPath = combinedPath;
    unawaited(_refreshSpotlight());
  }

  bool _decideShowAbove(Rect targetRect) {
    final screenHeight = _context != null
        ? MediaQuery.of(_context!).size.height
        : 0;
    final auto = targetRect.center.dy <= screenHeight / 2;
    switch (currentStep.position) {
      case OnboardingTooltipPosition.above:
        return true;
      case OnboardingTooltipPosition.below:
        return false;
      case OnboardingTooltipPosition.center:
        return false;
      case OnboardingTooltipPosition.auto:
        return auto;
    }
  }

  Future<void> _refreshSpotlight() async {
    if (_isSpotlightTransitioning) {
      _log('_refreshSpotlight(): transition in progress, queueing refresh');
      _hasPendingSpotlightRefresh = true;
      return;
    }
    _isSpotlightTransitioning = true;
    var targetNullRetries = 0;
    try {
      do {
        _hasPendingSpotlightRefresh = false;
        _log(
          '_refreshSpotlight(): target=${currentStep.targetKey} extraHole=${_tooltipPath?.getBounds()}',
        );
        _currentTargetRect = await _waitForTargetRect(
          currentStep.targetKey,
          maxFrames: 20,
        );
        if (_currentTargetRect == null) {
          if (!_isActive) return;
          targetNullRetries++;
          if (targetNullRetries > 120) {
            _log(
              '_refreshSpotlight(): target rect null after retries, aborting',
            );
            return;
          }
          _log('_refreshSpotlight(): target rect null, retrying next frame');
          _hasPendingSpotlightRefresh = true;
          final frame = Completer<void>();
          WidgetsBinding.instance.addPostFrameCallback((_) => frame.complete());
          await frame.future;
          continue;
        }
        targetNullRetries = 0;
        if (spotlight.isShowing) {
          await spotlight.hide();
          // Give the framework a microtask to finalize tree and release the old GlobalKey reservation.
          await Future.microtask(() {});
        }
        final targets = currentStep.allTargetKeys.map((key) {
          final maxHeight = currentStep.maxHeights?[key];
          final customWidth = currentStep.customWidths?[key];
          final borderRadius = currentStep.borderRadii?[key];
          final horizontalPadding =
              currentStep.spotlightHorizontalPadding ??
              _defaultSpotlightHorizontalPadding;
          return SpotlightTarget.fromKey(
            key,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              _kDefaultSpotlightVerticalPadding,
              horizontalPadding,
              _kDefaultSpotlightVerticalPadding,
            ),
            borderRadius: borderRadius == null ? 16 : 0,
            customBorderRadius: borderRadius,
            maxHeight: maxHeight,
            customWidth: customWidth,
            allowTouchThrough: currentStep.isTargetClickable(key),
          );
        }).toList();
        if (_context != null) {
          await spotlight.show(
            _context!,
            targets: targets,
            extraHolePaths: _tooltipPath != null ? [_tooltipPath!] : null,
          );
        }
        _tooltipEntry?.markNeedsBuild();
      } while (_hasPendingSpotlightRefresh && _isActive);
    } finally {
      _isSpotlightTransitioning = false;
    }
  }

  Future<void> _hideSpotlight() async {
    if (spotlight.isShowing) {
      await spotlight.hide();
    }
  }
}
