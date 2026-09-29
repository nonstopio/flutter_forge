import 'package:flutter/material.dart';
import 'package:localization/messages.i69n.dart';

/// Provides localization utilities for the {{name.titleCase()}} application.
///
/// Only English ships today. To add a locale, add
/// `messages_<code>.i69n.yaml`, list the code under `locales` in `build.yaml`,
/// regenerate, add it to [supportedLocales] and pick its generated messages
/// class in [messages].
class LocalizationProvider {
  /// The messages for the current (English) locale.
  static Messages get messages => const Messages();

  /// The current locale.
  static String get currentLocale => 'en';

  /// Locales with generated messages.
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
