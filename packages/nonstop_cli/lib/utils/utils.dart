import 'package:mason/mason.dart';
import 'package:nonstop_cli/utils/logger_extension.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

typedef MasonGeneratorFromBundle = Future<MasonGenerator> Function(MasonBundle);

typedef MasonGeneratorFromBrick = Future<MasonGenerator> Function(Brick);

final RegExp identifierRegExp = RegExp('[a-z_][a-z0-9_]*');
final RegExp orgNameRegExp = RegExp(r'^[a-zA-Z][\w-]*(\.[a-zA-Z][\w-]*)+$');

const String infoText = '''

+----------------------------------------------------+
| Bespoke Engineering Studio                         |
|----------------------------------------------------|
| Digital Product Development Experts for            |
| Startups & Enterprises                             |
|                                                    |
| For more info visit:                               |
| https://nonstopio.com                              |
+----------------------------------------------------+

''';

void templateSummary({
  required Logger logger,
  required Directory outputDir,
  required String message,
}) {
  final relativePath = path.relative(
    outputDir.path,
    from: Directory.current.path,
  );

  final projectPath = relativePath;
  final projectPathLink =
      link(uri: Uri.parse(projectPath), message: projectPath);

  final details = '''
  • Your project code is in $projectPathLink
''';

  logger
    ..info('\n')
    ..created(message)
    ..info(details)
    ..info(
      lightGray.wrap(infoText),
    );
}
