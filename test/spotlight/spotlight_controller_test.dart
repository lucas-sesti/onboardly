import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboardly/spotlight/spotlight_controller.dart';
import 'package:onboardly/spotlight/spotlight_target.dart';

void main() {
  group('SpotlightService', () {
    late SpotlightService service;

    setUp(() {
      service = SpotlightService();
    });

    test('should initialize with isShowing false', () {
      expect(service.isShowing, false);
    });

    testWidgets('should show spotlight with targets', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 100, width: 100),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
      ];

      await service.show(context, targets: targets);
      await tester.pumpAndSettle();

      expect(service.isShowing, true);
    });

    testWidgets('should not show spotlight with empty targets', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));

      await service.show(context, targets: []);
      await tester.pumpAndSettle();

      expect(service.isShowing, false);
    });

    testWidgets('should hide spotlight', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 100, width: 100),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
      ];

      await service.show(context, targets: targets);
      await tester.pumpAndSettle();

      expect(service.isShowing, true);

      await service.hide();
      await tester.pumpAndSettle();

      expect(service.isShowing, false);
    });

    testWidgets('should show spotlight with custom style', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 100, width: 100),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
      ];

      const customStyle = SpotlightStyle(
        blurSigma: 5,
        scrimColor: Colors.black45,
        animationDuration: Duration(milliseconds: 500),
      );

      await service.show(
        context,
        targets: targets,
        style: customStyle,
      );
      await tester.pumpAndSettle();

      expect(service.isShowing, true);
    });

    testWidgets('should show spotlight with extra holes', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 100, width: 100),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
      ];

      final extraHoles = [
        Rect.fromLTWH(200, 200, 100, 100),
      ];

      await service.show(
        context,
        targets: targets,
        extraHoles: extraHoles,
      );
      await tester.pumpAndSettle();

      expect(service.isShowing, true);
    });

    testWidgets('should show spotlight with extra hole paths', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 100, width: 100),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
      ];

      final extraHolePaths = [
        Path()..addOval(Rect.fromLTWH(200, 200, 100, 100)),
      ];

      await service.show(
        context,
        targets: targets,
        extraHolePaths: extraHolePaths,
      );
      await tester.pumpAndSettle();

      expect(service.isShowing, true);
    });

    testWidgets('should not show spotlight again if already showing', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(key: key1, height: 100, width: 100),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
      ];

      await service.show(context, targets: targets);
      await tester.pumpAndSettle();

      expect(service.isShowing, true);

      // Try to show again
      await service.show(context, targets: targets);
      await tester.pumpAndSettle();

      // Should still be showing (not re-created)
      expect(service.isShowing, true);
    });

    testWidgets('should handle hide when not showing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      expect(service.isShowing, false);

      await service.hide();
      await tester.pumpAndSettle();

      expect(service.isShowing, false);
    });

    testWidgets('should show multiple targets', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(key: key1, height: 100, width: 100),
                Container(key: key2, height: 100, width: 100),
              ],
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(Scaffold));
      final targets = [
        SpotlightTarget.fromKey(key1),
        SpotlightTarget.fromKey(key2),
      ];

      await service.show(context, targets: targets);
      await tester.pumpAndSettle();

      expect(service.isShowing, true);
    });
  });
}
