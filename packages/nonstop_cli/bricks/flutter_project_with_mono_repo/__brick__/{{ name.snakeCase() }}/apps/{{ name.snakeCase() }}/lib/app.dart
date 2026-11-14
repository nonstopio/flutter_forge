import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
// Third-party widgets (talker_flutter, firebase_ui_auth) still build on the
// legacy Material library, which needs its own localizations next to material_ui's.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy show DefaultMaterialLocalizations;
import 'package:material_ui/material_ui.dart';
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
          localizationsDelegates: [legacy.DefaultMaterialLocalizations.delegate],
          theme: theme,
          routerConfig: router,
        ),
      ),
    );
  }
}
