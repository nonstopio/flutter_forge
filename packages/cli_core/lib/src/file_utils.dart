import 'dart:io';
import 'package:path/path.dart' as p;

/// Utility methods for common file system operations.
///
/// This class provides methods for:
/// - Directory and file management
/// - File copying and deletion
/// - YAML file operations
/// - Mono-repo detection
///
/// Example usage:
/// ```dart
/// // Ensure a directory exists
/// await FileUtils.ensureDirectory('path/to/dir');
///
/// // Copy a file
/// await FileUtils.copyFile('source.txt', 'dest.txt');
///
/// // Check if in a mono-repo
/// final isMonoRepo = await FileUtils.isMonoRepo();
/// ```
class FileUtils {
  /// Ensure a directory exists, create it if it doesn't.
  ///
  /// Returns a [Directory] instance for the ensured directory.
  /// Creates parent directories if they don't exist.
  static Future<Directory> ensureDirectory(String path) async {
    final directory = Directory(p.normalize(path));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Delete a file if it exists.
  ///
  /// Silently succeeds if the file doesn't exist.
  static Future<void> deleteFile(String path) async {
    final file = File(p.normalize(path));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Copy a file from source to destination.
  ///
  /// Creates any necessary parent directories for the destination.
  /// Throws [FileSystemException] if source doesn't exist.
  static Future<void> copyFile(String source, String destination) async {
    final sourceFile = File(p.normalize(source));
    final destFile = File(p.normalize(destination));

    if (!await sourceFile.exists()) {
      throw FileSystemException('Source file does not exist', source);
    }

    await ensureDirectory(p.dirname(destination));
    await sourceFile.copy(destFile.path);
  }

  /// Read YAML file content.
  ///
  /// Returns the raw string content of the YAML file.
  /// Throws [FileSystemException] if file doesn't exist.
  static Future<String> readYamlFile(String path) async {
    final file = File(p.normalize(path));
    if (!await file.exists()) {
      throw FileSystemException('YAML file does not exist', path);
    }
    return file.readAsString();
  }

  /// Write YAML file content.
  ///
  /// Creates any necessary parent directories.
  /// Overwrites existing file if it exists.
  static Future<void> writeYamlFile(String path, String content) async {
    final file = File(p.normalize(path));
    await ensureDirectory(p.dirname(path));
    await file.writeAsString(content);
  }

  /// Check if the current directory is part of a mono-repo.
  ///
  /// First tries to detect using the melos command.
  /// Falls back to checking for melos.yaml in current and parent directories.
  ///
  /// [path] - Optional path to check. Defaults to current directory.
  static Future<bool> isMonoRepo([String? path]) async {
    final workingDir = path ?? Directory.current.path;

    // Try with melos command first
    try {
      final melosResult = await Process.run(
        'melos',
        ['list', '--json'],
        workingDirectory: workingDir,
        runInShell: true,
      );
      if (melosResult.exitCode == 0 &&
          melosResult.stdout.toString().isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Ignore melos command failures and fall back to file check
    }

    // Check for melos.yaml in current and parent directories
    final currentMelosFile = File(p.join(workingDir, 'melos.yaml'));
    final parentMelosFile = File(p.join(p.dirname(workingDir), 'melos.yaml'));

    return currentMelosFile.existsSync() || parentMelosFile.existsSync();
  }
}
