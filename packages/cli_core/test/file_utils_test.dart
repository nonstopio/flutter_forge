import 'dart:io';

import 'package:cli_core/cli_core.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('file_utils_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileUtils', () {
    test('ensureDirectory creates directory if it does not exist', () async {
      final testPath = p.join(tempDir.path, 'test_dir');
      final dir = await FileUtils.ensureDirectory(testPath);
      expect(await dir.exists(), isTrue);
    });

    test('deleteFile removes file if it exists', () async {
      final testPath = p.join(tempDir.path, 'test.txt');
      final file = File(testPath);
      await file.writeAsString('test');

      await FileUtils.deleteFile(testPath);
      expect(await file.exists(), isFalse);
    });

    test('copyFile copies file to destination', () async {
      final sourcePath = p.join(tempDir.path, 'source.txt');
      final destPath = p.join(tempDir.path, 'dest.txt');

      await File(sourcePath).writeAsString('test content');
      await FileUtils.copyFile(sourcePath, destPath);

      expect(await File(destPath).readAsString(), equals('test content'));
    });

    test('readYamlFile reads yaml content', () async {
      final yamlPath = p.join(tempDir.path, 'test.yaml');
      await File(yamlPath).writeAsString('key: value');

      final content = await FileUtils.readYamlFile(yamlPath);
      expect(content, equals('key: value'));
    });

    test('writeYamlFile writes yaml content', () async {
      final yamlPath = p.join(tempDir.path, 'test.yaml');
      await FileUtils.writeYamlFile(yamlPath, 'key: value');

      final content = await File(yamlPath).readAsString();
      expect(content, equals('key: value'));
    });

    test('copyFile throws when source does not exist', () {
      expect(
        () => FileUtils.copyFile(
          p.join(tempDir.path, 'nonexistent.txt'),
          p.join(tempDir.path, 'dest.txt'),
        ),
        throwsA(isA<FileSystemException>()),
      );
    });

    group('isMonoRepo', () {
      test('returns true when melos.yaml exists in current directory',
          () async {
        final melosPath = p.join(tempDir.path, 'melos.yaml');
        await File(melosPath).writeAsString('name: test_workspace');

        expect(await FileUtils.isMonoRepo(tempDir.path), isTrue);
      });

      test('returns true when melos.yaml exists in parent directory', () async {
        final parentDir =
            await Directory(p.join(tempDir.path, 'parent')).create();
        final childDir =
            await Directory(p.join(parentDir.path, 'child')).create();
        await File(p.join(parentDir.path, 'melos.yaml'))
            .writeAsString('name: test_workspace');

        expect(await FileUtils.isMonoRepo(childDir.path), isTrue);
      });

      test('returns false when no melos.yaml exists', () async {
        expect(await FileUtils.isMonoRepo(tempDir.path), isFalse);
      });
    });
  });
}
