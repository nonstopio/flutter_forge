import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:notifications/notifications.dart';

/// Owns foreground notification work independently of the application view.
class NotificationLifecycle extends StatefulWidget {
  const NotificationLifecycle({
    required this.child,
    required this.logger,
    this.client,
    super.key,
  });

  final Widget child;
  final Logger logger;
  final NotificationClient? client;

  @override
  State<NotificationLifecycle> createState() => _NotificationLifecycleState();
}

class _NotificationLifecycleState extends State<NotificationLifecycle> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: _clearBadge);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await widget.client?.init();
      } catch (error, stackTrace) {
        widget.logger.e(
          'Notification initialization failed',
          error,
          stackTrace,
        );
      }
    });
  }

  Future<void> _clearBadge() async {
    try {
      await widget.client?.clearBadge();
    } catch (error, stackTrace) {
      widget.logger.e('Notification badge clearing failed', error, stackTrace);
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
