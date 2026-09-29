import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key, required this.logger});

  final Logger logger;

  @override
  Widget build(BuildContext context) {
    if (logger.logger case final Talker talker) {
      return TalkerScreen(talker: talker);
    }
    return Scaffold(body: Center(child: Text(strings.developer.no_viewer)));
  }
}
