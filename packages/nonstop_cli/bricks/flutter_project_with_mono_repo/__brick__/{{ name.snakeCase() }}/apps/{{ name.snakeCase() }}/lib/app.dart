import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
{{#notifications}}import 'package:di/di.dart';
{{/notifications}}import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
{{#notifications}}import 'package:notifications/notifications.dart';
{{/notifications}}import 'package:{{name.snakeCase()}}/router/router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
{{#notifications}}  late final AppLifecycleListener _lifecycleListener;

{{/notifications}}  @override
  void initState() {
    super.initState();
{{#notifications}}    // Asking for notification permission needs a foreground surface, so this
    // runs from the first frame rather than from bootstrap. Move it behind
    // sign-in once you would rather ask a user who has committed to the app.
    _lifecycleListener = AppLifecycleListener(onResume: _clearBadge);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final logger = di.get<Logger>();
      try {
        await di.get<NotificationClient>().init();
      } catch (e, s) {
        logger.e('Failed to initialize NotificationClient', e, s);
      }
    });
{{/notifications}}  }
{{#notifications}}
  void _clearBadge() {
    final logger = di.get<Logger>();
    try {
      di.get<NotificationClient>().clearBadge();
    } catch (e, s) {
      logger.e('Failed to clear badge on app resume', e, s);
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }
{{/notifications}}
  @override
  Widget build(BuildContext context) {
    return GlobalEventChannelProvider(
      child: DesignSystemWrapper(
        builder: (context, theme) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: strings.app.name,
          theme: theme,
          routeInformationParser: AppRouter.routeInformationParser,
          routeInformationProvider: AppRouter.routeInformationProvider,
          routerDelegate: AppRouter.routerDelegate,
        ),
      ),
    );
  }
}
