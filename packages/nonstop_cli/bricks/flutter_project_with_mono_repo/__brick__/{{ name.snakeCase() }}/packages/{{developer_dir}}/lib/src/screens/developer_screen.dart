import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TalkerScreen(talker: di.get<Logger>().logger as Talker);
  }
}
