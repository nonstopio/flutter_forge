import 'dart:async';

class NotificationConfig {
  const NotificationConfig({this.onForeground, this.onOpenRoute});

  final FutureOr<void> Function(String title, String body)? onForeground;
  final FutureOr<void> Function(String route)? onOpenRoute;
}

class DefaultNotificationConfig extends NotificationConfig {
  const DefaultNotificationConfig({super.onForeground, super.onOpenRoute});
}
