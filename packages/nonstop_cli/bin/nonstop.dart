import 'dart:io';

import 'package:nonstop_cli/command_runner.dart';

Future<void> main(List<String> args) async {
  exitCode = await NonstopCliCommandRunner().run(args);
  await Future.wait<void>([stdout.flush(), stderr.flush()]);
}
