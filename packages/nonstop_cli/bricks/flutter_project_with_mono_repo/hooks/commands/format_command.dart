import 'package:cli_core/cli_core.dart' show CliCommand;
import 'package:mason/mason.dart';

import 'checked_process.dart';

/// Formats the generated workspace.
///
/// Templates are rendered from mustache, so the exact line breaks depend on
/// which modules were selected. Running the formatter once here means a fresh
/// project passes its own `melos lint` whatever the answers were.
final class FormatCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];

    await runChecked(
      context,
      startMessage: 'Formatting generated code',
      endMessage: 'Code formatted',
      executable: 'dart',
      arguments: ['format', '.'],
      workingDirectory: name.snakeCase,
    );
  }
}
