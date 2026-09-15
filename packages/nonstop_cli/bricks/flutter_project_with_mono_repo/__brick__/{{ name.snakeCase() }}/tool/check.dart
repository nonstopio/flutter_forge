import 'dart:io';
import 'package:path/path.dart' as p;

/// Portable, non-mutating format and analyzer checks from the workspace root.
Future<void> main() async {
  final sources = <String>[];
  void collect(Directory directory) {
    if (!directory.existsSync()) {
      return;
    }
    for (final entry in directory.listSync(followLinks: false)) {
      if (entry is Directory) {
        if (!['build', '.dart_tool', '.symlinks']
            .contains(p.basename(entry.path))) {
          collect(entry);
        }
      } else if (entry is File &&
          entry.path.endsWith('.dart') &&
          !RegExp(r'\.(g|freezed|i69n)\.dart$').hasMatch(entry.path)) {
        sources.add(entry.path);
      }
    }
  }

  collect(Directory('tool'));
  for (final area in ['apps', 'features', 'packages', 'plugins']) {
    final directory = Directory(area);
    if (!directory.existsSync()) {
      continue;
    }
    for (final package in directory.listSync().whereType<Directory>()) {
      collect(Directory(p.join(package.path, 'lib')));
      collect(Directory(p.join(package.path, 'test')));
    }
  }
  sources.sort();
  for (final arguments in [
    ['format', '--output=none', '--set-exit-if-changed', ...sources],
    ['analyze', '--fatal-infos', '.'],
  ]) {
    final process = await Process.start('dart', arguments,
        mode: ProcessStartMode.inheritStdio);
    final result = await process.exitCode;
    if (result != 0) {
      exitCode = result;
      return;
    }
  }
}
