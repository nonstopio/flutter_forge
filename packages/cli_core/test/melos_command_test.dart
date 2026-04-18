import 'dart:io';

import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeHookContext extends Mock implements HookContext {}

class _FakeLogger extends Mock implements Logger {}

class _FakeProgress extends Mock implements Progress {}

final class _TestMelosCommand extends BaseMelosCommand {}

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

  group('BaseMelosCommand.bootstrap', () {
    test('reports failure when working directory does not exist', () async {
      final cmd = _TestMelosCommand();
      await expectLater(
        cmd.bootstrap(
          context: context,
          workspacePath: '/definitely/not/a/real/path/melos1',
        ),
        throwsA(isA<ProcessException>()),
      );
      verify(() => progress.fail(any())).called(1);
    });
  });

  group('BaseMelosCommand.clean', () {
    test('reports failure when working directory does not exist', () async {
      final cmd = _TestMelosCommand();
      await expectLater(
        cmd.clean(
          context: context,
          workspacePath: '/definitely/not/a/real/path/melos2',
        ),
        throwsA(isA<ProcessException>()),
      );
      verify(() => progress.fail(any())).called(1);
    });
  });
}
