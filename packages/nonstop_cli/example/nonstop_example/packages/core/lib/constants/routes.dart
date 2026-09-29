/// Paths owned by the app shell itself.
///
/// Feature packages declare their own route constants; these are the ones
/// every app has.
abstract final class CoreRoutes {
  static const String root = '/';
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String profile = '/home/profile';
  static const String error = '/error';
}
