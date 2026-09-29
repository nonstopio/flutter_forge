import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Joins [member] to the nearest enclosing pub workspace: lists it under the
/// root `workspace:` and marks it `resolution: workspace`.
///
/// Without both, `dart pub get` at the root rejects or ignores the new
/// package. Returns the updated root pubspec, or `null` when [member] has no
/// pubspec or no enclosing workspace (e.g. a standalone package).
File? registerWorkspaceMember(Directory member) {
  final memberPubspec = File(path.join(member.path, 'pubspec.yaml'));
  if (!memberPubspec.existsSync()) return null;

  final root = _findWorkspaceRoot(member.absolute.parent);
  if (root == null) return null;

  final relative = path.posix.joinAll(
    path.split(path.relative(member.absolute.path, from: root.parent.path)),
  );
  final rootEditor = YamlEditor(root.readAsStringSync());
  final members = (rootEditor.parseAt(['workspace']) as YamlList).toList();
  if (!members.contains(relative)) {
    rootEditor.appendToList(['workspace'], relative);
    root.writeAsStringSync(rootEditor.toString());
  }

  final memberEditor = YamlEditor(memberPubspec.readAsStringSync());
  final resolution = memberEditor.parseAt(
    ['resolution'],
    orElse: () => YamlScalar.wrap(null),
  );
  if (resolution.value != 'workspace') {
    memberEditor.update(['resolution'], 'workspace');
    memberPubspec.writeAsStringSync(memberEditor.toString());
  }
  return root;
}

File? _findWorkspaceRoot(Directory start) {
  var directory = start;
  while (true) {
    final pubspec = File(path.join(directory.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      try {
        if (loadYaml(pubspec.readAsStringSync())
            case {
              'workspace': YamlList _,
            }) {
          return pubspec;
        }
      } on YamlException {
        // An unrelated or unfinished pubspec does not identify a workspace.
      }
    }
    final parent = directory.parent;
    if (parent.path == directory.path) return null;
    directory = parent;
  }
}
