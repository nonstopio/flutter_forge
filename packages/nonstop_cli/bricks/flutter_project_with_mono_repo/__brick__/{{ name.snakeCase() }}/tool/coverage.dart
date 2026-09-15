import 'dart:io';
import 'package:path/path.dart' as p;

/// Run from the workspace root: dart run tool/coverage.dart [--report-only].
/// Only compiler-generated serializers/translations are excluded.
Future<void> main(List<String> args) async {
  final root = Directory(Directory.current.resolveSymbolicLinksSync());
  final merged = <String, Map<int, int>>{};
  var failed = false;
  final reportOnly = args.contains('--report-only');
  final names = <String>[];
  for (final area in ['apps', 'features', 'packages', 'plugins']) {
    final directory = Directory('${root.path}/$area');
    if (!directory.existsSync()) continue;
    for (final package in directory.listSync().whereType<Directory>()) {
      final manifest = File('${package.path}/pubspec.yaml');
      if (manifest.existsSync()) {
        final name = RegExp(
          r'^name:\s*(\S+)',
          multiLine: true,
        ).firstMatch(manifest.readAsStringSync())!.group(1)!;
        names.add(RegExp.escape(name));
      }
    }
  }
  final coveragePackages = '^(${names.join('|')})\$';
  for (final area in ['apps', 'features', 'packages', 'plugins']) {
    final directory = Directory('${root.path}/$area');
    if (!directory.existsSync()) continue;
    final packages = directory.listSync().whereType<Directory>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final package in packages) {
      final manifest = File('${package.path}/pubspec.yaml');
      if (!manifest.existsSync()) continue;
      final name = RegExp(
        r'^name:\s*(\S+)',
        multiLine: true,
      ).firstMatch(manifest.readAsStringSync())!.group(1)!;
      final testDirectory = Directory('${package.path}/test');
      if (!testDirectory.existsSync() ||
          !testDirectory
              .listSync(recursive: true)
              .whereType<File>()
              .any((f) => f.path.endsWith('_test.dart'))) {
        stderr.writeln('$area/$name: missing tests');
        failed = true;
        continue;
      }
      final report = File('${package.path}/coverage/lcov.info');
      if (!reportOnly) {
        final imports = File(
          '${testDirectory.path}/coverage_imports_test.dart',
        );
        if (imports.existsSync()) {
          throw StateError('Refusing to overwrite ${imports.path}');
        }
        final sources = Directory('${package.path}/lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))
            .where(
              (f) => !RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(f.path),
            )
            .where(
              (f) => !RegExp(
                r'^part of ',
                multiLine: true,
              ).hasMatch(f.readAsStringSync()),
            )
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
        imports.writeAsStringSync(
          [
            '// Generated temporarily by tool/coverage.dart.',
            '// ignore_for_file: unused_import',
            for (final source in sources)
              "import 'package:$name/${p.relative(source.path, from: p.join(package.path, 'lib')).replaceAll(r'\', '/')}';",
            'void main() {}',
          ].join('\n'),
        );
        try {
          if (report.existsSync()) report.deleteSync();
          final process = await Process.start(
            'flutter',
            ['test', '--coverage', '--coverage-package=$coveragePackages'],
            workingDirectory: package.path,
            mode: ProcessStartMode.inheritStdio,
          );
          if (await process.exitCode != 0) failed = true;
        } finally {
          imports.deleteSync();
        }
      }
      if (!report.existsSync()) {
        stderr.writeln('$area/$name: missing coverage report');
        failed = true;
        continue;
      }
      String? source;
      for (final line in report.readAsLinesSync()) {
        if (line.startsWith('SF:')) {
          final path = line.substring(3);
          var absolute = p.normalize(
              p.isAbsolute(path) ? path : p.join(package.path, path));
          // VM reports may use /var while the workspace resolves to /private/var
          // on macOS (or another symlink on Linux). Merge the same real source.
          final sourceFile = File(absolute);
          if (sourceFile.existsSync()) {
            absolute = sourceFile.resolveSymbolicLinksSync();
          }
          source = p.isWithin(root.path, absolute)
              ? p.relative(absolute, from: root.path).replaceAll(r'\', '/')
              : null;
          if (source != null &&
              !RegExp(r'^(apps|features|packages|plugins)/[^/]+/lib/')
                  .hasMatch(source)) {
            source = null;
          }
          if (source != null &&
              RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(source)) {
            source = null;
          }
        } else if (line.startsWith('DA:') && source != null) {
          final fields = line.substring(3).split(',');
          final number = int.parse(fields[0]);
          final hits = int.parse(fields[1]);
          final lines = merged.putIfAbsent(source, () => {});
          lines[number] = (lines[number] ?? 0) + hits;
        }
      }
    }
  }
  var covered = 0;
  var total = 0;
  final output = StringBuffer();
  for (final source in merged.keys.toList()..sort()) {
    final lines = merged[source]!;
    final missing = lines.entries
        .where((e) => e.value == 0)
        .map((e) => e.key)
        .toList()
      ..sort();
    covered += lines.length - missing.length;
    total += lines.length;
    output.writeln('SF:$source');
    for (final line in lines.keys.toList()..sort()) {
      output.writeln('DA:$line,${lines[line]}');
    }
    output.writeln('LF:${lines.length}');
    output.writeln('LH:${lines.length - missing.length}');
    output.writeln('end_of_record');
    if (missing.isNotEmpty) {
      stdout.writeln('$source: uncovered lines ${missing.join(", ")}');
    }
  }
  Directory('coverage').createSync(recursive: true);
  File('coverage/lcov.info').writeAsStringSync(output.toString());
  stdout.writeln(
    'Coverage: $covered/$total executable lines '
    '(${total == 0 ? "0.00" : (100 * covered / total).toStringAsFixed(2)}%)',
  );
  if (failed || total == 0 || covered != total) exitCode = 1;
}
