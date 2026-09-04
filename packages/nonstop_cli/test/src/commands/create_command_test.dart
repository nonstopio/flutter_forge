import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nonstop_cli/commands/commands.dart';
import 'package:nonstop_cli/commands/create/modules.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

/// Parses [args] through the real `create` parser so the tests exercise the
/// same flag definitions users type.
Map<String, bool> modulesFor(List<String> args) {
  final command = CreateCommand(logger: _MockLogger())
    ..argResultOverrides = null;
  command.argResultOverrides = command.argParser.parse(args);
  return command.selectedModules();
}

void main() {
  group('create module selection', () {
    test('falls back to the recommended set with --defaults', () {
      final modules = modulesFor(['--defaults', 'my_app']);

      for (final module in templateModules) {
        expect(
          modules[module.key],
          module.defaultValue,
          reason: module.key,
        );
      }
    });

    test('explicit flags win over the defaults', () {
      final modules = modulesFor([
        '--defaults',
        '--no-network',
        '--no-notifications',
        '--firestore',
        'my_app',
      ]);

      expect(modules['network'], isFalse);
      expect(modules['firestore'], isTrue);
    });

    test('notifications pull in the network package they post tokens to', () {
      final modules = modulesFor(['--defaults', '--no-network', 'my_app']);

      expect(modules['notifications'], isTrue);
      // notifications imports package:network, so it cannot be dropped.
      expect(modules['network'], isTrue);
    });

    test('developer tools pull in feature flags', () {
      final modules = modulesFor([
        '--defaults',
        '--developer',
        '--no-feature-flags',
        'my_app',
      ]);

      expect(modules['feature_flags'], isTrue);
    });

    test('every module can be switched off together', () {
      final modules = modulesFor([
        for (final module in templateModules) '--no-${module.flag}',
        'my_app',
      ]);

      expect(modules.values, everyElement(isFalse));
    });
  });
}
