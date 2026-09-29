import 'dart:io';

import 'package:nonstop_cli/utils/workspace.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('workspace_test_'));
  tearDown(() => root.deleteSync(recursive: true));

  File write(String relative, String contents) =>
      File(p.join(root.path, relative))
        ..createSync(recursive: true)
        ..writeAsStringSync(contents);

  test('lists the member and marks it resolution: workspace', () {
    final rootPubspec = write(
      'pubspec.yaml',
      'name: w\nworkspace:\n  - packages/core\n',
    );
    final member = write('features/orders/pubspec.yaml', 'name: orders\n');

    expect(
      registerWorkspaceMember(member.parent)?.path,
      rootPubspec.path,
    );
    expect(
      rootPubspec.readAsStringSync(),
      'name: w\nworkspace:\n  - packages/core\n  - features/orders\n',
    );
    expect(member.readAsStringSync(), contains('resolution: workspace'));
  });

  test('is idempotent', () {
    final rootPubspec = write(
      'pubspec.yaml',
      'name: w\nworkspace:\n  - packages/core\n',
    );
    final member = write(
      'packages/core/pubspec.yaml',
      'name: core\nresolution: workspace\n',
    );

    registerWorkspaceMember(member.parent);

    expect(
      rootPubspec.readAsStringSync(),
      'name: w\nworkspace:\n  - packages/core\n',
    );
    expect(member.readAsStringSync(), 'name: core\nresolution: workspace\n');
  });

  test('does nothing outside a workspace', () {
    write('pubspec.yaml', 'name: standalone\n');
    final member = write('packages/a/pubspec.yaml', 'name: a\n');

    expect(registerWorkspaceMember(member.parent), isNull);
    expect(member.readAsStringSync(), 'name: a\n');
  });

  test('skips a malformed pubspec on the way up', () {
    final rootPubspec = write('pubspec.yaml', 'name: w\nworkspace:\n  - a\n');
    write('group/pubspec.yaml', 'name: [unterminated\n');
    final member = write('group/b/pubspec.yaml', 'name: b\n');

    expect(registerWorkspaceMember(member.parent)?.path, rootPubspec.path);
    expect(rootPubspec.readAsStringSync(), contains('group/b'));
  });

  test('does nothing without a member pubspec', () {
    write('pubspec.yaml', 'name: w\nworkspace:\n  - a\n');
    final member = Directory(p.join(root.path, 'b'))..createSync();

    expect(registerWorkspaceMember(member), isNull);
  });
}
