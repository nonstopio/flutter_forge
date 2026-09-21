#!/usr/bin/env python3
"""Run every real workspace package and enforce 100% executable Dart line coverage.

Examples and Mason hooks are included. Mustache brick templates are validated by
nonstop_cli's template tests; they are not executable Dart packages before rendering.
All owned production libraries are imported by a temporary test so unused files
cannot silently disappear from the denominator. Empty reports never pass.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[1]
RUNTIME_CRASH = b'Shell subprocess crashed with segmentation fault'

# Run the installed Flutter tool through its test-runner injection point. The
# stock CLI cannot request truly unfiltered coverage: an empty package selection
# disables VM filters but also discards every line when formatting LCOV. Setting
# the collector's nullable libraryNames to null handles both stages correctly.
# This does not modify the SDK or coverage dependency. Function.apply forwards
# Flutter's entire runTests signature, including optional arguments, unchanged.
FLUTTER_COVERAGE_RUNNER = """\
import 'dart:io';
import 'package:flutter_tools/runner.dart' as runner;
import 'package:flutter_tools/src/cache.dart';
import 'package:flutter_tools/src/commands/test.dart';
import 'package:flutter_tools/src/globals.dart' as globals;
import 'package:flutter_tools/src/test/coverage_collector.dart';
import 'package:flutter_tools/src/test/runner.dart';
import 'package:flutter_tools/src/hook_runner.dart';
import 'package:flutter_tools/src/build_system/targets/hook_runner_native.dart';
import 'package:flutter_tools/src/build_system/build_targets.dart';
import 'package:flutter_tools/src/isolated/build_targets.dart';
import 'package:flutter_tools/src/base/template.dart';
import 'package:flutter_tools/src/isolated/mustache_template.dart';

class AllSourceTestRunner implements FlutterTestRunner {
  @override
  dynamic noSuchMethod(Invocation call) {
    if (call.memberName != #runTests) return super.noSuchMethod(call);
    final watcher = call.namedArguments[#watcher];
    if (watcher is! CoverageCollector) {
      throw StateError('Expected coverage collector, got $watcher');
    }
    watcher.libraryNames = null;
    return Function.apply(const FlutterTestRunner().runTests,
        call.positionalArguments, call.namedArguments);
  }
}

Future<void> main(List<String> args) async {
  Cache.flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  await runner.run(args, () => [TestCommand(
      testRunner: AllSourceTestRunner(),
      nativeAssetsBuilder: globals.nativeAssetsBuilder)],
      shutdownHooks: globals.shutdownHooks,
      overrides: {
        FlutterHookRunner: () => FlutterHookRunnerNative(),
        BuildTargets: () => const BuildTargetsImpl(),
        TemplateRenderer: () => const MustacheTemplateRenderer(),
      });
}
"""


def flutter_command(coverage: Path, env: dict) -> list[str]:
    executable = shutil.which('flutter')
    if executable is None:
        raise RuntimeError('Flutter is not on PATH')
    sdk = Path(env.get('FLUTTER_ROOT') or Path(executable).resolve().parent.parent)
    config = sdk / 'packages/flutter_tools/.dart_tool/package_config.json'
    if not config.exists():
        raise RuntimeError('Cannot locate Flutter tool package config; set FLUTTER_ROOT to the SDK directory')
    env['FLUTTER_ROOT'] = str(sdk)
    driver = coverage / 'flutter_coverage_runner.dart'
    driver.write_text(FLUTTER_COVERAGE_RUNNER)
    return [str(sdk / 'bin/cache/dart-sdk/bin/dart'), f'--packages={config}', str(driver), 'test']


def discover(root: Path) -> list[dict]:
    output = subprocess.check_output(
        ['dart', 'pub', 'workspace', 'list', '--json'], cwd=root, text=True
    )
    return json.loads(output)['packages']


def sources(package: Path, root: Path) -> list[Path]:
    if package == root:
        candidates = list((package / 'tools').glob('*.dart'))
    elif package.name == 'hooks' or package == root / 'tools/readme_sync':
        candidates = list(package.glob('*.dart')) + list((package / 'commands').rglob('*.dart'))
    else:
        candidates = (list(package.glob('*.dart')) + list((package / 'lib').rglob('*.dart'))
                      + list((package / 'bin').rglob('*.dart'))
                      + list((package / 'tool').rglob('*.dart')))
    return sorted(path.resolve() for path in candidates)


def read_lcov(path: Path, package: Path, owned: set[Path]) -> dict[Path, dict[int, int]]:
    result: dict[Path, dict[int, int]] = {}
    current = None
    for line in path.read_text().splitlines():
        if line.startswith('SF:'):
            current = (package / line[3:]).resolve()
            if current in owned:
                result.setdefault(current, {})
        elif line.startswith('DA:') and current in owned:
            number, hits, *_ = line[3:].split(',')
            points = result[current]
            points[int(number)] = points.get(int(number), 0) + int(hits)
    return result


def declaration_only(source: str) -> bool:
    """Recognize a deliberately narrow set of files with no executable lines.

    This is not an executable-line estimator. Unrecognized syntax fails closed:
    it must have a VM coverage record. In particular, constructors, function
    bodies, and non-const initializers cannot be excused as declaration-only.
    """
    tokens = re.compile(r'''//[^\n]*|/\*.*?\*/|'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"''', re.S)
    text = tokens.sub(lambda match: '' if match[0].startswith(('/',)) else "''", source)
    text = re.sub(r"\b(?:import|export|part)\s+''[^;]*;", '', text)
    text = re.sub(r'\bpart\s+of\s+[\w.]+\s*;', '', text)
    text = re.sub(r'\blibrary(?:\s+[\w.]+)?\s*;', '', text)
    text = re.sub(r'\btypedef\s+[^;]+;', '', text)
    text = re.sub(r'\b(?:static\s+)?const\s+(?:[\w$]+(?:<[\w\s,<>?]+>)?\s+)?[\w$]+\s*=[^;]*;', '', text)
    text = re.sub(r'\b(?:(?:abstract|final|base|interface|sealed)\s+)*class\s+\w+\s*\{\s*\}', '', text)
    text = re.sub(r'\bextension(?:\s+\w+)?\s+on\s+[\w\s?<>.,]+\{\s*\}', '', text)
    text = re.sub(r'\benum\s+\w+\s*\{\s*(?:\w+\s*(?:,\s*\w+\s*)*,?\s*)?\}', '', text)
    return not text.strip()


def command(args: list[str], package: Path, log, env: dict, timeout_seconds: float = 600) -> bool:
    """Bound each command and terminate its children on a timeout or VM crash.

    Flutter's runner can hang while finalizing a crashed coverage isolate. A
    process group prevents a stalled compiler or test process surviving a failed
    gate, and the log retains the original diagnostic rather than hiding it.
    """
    log.write(('\n$ ' + ' '.join(args) + '\n').encode())
    log.flush()
    output_offset = log.tell()
    process = subprocess.Popen(args, cwd=package, stdout=log, stderr=subprocess.STDOUT,
                               env=env, start_new_session=True)

    def stop() -> None:
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            return
        try:
            process.wait(timeout=2)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            process.wait()

    deadline = time.monotonic() + timeout_seconds
    try:
        with Path(log.name).open('rb') as output:
            output.seek(output_offset)
            tail = b''
            while process.poll() is None:
                latest = tail + output.read()
                if RUNTIME_CRASH in latest:
                    log.write(b'\n[coverage-gate] VM crash detected; terminating stalled runner.\n')
                    log.flush()
                    stop()
                    return False
                tail = latest[-len(RUNTIME_CRASH):]
                if time.monotonic() >= deadline:
                    log.write(f'\n[coverage-gate] Command timed out after {timeout_seconds:g}s.\n'.encode())
                    log.flush()
                    stop()
                    return False
                try:
                    process.wait(timeout=0.1)
                except subprocess.TimeoutExpired:
                    pass
        return process.returncode == 0
    except BaseException:
        stop()
        raise


def run_package(entry: dict, root: Path, report_only: bool = False) -> dict:
    root = root.resolve()
    package = Path(entry['path']).resolve()
    name = entry['name']
    owned = sources(package, root)
    summary = {'package': name, 'path': str(package.relative_to(root)), 'status': 'failed', 'hit': 0, 'lines': 0}
    if not owned:
        summary['reason'] = 'No production Dart sources discovered'
        return summary
    fixture = package / 'test/full_coverage_test.dart'
    tests = sorted(p for p in (package / 'test').rglob('*_test.dart') if p != fixture)
    if not tests:
        summary['reason'] = 'No unit tests found'
        return summary
    coverage = package / 'coverage'
    lcov = coverage / 'lcov.info'
    if not report_only:
        if coverage.exists():
            shutil.rmtree(coverage)
        coverage.mkdir()
        flutter = bool(re.search(r'^\s+sdk:\s*flutter\s*$', (package / 'pubspec.yaml').read_text(), re.M))
        if flutter:
            # Incremental kernels left by earlier SDK/source revisions can
            # execute correctly but omit source records from VM coverage. A
            # fresh gate needs fresh compilation metadata as well as fresh LCOV.
            test_cache = package / 'build/test_cache'
            if test_cache.exists():
                shutil.rmtree(test_cache)
        previous = fixture.read_bytes() if fixture.exists() else None
        imports = []
        for index, source in enumerate(owned):
            if re.search(r'^\s*part\s+of\b', source.read_text(), re.M):
                continue
            relative = (f'package:{name}/' + source.relative_to(package / 'lib').as_posix()) if source.is_relative_to(package / 'lib') else quote(os.path.relpath(source, fixture.parent), safe='/._-')
            imports.append(f"import '{relative}' as source{index};")
        framework = 'flutter_test/flutter_test.dart' if flutter else 'test/test.dart'
        first_test = quote(os.path.relpath(tests[0], fixture.parent), safe='/._-')
        imports.append(f"import '{first_test}' as original_tests;")
        fixture.write_text('// Generated by tools/coverage.py; removed after the run.\n'
                           '// ignore_for_file: unused_import, directives_ordering\n'
                           f"import 'package:{framework}';\n" + '\n'.join(imports) +
                           ("\nvoid main() { TestWidgetsFlutterBinding.ensureInitialized(); original_tests.main(); }\n" if flutter else "\nvoid main() { original_tests.main(); }\n"))
        env = os.environ.copy()
        env['CI'] = 'true'
        try:
            with (coverage / 'test.log').open('wb') as log:
                # VM package filters crash in Dart 3.13.4's SourceReport and omit
                # file: libraries such as package-root entrypoints. Collect all
                # loaded sources, then select owned paths in read_lcov instead.
                args = flutter_command(coverage, env) + ['--no-pub', '--concurrency=1', '--coverage', '--reporter', 'expanded'] if flutter else ['dart', 'test', '--coverage=coverage/raw', '--reporter=expanded']
                args += [str(fixture.relative_to(package)), *[str(test.relative_to(package)) for test in tests[1:]]]
                if not command(args, package, log, env):
                    summary['reason'] = f'Tests failed; see {coverage.relative_to(root)}/test.log'
                    return summary
                if not flutter and not command(['dart', 'run', 'coverage:format_coverage', '--lcov', '--in=coverage/raw', '--out=coverage/lcov.info', '--report-on=.'], package, log, env):
                    summary['reason'] = 'Coverage conversion failed'
                    return summary
        finally:
            if previous is None:
                fixture.unlink(missing_ok=True)
            else:
                fixture.write_bytes(previous)
    if not lcov.exists():
        summary['reason'] = 'Coverage report missing'
        return summary
    records = read_lcov(lcov, package, set(owned))
    summary['lines'] = sum(len(lines) for lines in records.values())
    summary['hit'] = sum(hits > 0 for lines in records.values() for hits in lines.values())
    summary['uncovered'] = {str(file.relative_to(package)): [number for number, hits in lines.items() if hits == 0]
                            for file, lines in records.items() if any(hits == 0 for hits in lines.values())}
    summary['sources'] = len(owned)
    missing = [str(source.relative_to(package)) for source in owned
               if source not in records and not declaration_only(source.read_text())]
    if missing:
        summary['missing_sources'] = missing
    if summary['lines'] == 0:
        summary['reason'] = 'Empty coverage report'
    elif missing:
        summary['reason'] = 'Production sources missing from coverage'
    elif summary['hit'] != summary['lines']:
        summary['reason'] = 'Uncovered production lines'
    else:
        summary['status'] = 'passed'
    return summary


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package', action='append', default=[], help='Workspace package name or path (repeatable)')
    parser.add_argument('--report-only', action='store_true', help='Inspect existing reports; does not provide fresh verification')
    args = parser.parse_args()
    packages = discover(ROOT)
    if args.package:
        unknown = [selection for selection in args.package if not any(p['name'] == selection or str(Path(p['path']).relative_to(ROOT)) == selection for p in packages)]
        if unknown:
            parser.error('Unknown workspace packages: ' + ', '.join(unknown))
        packages = [p for p in packages if p['name'] in args.package or str(Path(p['path']).relative_to(ROOT)) in args.package]
        if not packages:
            parser.error('No matching workspace package')
    results = []
    for entry in packages:
        print(f"Testing {entry['name']}...", flush=True)
        result = run_package(entry, ROOT, args.report_only)
        results.append(result)
        percentage = f"{100 * result['hit'] / result['lines']:.2f}%" if result['lines'] else 'no coverage'
        print(f"  {result['status'].upper()}: {result['hit']}/{result['lines']} ({percentage}) {result.get('reason', '')}", flush=True)
        for source, lines in result.get('uncovered', {}).items():
            print(f"    {source}: {', '.join(map(str, lines))}", flush=True)
        for source in result.get('missing_sources', []):
            print(f"    {source}: no VM coverage record", flush=True)
    destination = ROOT / 'coverage'
    destination.mkdir(exist_ok=True)
    report = destination / ('summary-existing.json' if args.report_only else 'summary.json')
    report.write_text(json.dumps(results, indent=2) + '\n')
    return int(any(result['status'] != 'passed' for result in results))


if __name__ == '__main__':
    sys.exit(main())
