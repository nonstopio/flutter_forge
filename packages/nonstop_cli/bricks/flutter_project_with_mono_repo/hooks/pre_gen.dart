import 'dart:async';
import 'dart:io';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';

import 'commands/checked_process.dart';
import 'commands/flutter_create_command.dart';
import 'commands/module_vars.dart';

Future<void> run(HookContext context,
    {ProcessRunner runProcess = Process.run}) async {
  context.vars['is_mono_repo'] = await FileUtils.isMonoRepo();

  // Turn the module answers into the `*_dir` path variables the brick uses to
  // include or skip whole directories, and derive `firebase`.
  resolveModuleVars(context);

  // The app is scaffolded before generation so the brick's `lib/` and
  // `pubspec.yaml` land on top of what `flutter create` produced.
  await FlutterCreateCommand(runProcess: runProcess).run(context);
}
