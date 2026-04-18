import 'package:cli_core/cli_core.dart';
import 'package:cli_core/src/logger_extension.dart' as ext;
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeLogger extends Mock implements Logger {}

void main() {
  group('LoggerX.created', () {
    test('forwards message to info', () {
      final logger = _FakeLogger();
      when(() => logger.info(any())).thenReturn(null);
      logger.created('hello');
      verify(() => logger.info(any(that: contains('hello')))).called(1);
    });
  });

  group('LoggerX.wrap', () {
    final logger = _FakeLogger();

    tearDown(() {
      ext.stdoutTerminalColumnsResolver = ext.defaultTerminalColumnsForTest;
    });

    test('does nothing when text is null', () {
      final collected = <String?>[];
      logger.wrap(null, print: collected.add, length: 20);
      expect(collected, isEmpty);
    });

    test('wraps long text across lines based on length', () {
      final collected = <String?>[];
      logger.wrap(
        'aaa bbb ccc ddd eee',
        print: collected.add,
        length: 8,
      );
      expect(collected, isNotEmpty);
      expect(collected.last, isNot(contains('eee eee')));
      expect(collected.join('|'), contains('aaa'));
      expect(collected.join('|'), contains('eee'));
    });

    test('uses resolver when length is not provided', () {
      var resolverCalls = 0;
      ext.stdoutTerminalColumnsResolver = () {
        resolverCalls++;
        return 120;
      };
      final collected = <String?>[];
      logger.wrap('short text', print: collected.add);
      expect(resolverCalls, 1);
      expect(collected.single, 'short text ');
    });

    test('strips ANSI codes when measuring char length', () {
      final collected = <String?>[];
      // ANSI escape + short word. Raw length is 12 for the first word, but
      // the ANSI-stripped char length is 3, so the wrap check uses 3.
      logger.wrap('\x1B[31mred\x1B[0m word', print: collected.add, length: 20);
      expect(collected, hasLength(1));
      expect(collected.single, contains('red'));
      expect(collected.single, contains('word'));
    });

    test('default resolver returns fallback when stdout has no terminal', () {
      // In the test environment stdout never has a real terminal, so this
      // exercises the fallback path of the default resolver.
      expect(ext.defaultTerminalColumnsForTest(), ext.fallbackStdoutTerminalColumns);
    });
  });
}
