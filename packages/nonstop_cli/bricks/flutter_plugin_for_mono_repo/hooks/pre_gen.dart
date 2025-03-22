import 'dart:async';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  // Check if we're in a mono repo using the shared utility
  context.vars['is_mono_repo'] = await FileUtils.isMonoRepo();
}
