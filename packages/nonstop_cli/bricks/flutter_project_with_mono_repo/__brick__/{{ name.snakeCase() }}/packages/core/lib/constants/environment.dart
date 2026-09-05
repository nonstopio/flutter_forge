/// Build-time configuration.
///
/// Every value is a `--dart-define`, so the same binary can be pointed at a
/// different backend without a code change:
///
/// ```sh
/// flutter run --dart-define=BASE_URL=https://staging.example.com
/// ```
class Environment {
  Environment._();

  static const bool useEmulators = bool.fromEnvironment('USE_EMULATORS');

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
