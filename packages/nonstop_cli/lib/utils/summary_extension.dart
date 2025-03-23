import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';

const String infoText = '''

+----------------------------------------------------+
| NonStop IO                                         |
|----------------------------------------------------|
| A Bespoke Engineering Studio                       |
|                                                    |
| Digital Product Development Experts for            |
| Startups & Enterprises                             |
|                                                    |
| For more info visit:                               |
| https://nonstopio.com                              |
+----------------------------------------------------+

''';

extension SummaryExtension on Logger {
  void logSummary({
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

    final readmePath = path.join(relativePath, 'README.md');
    final readmePathLink =
        link(uri: Uri.parse(readmePath), message: readmePath);

    final details = '''
  • To get started refer to $readmePathLink
  • Your project code is in $projectPathLink
''';

    this
      ..info('\n')
      ..created(message)
      ..info(details)
      ..info(
        lightGray.wrap(infoText),
      );
  }
}
