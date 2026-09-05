/// Paths owned by the app shell itself.
///
/// Feature packages declare their own route constants; these are the ones
/// every app has.
class CoreRoutes {
  CoreRoutes._();

  static const String root = '/';
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String profile = '/home/profile';
  static const String error = '/error';
}
