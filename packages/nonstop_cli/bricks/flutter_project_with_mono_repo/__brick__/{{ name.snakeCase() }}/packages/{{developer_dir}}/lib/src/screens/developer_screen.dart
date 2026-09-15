import 'package:core/core.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = di.get<Logger>().logger;
    if (logger is Talker) return TalkerScreen(talker: logger);
    return const Scaffold(
      body: Center(child: Text('This logger has no interactive viewer.')),
    );
  }
}
