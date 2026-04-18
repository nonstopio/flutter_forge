import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:connectivity_wrapper/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Constants', () {
    test('DEFAULT_PORT is 53', () {
      expect(DEFAULT_PORT, 53);
    });

    test('DEFAULT_TIMEOUT is 5 seconds', () {
      expect(DEFAULT_TIMEOUT, const Duration(seconds: 5));
    });

    test('DEFAULT_INTERVAL is 2 seconds', () {
      expect(DEFAULT_INTERVAL, const Duration(seconds: 2));
    });

    test('defaultHeight is 40', () {
      expect(defaultHeight, 40.0);
    });

    test('defaultPadding is 8', () {
      expect(defaultPadding, const EdgeInsets.all(8.0));
    });

    test('disconnectedMessage is non-empty', () {
      expect(disconnectedMessage, isNotEmpty);
    });

    test('defaultMessageStyle has expected values', () {
      expect(defaultMessageStyle.fontSize, 15.0);
      expect(defaultMessageStyle.color, Colors.white);
    });
  });

  group('PositionOnScreenExtention', () {
    test('isTOP / isBOTTOM', () {
      expect(PositionOnScreen.TOP.isTOP, isTrue);
      expect(PositionOnScreen.TOP.isBOTTOM, isFalse);
      expect(PositionOnScreen.BOTTOM.isTOP, isFalse);
      expect(PositionOnScreen.BOTTOM.isBOTTOM, isTrue);
    });

    test('top returns 0 when TOP and offline', () {
      expect(PositionOnScreen.TOP.top(40, true), 0);
    });

    test('top returns -height when TOP and online', () {
      expect(PositionOnScreen.TOP.top(40, false), -40);
    });

    test('top returns null when not TOP', () {
      expect(PositionOnScreen.BOTTOM.top(40, true), isNull);
      expect(PositionOnScreen.BOTTOM.top(40, false), isNull);
    });

    test('bottom returns 0 when BOTTOM and offline', () {
      expect(PositionOnScreen.BOTTOM.bottom(40, true), 0);
    });

    test('bottom returns -height when BOTTOM and online', () {
      expect(PositionOnScreen.BOTTOM.bottom(40, false), -40);
    });

    test('bottom returns null when not BOTTOM', () {
      expect(PositionOnScreen.TOP.bottom(40, true), isNull);
      expect(PositionOnScreen.TOP.bottom(40, false), isNull);
    });
  });
}
