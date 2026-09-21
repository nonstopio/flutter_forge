import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('coverage_gate', Path(__file__).resolve().parents[1] / 'coverage.py')
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)


class CoverageGateTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name).resolve()
        self.package = self.root / 'packages/example'
        (self.package / 'lib').mkdir(parents=True)
        (self.package / 'lib/example.dart').write_text('int value() => 1;\n')
        (self.package / 'test').mkdir()
        (self.package / 'test/example_test.dart').write_text('void main() {}\n')
        (self.package / 'coverage').mkdir()
        self.entry = {'name': 'example', 'path': str(self.package)}

    def tearDown(self):
        self.temp.cleanup()

    def report(self, text):
        (self.package / 'coverage/lcov.info').write_text(text)
        return gate.run_package(self.entry, self.root, report_only=True)

    def test_uncovered_line_fails_even_when_percentage_would_round_to_100(self):
        text = 'SF:lib/example.dart\n' + ''.join(f'DA:{n},1\n' for n in range(1, 10001)) + 'DA:10001,0\nend_of_record\n'
        result = self.report(text)
        self.assertEqual(result['status'], 'failed')
        self.assertEqual(result['uncovered'], {'lib/example.dart': [10001]})

    def test_missing_tests_missing_report_and_empty_report_fail(self):
        self.assertEqual(gate.run_package(self.entry, self.root, True)['reason'], 'Coverage report missing')
        self.assertEqual(self.report('')['reason'], 'Empty coverage report')
        (self.package / 'test/example_test.dart').unlink()
        self.assertEqual(self.report('SF:lib/example.dart\nDA:1,1\n')['reason'], 'No unit tests found')

    def test_only_owned_sources_count_and_duplicate_records_merge(self):
        result = self.report('SF:lib/example.dart\nDA:1,0\nend_of_record\nSF:lib/example.dart\nDA:1,2\nend_of_record\nSF:test/example_test.dart\nDA:1,0\nend_of_record\n')
        self.assertEqual((result['status'], result['hit'], result['lines']), ('passed', 1, 1))

    def test_missing_executable_library_cannot_silently_reduce_denominator(self):
        (self.package / 'lib/missing.dart').write_text('int missing() => 1;')
        result = self.report('SF:lib/example.dart\nDA:1,1\nend_of_record\n')
        self.assertEqual(result['status'], 'failed')
        self.assertEqual(result['missing_sources'], ['lib/missing.dart'])

    def test_only_verified_declarations_can_be_absent_from_vm_coverage(self):
        declarations = """// Documentation
library constants;
import 'package:foo/foo.dart';
export 'foo.dart' show Foo;
const Map<String, dynamic> values = {};
class Keys { static const String name = 'name'; }
enum Mode { first, second, }
extension Empty on Function {}
"""
        self.assertTrue(gate.declaration_only(declarations))
        for executable in ['void work() {}', 'int work() => 1;', 'final value = 1;',
                           'class Value { const Value({this.number = 1}); final int number; }']:
            self.assertFalse(gate.declaration_only(executable), executable)
        (self.package / 'lib/constants.dart').write_text(declarations)
        self.assertEqual(self.report('SF:lib/example.dart\nDA:1,1\nend_of_record\n')['status'], 'passed')

    def test_failed_test_run_restores_preexisting_generated_fixture(self):
        (self.package / 'pubspec.yaml').write_text('name: example\n')
        fixture = self.package / 'test/full_coverage_test.dart'
        fixture.write_text('original contents')
        with patch.object(gate, 'command', return_value=False) as run:
            result = gate.run_package(self.entry, self.root)
        self.assertEqual(result['status'], 'failed')
        self.assertIn('Tests failed', result['reason'])
        self.assertEqual(fixture.read_text(), 'original contents')
        self.assertIn('test/full_coverage_test.dart', run.call_args.args[0])
        self.assertNotIn('test/example_test.dart', run.call_args.args[0])

    def test_hooks_include_commands_but_not_tests_or_nested_templates(self):
        hooks = self.root / 'hooks'
        (hooks / 'commands').mkdir(parents=True)
        (hooks / 'test').mkdir()
        for relative in ['pre_gen.dart', 'commands/create.dart', 'test/example_test.dart']:
            (hooks / relative).write_text('void main() {}')
        self.assertEqual([p.relative_to(hooks).as_posix() for p in gate.sources(hooks, self.root)], ['commands/create.dart', 'pre_gen.dart'])

    def test_package_root_entrypoints_are_owned(self):
        (self.package / 'main.dart').write_text('void main() {}')
        (self.package / 'tool').mkdir()
        (self.package / 'tool/verify.dart').write_text('void main() {}')
        self.assertEqual([p.relative_to(self.package).as_posix() for p in gate.sources(self.package, self.root)], ['lib/example.dart', 'main.dart', 'tool/verify.dart'])

    def test_fixture_imports_all_sources_and_calls_real_tests(self):
        (self.package / 'pubspec.yaml').write_text('name: example\ndependencies:\n  flutter:\n    sdk: flutter\n')
        (self.package / 'lib/unused.dart').write_text('int unused() => 2;')
        (self.package / 'main.dart').write_text('void main() {}')
        cache = self.package / 'build/test_cache/stale.dill'
        cache.parent.mkdir(parents=True)
        cache.write_text('old kernel')
        other_build = self.package / 'build/keep.txt'
        other_build.write_text('unrelated artifact')
        def inspect(args, package, log, env):
            self.assertFalse(cache.exists())
            self.assertEqual(other_build.read_text(), 'unrelated artifact')
            fixture = (package / 'test/full_coverage_test.dart').read_text()
            self.assertIn("import 'package:example/unused.dart'", fixture)
            self.assertIn("import '../main.dart'", fixture)
            self.assertIn('original_tests.main()', fixture)
            self.assertNotIn('--coverage-package=^$', args)
            (package / 'coverage/lcov.info').write_text('SF:lib/example.dart\nDA:1,1\nend_of_record\nSF:lib/unused.dart\nDA:1,0\nend_of_record\nSF:main.dart\nDA:1,1\nend_of_record\n')
            return True
        with patch.object(gate, 'command', side_effect=inspect), patch.object(gate, 'flutter_command', return_value=['flutter', 'test']):
            result = gate.run_package(self.entry, self.root)
        self.assertEqual(result['status'], 'failed')
        self.assertEqual(result['uncovered'], {'lib/unused.dart': [1]})
        self.assertFalse((self.package / 'test/full_coverage_test.dart').exists())

    def test_flutter_driver_uses_installed_sdk_without_changing_it(self):
        sdk = self.root / 'sdk'
        config = sdk / 'packages/flutter_tools/.dart_tool/package_config.json'
        config.parent.mkdir(parents=True)
        config.write_text('{}')
        env = {'FLUTTER_ROOT': str(sdk)}
        with patch.object(gate.shutil, 'which', return_value=str(sdk / 'bin/flutter')):
            args = gate.flutter_command(self.package / 'coverage', env)
        self.assertEqual(args[0], str(sdk / 'bin/cache/dart-sdk/bin/dart'))
        self.assertEqual(args[1], f'--packages={config}')
        driver = Path(args[2]).read_text()
        self.assertIn('watcher.libraryNames = null;', driver)
        self.assertIn('Function.apply(const FlutterTestRunner().runTests', driver)
        self.assertEqual(config.read_text(), '{}')

    def test_command_timeout_returns_failure_and_writes_diagnostic(self):
        with (self.package / 'timeout.log').open('wb') as log:
            started = time.monotonic()
            result = gate.command([sys.executable, '-c', 'import time; time.sleep(30)'], self.package, log, os.environ.copy(), timeout_seconds=0.1)
        self.assertFalse(result)
        self.assertLess(time.monotonic() - started, 3)
        self.assertIn('timed out', (self.package / 'timeout.log').read_text())

    def test_command_detects_runtime_crash_without_waiting_for_timeout(self):
        script = "import time; print('Shell subprocess crashed with segmentation fault', flush=True); time.sleep(30)"
        with (self.package / 'crash.log').open('wb') as log:
            started = time.monotonic()
            result = gate.command([sys.executable, '-c', script], self.package, log, os.environ.copy(), timeout_seconds=10)
        self.assertFalse(result)
        self.assertLess(time.monotonic() - started, 3)
        self.assertIn('VM crash detected', (self.package / 'crash.log').read_text())


if __name__ == '__main__':
    unittest.main()
