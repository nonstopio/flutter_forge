import 'dart:async';

import 'package:mason/mason.dart';

import 'commands/format_command.dart';
import 'commands/melos_command.dart';
import 'commands/next_steps_command.dart';

Future<void> run(HookContext context) async {
  final commands = [
    FormatCommand(),
    MelosCommand(),
    NextStepsCommand(),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
