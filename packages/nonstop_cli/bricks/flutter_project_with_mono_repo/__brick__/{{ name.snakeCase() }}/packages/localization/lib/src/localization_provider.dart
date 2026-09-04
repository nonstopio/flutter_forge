import 'package:flutter/material.dart';
import 'package:localization/messages.i69n.dart';

/// Provides localization utilities for the {{name.titleCase()}} application
class LocalizationProvider {
  static Messages _messages = const Messages();

  /// Get the current messages instance
  static Messages get messages => _messages;

  /// Initialize localization (currently only supports English)
  static void initialize({String locale = 'en'}) {
    // Currently only supports English, future versions will support multiple locales
    _messages = const Messages();
  }

  /// Get messages (currently only supports English)
  static Messages getMessages(String locale) {
    // Currently only supports English, future versions will support multiple locales
    return const Messages();
  }

  /// Get the current locale
  static String get currentLocale => 'en';

  /// Get supported locales (currently only English)
  static List<String> get supportedLocales => ['en'];

  /// Check if a locale is supported
  static bool isLocaleSupported(String locale) {
    return supportedLocales.contains(locale);
  }

  /// Get the best matching locale from a list of preferred locales
  static String getBestMatchingLocale(List<Locale> preferredLocales) {
    for (final locale in preferredLocales) {
      if (isLocaleSupported(locale.languageCode)) {
        return locale.languageCode;
      }
    }
    return 'en'; // Default to English
  }
}
