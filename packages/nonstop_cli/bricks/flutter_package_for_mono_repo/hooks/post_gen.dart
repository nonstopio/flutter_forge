import 'dart:async';

import 'package:mason/mason.dart';

import 'commands/flutter_package_create_command.dart';
import 'commands/melos_command.dart';

Future<void> run(HookContext context) async {
  final commands = [
    FlutterPackageCreateCommand(),
    MelosCommand(),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
