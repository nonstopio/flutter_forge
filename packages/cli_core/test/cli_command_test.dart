import 'package:cli_core/cli_core.dart';
import 'package:mason/mason.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeHookContext extends Mock implements HookContext {}

class _FakeLogger extends Mock implements Logger {}

class _FakeProgress extends Mock implements Progress {}

final class _TestCommand extends CliCommand {}

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

  group('CliCommand', () {
    test('default run completes without error', () async {
      final cmd = _TestCommand();
      await cmd.run(context);
    });

    test('trackOperation completes on success', () async {
      final cmd = _TestCommand();
      var called = false;
      await cmd.trackOperation(
        context,
        startMessage: 'starting',
        endMessage: 'done',
        operation: () async {
          called = true;
        },
      );
      expect(called, isTrue);
      verify(() => logger.progress('starting')).called(1);
      verify(() => progress.complete('done')).called(1);
      verifyNever(() => progress.fail(any()));
    });

    test('trackOperation fails and rethrows when operation throws', () async {
      final cmd = _TestCommand();
      await expectLater(
        cmd.trackOperation(
          context,
          startMessage: 'starting',
          endMessage: 'done',
          operation: () async => throw StateError('boom'),
        ),
        throwsA(isA<StateError>()),
      );
      verify(() => logger.progress('starting')).called(1);
      verify(() => progress.fail(any(that: contains('boom')))).called(1);
      verifyNever(() => progress.complete(any()));
    });
  });
}
