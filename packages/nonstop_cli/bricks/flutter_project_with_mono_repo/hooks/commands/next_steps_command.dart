import 'package:cli_core/cli_core.dart' show CliCommand;
import 'package:mason/mason.dart';

/// Prints the handful of things the generator cannot do for you.
final class NextStepsCommand extends CliCommand {
  @override
  Future<void> run(HookContext context) async {
    final String name = context.vars['name'];
    final appName = name.snakeCase;
    final logger = context.logger;

    if (context.vars['firebase'] == true) {
      logger
        ..info('')
        ..warn('Firebase modules are enabled but not configured yet.')
        ..info('  dart pub global activate flutterfire_cli')
        ..info('  cd $appName/apps/$appName && flutterfire configure')
        ..info(
          '  (until then lib/firebase_options.dart throws on purpose)',
        );
    }

    logger
      ..info('')
      ..info('Run the app:')
      ..info('  cd $appName/apps/$appName && flutter run');
  }
}
