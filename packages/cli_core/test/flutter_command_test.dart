import 'dart:io';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeHookContext extends Mock implements HookContext {}

class _FakeLogger extends Mock implements Logger {}

class _FakeProgress extends Mock implements Progress {}

final class _TestFlutterCommand extends BaseFlutterCommand {}

void main() {
  late _FakeHookContext context;
  late _FakeLogger logger;
  late _FakeProgress progress;

  setUp(() {
    context = _FakeHookContext();
    logger = _FakeLogger();
    progress = _FakeProgress();
    when(() => context.logger).thenReturn(logger);
    when(() => logger.progress(any())).thenReturn(progress);
    when(() => progress.complete(any())).thenReturn(null);
    when(() => progress.fail(any())).thenReturn(null);
  });

  group('BaseFlutterCommand.createFlutterProject', () {
    test('reports failure when working directory does not exist', () async {
      final cmd = _TestFlutterCommand();
      await expectLater(
        cmd.createFlutterProject(
          context: context,
          name: 'tmp_app',
          description: 'desc',
          outputPath: '/definitely/not/a/real/path/xyz123',
          orgName: 'com.example',
        ),
        throwsA(isA<ProcessException>()),
      );
      verify(() => progress.fail(any())).called(1);
    });

    test('package template omits platforms arg and reports failure', () async {
      final cmd = _TestFlutterCommand();
      await expectLater(
        cmd.createFlutterProject(
          context: context,
          name: 'tmp_pkg',
          description: 'desc',
          outputPath: '/definitely/not/a/real/path/xyz456',
          template: 'package',
        ),
        throwsA(isA<ProcessException>()),
      );
    });
  });

  group('BaseFlutterCommand.removeAnalysisOptions', () {
    test('succeeds when file is present', () async {
      final tmp = await Directory.systemTemp.createTemp('flutter_cmd_');
      addTearDown(() async {
        if (await tmp.exists()) await tmp.delete(recursive: true);
      });
      final file = File('${tmp.path}/analysis_options.yaml');
      await file.writeAsString('');
      final cmd = _TestFlutterCommand();
      await cmd.removeAnalysisOptions(
        context: context,
        projectPath: tmp.path,
      );
      expect(await file.exists(), isFalse);
      verify(() => progress.complete(any())).called(1);
    });

    test('rethrows when file is missing', () async {
      final tmp = await Directory.systemTemp.createTemp('flutter_cmd_');
      addTearDown(() async {
        if (await tmp.exists()) await tmp.delete(recursive: true);
      });
      final cmd = _TestFlutterCommand();
      await expectLater(
        cmd.removeAnalysisOptions(context: context, projectPath: tmp.path),
        throwsA(isA<FileSystemException>()),
      );
      verify(() => progress.fail(any())).called(1);
    });
  });

  group('BaseFlutterCommand.pubGet', () {
    test('reports failure when working directory does not exist', () async {
      final cmd = _TestFlutterCommand();
      await expectLater(
        cmd.pubGet(
          context: context,
          projectPath: '/definitely/not/a/real/path/xyz789',
        ),
        throwsA(isA<ProcessException>()),
      );
      verify(() => progress.fail(any())).called(1);
    });
  });
}
