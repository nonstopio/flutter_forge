import 'package:dashboard/ui/widgets/index.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ExploreTabScreen extends StatelessWidget {
  const ExploreTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: const SafeArea(
        child: PlaceholderTab(
          icon: NavigationIcons.exploreSelected,
          title: 'Explore',
          subtitle: 'Your second tab. Replace this with a real feature.',
        ),
      ),
    );
  }
}
