import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onboardly/spotlight/spotlight_target.dart';

void main() {
  group('SpotlightTarget', () {
    late GlobalKey testKey;

    setUp(() {
      testKey = GlobalKey();
    });

    test('should create target with default values', () {
      final target = SpotlightTarget.fromKey(testKey);

      expect(target.key, testKey);
      expect(target.padding, const EdgeInsets.all(8));
      expect(target.borderRadius, 16);
      expect(target.customBorderRadius, null);
      expect(target.customPath, null);
      expect(target.maxHeight, null);
      expect(target.customWidth, null);
      expect(target.allowTouchThrough, true);
    });

    test('should create target with custom padding', () {
      final target = SpotlightTarget.fromKey(
        testKey,
        padding: const EdgeInsets.all(16),
      );

      expect(target.padding, const EdgeInsets.all(16));
    });

    test('should create target with custom border radius', () {
      final target = SpotlightTarget.fromKey(
        testKey,
        borderRadius: 24,
      );

      expect(target.borderRadius, 24);
    });

    test('should create target with custom BorderRadius', () {
      final customBorderRadius = BorderRadius.circular(12);
      final target = SpotlightTarget.fromKey(
        testKey,
        customBorderRadius: customBorderRadius,
      );

      expect(target.customBorderRadius, customBorderRadius);
    });

    test('should create target with custom path', () {
      final customPath = Path()..addOval(Rect.fromLTWH(0, 0, 100, 100));
      final target = SpotlightTarget.fromKey(
        testKey,
        customPath: customPath,
      );

      expect(target.customPath, customPath);
    });

    test('should create target with max height', () {
      final target = SpotlightTarget.fromKey(
        testKey,
        maxHeight: 200,
      );

      expect(target.maxHeight, 200);
    });

    test('should create target with custom width', () {
      final target = SpotlightTarget.fromKey(
        testKey,
        customWidth: 300,
      );

      expect(target.customWidth, 300);
    });

    test('should create target with allowTouchThrough set to false', () {
      final target = SpotlightTarget.fromKey(
        testKey,
        allowTouchThrough: false,
      );

      expect(target.allowTouchThrough, false);
    });
  });

  group('SpotlightStyle', () {
    test('should create style with default values', () {
      const style = SpotlightStyle();

      expect(style.blurSigma, 2);
      expect(style.scrimColor, const Color.fromARGB(60, 0, 0, 0));
      expect(style.animationDuration, const Duration(milliseconds: 300));
    });

    test('should create style with custom blur sigma', () {
      const style = SpotlightStyle(blurSigma: 5);

      expect(style.blurSigma, 5);
    });

    test('should create style with custom scrim color', () {
      const style = SpotlightStyle(scrimColor: Colors.black54);

      expect(style.scrimColor, Colors.black54);
    });

    test('should create style with custom animation duration', () {
      const style = SpotlightStyle(animationDuration: Duration(milliseconds: 500));

      expect(style.animationDuration, const Duration(milliseconds: 500));
    });
  });

  group('SpotlightHole', () {
    test('should create hole with required parameters', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path = Path()..addRect(rect);

      final hole = SpotlightHole(
        rect: rect,
        path: path,
      );

      expect(hole.rect, rect);
      expect(hole.path, path);
      expect(hole.allowTouchThrough, true);
    });

    test('should create hole with allowTouchThrough set to false', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path = Path()..addRect(rect);

      final hole = SpotlightHole(
        rect: rect,
        path: path,
        allowTouchThrough: false,
      );

      expect(hole.allowTouchThrough, false);
    });

    test('should be equal when rect and allowTouchThrough are the same', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path1 = Path()..addRect(rect);
      final path2 = Path()..addRect(rect);

      final hole1 = SpotlightHole(rect: rect, path: path1);
      final hole2 = SpotlightHole(rect: rect, path: path2);

      expect(hole1, hole2);
    });

    test('should not be equal when rect is different', () {
      final rect1 = Rect.fromLTWH(0, 0, 100, 100);
      final rect2 = Rect.fromLTWH(0, 0, 200, 200);
      final path1 = Path()..addRect(rect1);
      final path2 = Path()..addRect(rect2);

      final hole1 = SpotlightHole(rect: rect1, path: path1);
      final hole2 = SpotlightHole(rect: rect2, path: path2);

      expect(hole1, isNot(hole2));
    });

    test('should not be equal when allowTouchThrough is different', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path1 = Path()..addRect(rect);
      final path2 = Path()..addRect(rect);

      final hole1 = SpotlightHole(rect: rect, path: path1, allowTouchThrough: true);
      final hole2 = SpotlightHole(rect: rect, path: path2, allowTouchThrough: false);

      expect(hole1, isNot(hole2));
    });

    test('should have same hashCode when equal', () {
      final rect = Rect.fromLTWH(0, 0, 100, 100);
      final path1 = Path()..addRect(rect);
      final path2 = Path()..addRect(rect);

      final hole1 = SpotlightHole(rect: rect, path: path1);
      final hole2 = SpotlightHole(rect: rect, path: path2);

      expect(hole1.hashCode, hole2.hashCode);
    });
  });
}
