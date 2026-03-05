import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboardly/onboarding/onboarding_step.dart';
import 'package:onboardly/onboarding/onboarding_tooltip.dart';

void main() {
  group('OnboardingTooltip', () {
    late GlobalKey targetKey;

    setUp(() {
      targetKey = GlobalKey();
    });

    testWidgets('should render tooltip with description', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test description',
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('should render tooltip with custom description widget', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        descriptionWidget: const Row(
          children: [
            Icon(Icons.info),
            SizedBox(width: 8),
            Text('Custom widget'),
          ],
        ),
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('Custom widget'), findsOneWidget);
    });

    testWidgets('should show OK button when showNext is true', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showNext: true,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('should not show OK button when showNext is false', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showNext: false,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('OK'), findsNothing);
    });

    testWidgets('should show skip button when showSkip is true', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showSkip: true,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('should show Finish text on skip button when isLastStep is true', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showSkip: true,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: true,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('Finish'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('should call onNext when OK button is tapped', (tester) async {
      var nextCalled = false;
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showNext: true,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () => nextCalled = true,
              onSkip: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(nextCalled, true);
    });

    testWidgets('should call onSkip when skip button is tapped', (tester) async {
      var skipCalled = false;
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showSkip: true,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () => skipCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(skipCalled, true);
    });

    testWidgets('should call onNext when Finish button is tapped on last step', (tester) async {
      var nextCalled = false;
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showSkip: true,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: true,
              onNext: () => nextCalled = true,
              onSkip: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(nextCalled, true);
    });

    testWidgets('should not show skip button when showSkip is false', (tester) async {
      final step = OnboardingStep(
        targetKey: targetKey,
        description: 'Test',
        showSkip: false,
      );

      final targetRect = Rect.fromLTWH(100, 100, 100, 100);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnboardingTooltip(
              step: step,
              targetRect: targetRect,
              showAbove: false,
              isLastStep: false,
              onNext: () {},
              onSkip: () {},
            ),
          ),
        ),
      );

      expect(find.text('Skip'), findsNothing);
    });
  });

  group('TooltipArrow', () {
    testWidgets('should render arrow pointing up', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TooltipArrow(
              pointUp: true,
              color: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(TooltipArrow), findsOneWidget);
    });

    testWidgets('should render arrow pointing down', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TooltipArrow(
              pointUp: false,
              color: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(TooltipArrow), findsOneWidget);
    });

    testWidgets('should render arrow with custom color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TooltipArrow(
              pointUp: true,
              color: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.byType(TooltipArrow), findsOneWidget);
    });
  });
}
