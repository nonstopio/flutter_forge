import 'package:core/core.dart';
// talker_flutter still builds on the legacy Material library, which needs its own
// localizations next to material_ui's.
// ignore: deprecated_member_use
import 'package:flutter/material.dart'
    as legacy
    show DefaultMaterialLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:localization/localization.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key, required this.logger});

  final Logger logger;

  @override
  Widget build(BuildContext context) {
    if (logger.logger case final Talker talker) {
      return Localizations.override(
        context: context,
        delegates: [legacy.DefaultMaterialLocalizations.delegate],
        child: TalkerScreen(talker: talker),
      );
    }
    return Scaffold(body: Center(child: Text(strings.developer.no_viewer)));
  }
}
