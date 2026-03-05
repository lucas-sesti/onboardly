import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboardly/onboarding/onboarding_controller.dart';
import 'package:onboardly/onboarding/onboarding_step.dart';
import 'package:onboardly/spotlight/spotlight_controller.dart';

void main() {
  group('OnboardingService', () {
    late OnboardingService service;
    late SpotlightService spotlightService;

    setUp(() {
      spotlightService = SpotlightService();
      service = OnboardingService(spotlightService);
    });

    test('should initialize with isActive false', () {
      expect(service.isActive, false);
    });

    test('should initialize with isSkipSheetOpen false', () {
      expect(service.isSkipSheetOpen, false);
    });

    testWidgets('should start onboarding with valid steps', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: key1, height: 50, width: 50),
                Container(key: key2, height: 50, width: 50),
              ],
            ),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
        OnboardingStep(targetKey: key2, description: 'Step 2'),
      ];

      final context = tester.element(find.byType(Scaffold));
      service.start(context, steps);

      expect(service.isActive, true);
      expect(service.steps.length, 2);
      expect(service.currentStep, steps[0]);
    });

    testWidgets('should not start with empty steps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      service.start(context, []);

      expect(service.isActive, false);
    });

    testWidgets('should move to next step when next is called', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: key1, height: 50, width: 50),
                Container(key: key2, height: 50, width: 50),
              ],
            ),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
        OnboardingStep(targetKey: key2, description: 'Step 2'),
      ];

      final context = tester.element(find.byType(Scaffold));
      service.start(context, steps);

      await tester.pumpAndSettle();

      service.next();

      expect(service.currentStep, steps[1]);
    });

    testWidgets('should call onStepChanged when moving to next step', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: key1, height: 50, width: 50),
                Container(key: key2, height: 50, width: 50),
              ],
            ),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
        OnboardingStep(targetKey: key2, description: 'Step 2'),
      ];

      int? changedIndex;
      final context = tester.element(find.byType(Scaffold));
      service.start(
        context,
        steps,
        onStepChanged: (index) => changedIndex = index,
      );

      await tester.pumpAndSettle();

      service.next();

      expect(changedIndex, 1);
    });

    testWidgets('should call onFinish when next is called on last step', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 50, width: 50),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
      ];

      bool finishCalled = false;
      final context = tester.element(find.byType(Scaffold));
      service.start(
        context,
        steps,
        onFinish: () => finishCalled = true,
      );

      await tester.pumpAndSettle();

      service.next();

      expect(finishCalled, true);
      expect(service.isActive, false);
    });

    testWidgets('should call finish and set isActive to false', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 50, width: 50),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
      ];

      bool finishCalled = false;
      final context = tester.element(find.byType(Scaffold));
      service.start(
        context,
        steps,
        onFinish: () => finishCalled = true,
      );

      await tester.pumpAndSettle();

      service.finish();

      expect(finishCalled, true);
      expect(service.isActive, false);
    });

    testWidgets('should dismiss silently without calling callbacks', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 50, width: 50),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
      ];

      bool finishCalled = false;
      bool skipCalled = false;

      final context = tester.element(find.byType(Scaffold));
      service.start(
        context,
        steps,
        onFinish: () => finishCalled = true,
        onSkip: () => skipCalled = true,
      );

      await tester.pumpAndSettle();

      service.dismissSilently();

      expect(finishCalled, false);
      expect(skipCalled, false);
      expect(service.isActive, false);
    });

    testWidgets('should use custom skip sheet texts', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 50, width: 50),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
      ];

      final context = tester.element(find.byType(Scaffold));
      service.start(
        context,
        steps,
        skipSheetTitle: 'Custom Title',
        skipSheetContinueButtonText: 'Continue Custom',
        skipSheetSkipButtonText: 'Skip Custom',
      );

      await tester.pumpAndSettle();

      // Trigger skip to show the bottom sheet
      service.skip();
      await tester.pumpAndSettle();

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Continue Custom'), findsOneWidget);
      expect(find.text('Skip Custom'), findsOneWidget);
    });

    test('should notify listeners when state changes', () {
      var notified = false;
      service.addListener(() => notified = true);

      service.notifyListeners();

      expect(notified, true);
    });

    testWidgets('should clean up previous onboarding when starting new one', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: key1, height: 50, width: 50),
                Container(key: key2, height: 50, width: 50),
              ],
            ),
          ),
        ),
      );

      final steps1 = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
      ];

      final steps2 = [
        OnboardingStep(targetKey: key2, description: 'Step 2'),
      ];

      final context = tester.element(find.byType(Scaffold));

      service.start(context, steps1);
      await tester.pumpAndSettle();

      expect(service.isActive, true);
      expect(service.steps, steps1);

      // Start new onboarding should clean previous
      service.start(context, steps2);
      await tester.pumpAndSettle();

      expect(service.isActive, true);
      expect(service.steps, steps2);
    });

    testWidgets('should use custom spotlight horizontal padding', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 50, width: 50),
          ),
        ),
      );

      final steps = [
        OnboardingStep(targetKey: key1, description: 'Step 1'),
      ];

      final context = tester.element(find.byType(Scaffold));
      service.start(
        context,
        steps,
        defaultSpotlightHorizontalPadding: 20.0,
      );

      await tester.pumpAndSettle();

      expect(service.isActive, true);
    });
  });
}
