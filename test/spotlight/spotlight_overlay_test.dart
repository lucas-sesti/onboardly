import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboardly/spotlight/spotlight_overlay.dart';
import 'package:onboardly/spotlight/spotlight_target.dart';

void main() {
  group('SpotlightOverlay', () {
    testWidgets('should render spotlight overlay', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should render with multiple targets', (tester) async {
      final key1 = GlobalKey();
      final key2 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(key: key1, height: 100, width: 100),
                    Container(key: key2, height: 100, width: 100),
                  ],
                ),
                SpotlightOverlay(
                  targets: [
                    SpotlightTarget.fromKey(key1),
                    SpotlightTarget.fromKey(key2),
                  ],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should render with custom style', (tester) async {
      final key1 = GlobalKey();

      const customStyle = SpotlightStyle(
        blurSigma: 5,
        scrimColor: Colors.black45,
        animationDuration: Duration(milliseconds: 500),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: customStyle,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should render with extra holes', (tester) async {
      final key1 = GlobalKey();

      final extraHoles = [
        Rect.fromLTWH(200, 200, 100, 100),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: const SpotlightStyle(),
                  extraHoles: extraHoles,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should render with extra hole paths', (tester) async {
      final key1 = GlobalKey();

      final extraHolePaths = [
        Path()..addOval(Rect.fromLTWH(200, 200, 100, 100)),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: const SpotlightStyle(),
                  extraHolePaths: extraHolePaths,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should animate on show', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: const SpotlightStyle(
                    animationDuration: Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Initial frame
      await tester.pump();

      // Animation in progress
      await tester.pump(const Duration(milliseconds: 150));

      // Animation complete
      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should handle hide animation', (tester) async {
      final key1 = GlobalKey();
      final overlayKey = GlobalKey<SpotlightOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  key: overlayKey,
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: const SpotlightStyle(
                    animationDuration: Duration(milliseconds: 300),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);

      // Trigger hide
      await overlayKey.currentState?.hide();
      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should render touch layer', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [SpotlightTarget.fromKey(key1)],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should handle targets with custom border radius', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [
                    SpotlightTarget.fromKey(
                      key1,
                      customBorderRadius: BorderRadius.circular(24),
                    ),
                  ],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should handle targets with custom path', (tester) async {
      final key1 = GlobalKey();
      final customPath = Path()..addOval(Rect.fromLTWH(0, 0, 100, 100));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [
                    SpotlightTarget.fromKey(
                      key1,
                      customPath: customPath,
                    ),
                  ],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should handle targets with max height', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 200, width: 100),
                SpotlightOverlay(
                  targets: [
                    SpotlightTarget.fromKey(
                      key1,
                      maxHeight: 100,
                    ),
                  ],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });

    testWidgets('should handle targets with custom width', (tester) async {
      final key1 = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(key: key1, height: 100, width: 100),
                SpotlightOverlay(
                  targets: [
                    SpotlightTarget.fromKey(
                      key1,
                      customWidth: 150,
                    ),
                  ],
                  style: const SpotlightStyle(),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SpotlightOverlay), findsOneWidget);
    });
  });
}
