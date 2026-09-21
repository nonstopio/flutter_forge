import 'dart:async';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';

import 'commands/flutter_package_create_command.dart';

Future<void> run(HookContext context, {BaseFlutterCommand? flutter}) async {
  final commands = [
    FlutterPackageCreateCommand(flutter: flutter),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
