import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

/// The application view. Its owner creates and disposes the router.
class App extends StatelessWidget {
  const App({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return GlobalEventChannelProvider(
      child: DesignSystemWrapper(
        builder: (context, theme) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: strings.app.name,
          theme: theme,
          routerConfig: router,
        ),
      ),
    );
  }
}
