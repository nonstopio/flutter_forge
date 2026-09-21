import 'dart:io';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../commands/flutter_plugin_create_command.dart';
import '../post_gen.dart' as post;
import '../pre_gen.dart' as pre;

class _Context extends Mock implements HookContext {}

final class _Flutter extends BaseFlutterCommand {
  final creations = <Map<String, Object?>>[];
  final removals = <String>[];

  @override
  Future<void> createFlutterProject({
    required HookContext context,
    required String name,
    required String description,
    required String outputPath,
    String template = 'app',
    List<String> platforms = const ['ios', 'android', 'web'],
    String? orgName,
  }) async {
    creations.add({
      'context': context,
      'name': name,
      'description': description,
      'outputPath': outputPath,
      'template': template,
      'platforms': platforms,
      'orgName': orgName
    });
  }

  @override
  Future<void> removeAnalysisOptions(
      {required HookContext context, required String projectPath}) async {
    removals.add(projectPath);
  }
}

void main() {
  test('default command constructs without external work', () {
    expect(FlutterPluginCreateCommand(), isA<CliCommand>());
  });

  test('pre-generation discovers a native workspace', () async {
    final temporary = await Directory.systemTemp.createTemp('hook_pre_');
    final original = Directory.current;
    try {
      Directory.current = temporary;
      final context = _Context();
      final variables = <String, dynamic>{};
      when(() => context.vars).thenReturn(variables);
      await pre.run(context);
      expect(variables['is_mono_repo'], isFalse);
      await File('pubspec.yaml').writeAsString('name: root\nworkspace: []\n');
      await pre.run(context);
      expect(variables['is_mono_repo'], isTrue);
    } finally {
      Directory.current = original;
      await temporary.delete(recursive: true);
    }
  });

  for (final mono in [true, false, null]) {
    for (final org in ['io.nonstop', null]) {
      test(
          'post-generation creates plugin (workspace=$mono, organization=$org)',
          () async {
        final context = _Context();
        when(() => context.vars).thenReturn({
          'name': 'Sample App',
          'description': 'An example',
          if (mono != null) 'is_mono_repo': mono,
          if (org != null) 'org_name': org,
        });
        final flutter = _Flutter();
        await post.run(context, flutter: flutter);
        expect(flutter.creations, [
          {
            'context': context,
            'name': 'sample_app',
            'description': 'An example',
            'outputPath': '.',
            'template': 'plugin',
            'platforms': ['ios', 'android', 'web'],
            'orgName': org ?? 'com.example'
          },
        ]);
        expect(flutter.removals, mono == true ? ['sample_app'] : isEmpty);
      });
    }
  }
}
