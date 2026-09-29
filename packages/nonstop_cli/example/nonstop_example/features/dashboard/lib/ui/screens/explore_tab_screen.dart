import 'package:dashboard/ui/widgets/index.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.nav.explore)),
      body: SafeArea(
        child: PlaceholderTab(
          icon: NavigationIcons.exploreSelected,
          title: strings.nav.explore,
          subtitle: strings.nav.explore_placeholder,
        ),
      ),
    );
  }
}
