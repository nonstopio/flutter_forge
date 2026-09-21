import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';

import 'commands/checked_process.dart';
import 'commands/format_command.dart';
import 'commands/melos_command.dart';
import 'commands/next_steps_command.dart';

Future<void> run(HookContext context,
    {ProcessRunner runProcess = Process.run}) async {
  final commands = [
    MelosCommand(runProcess: runProcess),
    FormatCommand(runProcess: runProcess),
    NextStepsCommand(),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
