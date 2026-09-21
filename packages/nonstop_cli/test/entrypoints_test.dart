import 'dart:async';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../bin/nonstop.dart' as nonstop;
import '../bin/ns.dart' as ns;
import '../bin/nsio.dart' as nsio;

class _Stdout extends Mock implements Stdout {}

void main() {
  for (final entry
      in {'nonstop': nonstop.main, 'ns': ns.main, 'nsio': nsio.main}.entries) {
    for (final success in [true, false]) {
      test(
          '${entry.key} sets the exit status and waits for both output streams (${success ? 'success' : 'usage error'})',
          () async {
        final output = _Stdout();
        final errors = _Stdout();
        final outputFlushed = Completer<void>();
        final errorsFlushed = Completer<void>();
        for (final stream in [output, errors]) {
          when(() => stream.hasTerminal).thenReturn(false);
          when(() => stream.supportsAnsiEscapes).thenReturn(false);
        }
        when(() => output.flush()).thenAnswer((_) => outputFlushed.future);
        when(() => errors.flush()).thenAnswer((_) => errorsFlushed.future);
        final originalExitCode = exitCode;
        try {
          await IOOverrides.runZoned(() async {
            var finished = false;
            final future = entry
                .value(success ? ['completion'] : ['--invalid-option'])
                .then((_) => finished = true);
            await Future<void>.delayed(Duration.zero);
            expect(exitCode, success ? 0 : 64);
            expect(finished, isFalse);
            outputFlushed.complete();
            await Future<void>.delayed(Duration.zero);
            expect(finished, isFalse);
            errorsFlushed.complete();
            await future;
            expect(finished, isTrue);
            verify(() => output.flush()).called(1);
            verify(() => errors.flush()).called(1);
          }, stdout: () => output, stderr: () => errors);
        } finally {
          exitCode = originalExitCode;
        }
      });
    }
  }
}
