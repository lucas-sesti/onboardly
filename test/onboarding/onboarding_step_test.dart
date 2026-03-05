import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboardly/onboarding/onboarding_step.dart';

void main() {
  group('OnboardingStep', () {
    late GlobalKey testKey;
    late GlobalKey extraKey1;
    late GlobalKey extraKey2;

    setUp(() {
      testKey = GlobalKey();
      extraKey1 = GlobalKey();
      extraKey2 = GlobalKey();
    });

    test('should create step with required parameters', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test description',
      );

      expect(step.targetKey, testKey);
      expect(step.description, 'Test description');
      expect(step.showNext, true);
      expect(step.showSkip, true);
      expect(step.position, OnboardingTooltipPosition.auto);
      expect(step.tooltipVerticalOffset, 0);
    });

    test('should create step with descriptionWidget instead of description', () {
      final widget = Text('Custom widget');
      final step = OnboardingStep(
        targetKey: testKey,
        descriptionWidget: widget,
      );

      expect(step.descriptionWidget, widget);
      expect(step.description, null);
    });

    test('should assert when neither description nor descriptionWidget is provided', () {
      expect(
        () => OnboardingStep(targetKey: testKey),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should include extraTargetKeys in allTargetKeys', () {
      final step = OnboardingStep(
        targetKey: testKey,
        extraTargetKeys: [extraKey1, extraKey2],
        description: 'Test',
      );

      expect(step.allTargetKeys, [testKey, extraKey1, extraKey2]);
    });

    test('should return only targetKey when no extraTargetKeys', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
      );

      expect(step.allTargetKeys, [testKey]);
    });

    test('isTargetClickable should return true by default', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
      );

      expect(step.isTargetClickable(testKey), true);
      expect(step.isTargetClickable(extraKey1), true);
    });

    test('isTargetClickable should return configured value when targetClickables is set', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        targetClickables: {
          testKey: false,
          extraKey1: true,
        },
      );

      expect(step.isTargetClickable(testKey), false);
      expect(step.isTargetClickable(extraKey1), true);
    });

    test('isTargetClickable should return true for keys not in targetClickables map', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        targetClickables: {
          testKey: false,
        },
      );

      expect(step.isTargetClickable(extraKey1), true);
    });

    test('should create step with custom spotlight padding', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        spotlightHorizontalPadding: 16.0,
      );

      expect(step.spotlightHorizontalPadding, 16.0);
    });

    test('should create step with custom tooltip vertical offset', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        tooltipVerticalOffset: 20.0,
      );

      expect(step.tooltipVerticalOffset, 20.0);
    });

    test('should create step with arrow positions', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        arrowPositions: [ArrowPosition.topLeft, ArrowPosition.bottomRight],
      );

      expect(step.arrowPositions, [ArrowPosition.topLeft, ArrowPosition.bottomRight]);
    });

    test('should create step with arrow anchor keys', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        arrowAnchorKeys: [extraKey1, extraKey2],
      );

      expect(step.arrowAnchorKeys, [extraKey1, extraKey2]);
    });

    test('should create step with custom border radii', () {
      final borderRadius = BorderRadius.circular(8);
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        borderRadii: {
          testKey: borderRadius,
        },
      );

      expect(step.borderRadii?[testKey], borderRadius);
    });

    test('should create step with max heights', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        maxHeights: {
          testKey: 100.0,
          extraKey1: 200.0,
        },
      );

      expect(step.maxHeights?[testKey], 100.0);
      expect(step.maxHeights?[extraKey1], 200.0);
    });

    test('should create step with custom widths', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        customWidths: {
          testKey: 150.0,
        },
      );

      expect(step.customWidths?[testKey], 150.0);
    });

    test('should create step with position set to above', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        position: OnboardingTooltipPosition.above,
      );

      expect(step.position, OnboardingTooltipPosition.above);
    });

    test('should create step with position set to below', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        position: OnboardingTooltipPosition.below,
      );

      expect(step.position, OnboardingTooltipPosition.below);
    });

    test('should create step with position set to center', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        position: OnboardingTooltipPosition.center,
      );

      expect(step.position, OnboardingTooltipPosition.center);
    });

    test('should create step with showNext and showSkip set to false', () {
      final step = OnboardingStep(
        targetKey: testKey,
        description: 'Test',
        showNext: false,
        showSkip: false,
      );

      expect(step.showNext, false);
      expect(step.showSkip, false);
    });
  });

  group('ArrowPosition', () {
    test('should have all arrow position values', () {
      expect(ArrowPosition.values, [
        ArrowPosition.topLeft,
        ArrowPosition.topCenter,
        ArrowPosition.topRight,
        ArrowPosition.bottomLeft,
        ArrowPosition.bottomCenter,
        ArrowPosition.bottomRight,
      ]);
    });
  });

  group('OnboardingTooltipPosition', () {
    test('should have all position values', () {
      expect(OnboardingTooltipPosition.values, [
        OnboardingTooltipPosition.auto,
        OnboardingTooltipPosition.above,
        OnboardingTooltipPosition.below,
        OnboardingTooltipPosition.center,
      ]);
    });
  });
}
