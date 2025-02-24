import 'dart:async';

import 'package:mason/mason.dart';

import 'commands/flutter_create_command.dart';
import 'commands/melos_command.dart';

Future<void> run(HookContext context) async {
  final commands = [
    FlutterCreateCommand(),
    MelosCommand(),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
