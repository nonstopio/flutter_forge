import 'package:flutter/material.dart';

/// Icons used by the app's primary navigation.
///
/// Swap these for your product's icon set - every navigation surface reads
/// from here so a single edit re-skins the whole shell.
class NavigationIcons {
  const NavigationIcons._();

  static const IconData home = Icons.home_outlined;
  static const IconData homeSelected = Icons.home;

  static const IconData explore = Icons.explore_outlined;
  static const IconData exploreSelected = Icons.explore;

  static const IconData dashboard = Icons.dashboard_outlined;
  static const IconData dashboardSelected = Icons.dashboard;

  static const IconData insights = Icons.trending_up_outlined;
  static const IconData insightsSelected = Icons.trending_up;

  static const IconData profile = Icons.person_outline;
  static const IconData profileSelected = Icons.person;

  static const IconData settings = Icons.settings_outlined;
}
