import 'package:dashboard/ui/widgets/index.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.nav.dashboard)),
      body: SafeArea(
        child: PlaceholderTab(
          icon: NavigationIcons.homeSelected,
          title: strings.app.welcome_to_app,
          subtitle: strings.app.description,
        ),
      ),
    );
  }
}
