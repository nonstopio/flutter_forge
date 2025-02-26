import 'dart:async';

import 'package:mason/mason.dart';

import 'commands/flutter_app_create_command.dart';

Future<void> run(HookContext context) async {
  final commands = [
    FlutterAppCreateCommand(),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
