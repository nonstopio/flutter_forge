import 'dart:async';
import 'package:mason/mason.dart';
import 'package:cli_utils/cli_utils.dart';

Future<void> run(HookContext context) async {
  // Check if we're in a mono repo using the shared utility
  context.vars['is_mono_repo'] = await FileUtils.isMonoRepo();
}
