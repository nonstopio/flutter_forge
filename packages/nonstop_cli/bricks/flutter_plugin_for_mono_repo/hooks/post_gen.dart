import 'dart:async';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';

import 'commands/flutter_plugin_create_command.dart';

Future<void> run(HookContext context, {BaseFlutterCommand? flutter}) async {
  final commands = [
    FlutterPluginCreateCommand(flutter: flutter),
  ];

  for (final command in commands) {
    await command.run(context);
  }
}
