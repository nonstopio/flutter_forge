import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

void main() {
  test('locale matching selects supported language or defaults to English', () {
    expect(LocalizationProvider.getMessages('en'), isA<Messages>());
    expect(
      LocalizationProvider.getBestMatchingLocale([
        const Locale('es'),
        const Locale('en', 'US'),
      ]),
      'en',
    );
    expect(
      LocalizationProvider.getBestMatchingLocale([const Locale('es')]),
      'en',
    );
    expect(LocalizationProvider.getBestMatchingLocale([]), 'en');
  });
  group('LocalizationProvider Tests', () {
    test('should initialize with default locale', () {
      LocalizationProvider.initialize();
      expect(LocalizationProvider.currentLocale, 'en');
    });

    test('should return Messages instance', () {
      final messages = LocalizationProvider.messages;
      expect(messages, isA<Messages>());
    });

    test('should return supported locales', () {
      final locales = LocalizationProvider.supportedLocales;
      expect(locales, contains('en'));
    });

    test('should check if locale is supported', () {
      expect(LocalizationProvider.isLocaleSupported('en'), true);
      expect(LocalizationProvider.isLocaleSupported('es'), false);
    });
  });
}
