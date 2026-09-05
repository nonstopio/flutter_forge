import 'package:flutter_test/flutter_test.dart';
import 'package:localization/localization.dart';

void main() {
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
