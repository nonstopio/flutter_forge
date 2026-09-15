import 'package:mason/mason.dart' as mason;
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nonstop_cli/commands/commands.dart';
import 'package:nonstop_cli/commands/create/modules.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockGenerator extends Mock implements mason.MasonGenerator {}

/// Parses [args] through the real `create` parser so the tests exercise the
/// same flag definitions users type.
Map<String, bool> modulesFor(List<String> args) {
  final command = CreateCommand(logger: _MockLogger())
    ..argResultOverrides = null;
  command.argResultOverrides = command.argParser.parse(args);
  return command.selectedModules();
}

void main() {
  test('generation uses the bundle shipped with the selected CLI template',
      () async {
    final generator = _MockGenerator();
    mason.MasonBundle? selected;
    final command = CreateCommand(
        logger: _MockLogger(),
        generatorFromBundle: (bundle) async {
          selected = bundle;
          return generator;
        });
    command.argResultOverrides =
        command.argParser.parse(['--defaults', 'example']);
    expect(await command.createGenerator(), same(generator));
    expect(selected?.name, 'flutter_project_with_mono_repo');
    expect(selected?.files, isNotEmpty);
  });
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
