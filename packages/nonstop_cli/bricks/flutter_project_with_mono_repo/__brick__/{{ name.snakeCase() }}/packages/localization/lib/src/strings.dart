import 'package:localization/localization.dart';

/// Global strings instance for easy access throughout the application
///
/// Usage:
/// ```dart
/// import 'package:localization/localization.dart';
///
/// // Access strings easily
/// Text(strings.auth.login);
/// Text(strings.generic.ok);
/// Text(strings.profile.name);
/// ```
Messages get strings => LocalizationProvider.messages;
