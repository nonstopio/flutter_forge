import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nonstop_cli/commands/doctor/command.dart';
import 'package:nonstop_cli/commands/doctor/src/doctor.dart';
import 'package:nonstop_cli/commands/doctor/src/utils/utils.dart';
import 'package:nonstop_cli/commands/doctor/src/validators/validators.dart';
import 'package:test/test.dart';

class _Logger extends Mock implements Logger {}

class _Progress extends Mock implements Progress {}

class _Validator extends DoctorValidator {
  _Validator(this.result) : super('Example');

  final ValidationResult result;

  @override
  String get installHelp => 'https://example.test/install';

  @override
  String extractVersion(String output) => output;

  @override
  Future<ValidationResult> validate() async => result;
}

void main() {
  group('tool validators', () {
    test('parse known versions and reject unrelated output', () {
      final cases = <DoctorValidator, String>{
        DartValidator(): 'Dart SDK version: 3.12.0 (stable)',
        FlutterValidator(): 'Flutter 3.44.2 • channel stable',
        MelosValidator(): '7.0.0\n',
      };
      const versions = {
        'Dart': '3.12.0',
        'Flutter': '3.44.2',
        'Melos': '7.0.0'
      };
      for (final entry in cases.entries) {
        expect(
            entry.key.extractVersion(entry.value), versions[entry.key.title]);
        expect(entry.key.extractVersion('unrecognized'), 'Unknown');
        expect(entry.key.installInstructions,
            'Install ${entry.key.title} from ${entry.key.installHelp}');
        expect(Uri.parse(entry.key.installHelp).scheme, 'https');
      }
    });

    test('invoke each tool with --version and return its parsed version',
        () async {
      final calls = <String>[];
      ProcessResult run(String command, List<String> arguments) {
        expect(arguments, ['--version']);
        calls.add(command);
        return ProcessResult(
            1,
            0,
            switch (command) {
              'dart' => 'Dart SDK version: 3.12.0',
              'flutter' => 'Flutter 3.44.2',
              _ => '7.0.0',
            },
            '');
      }

      final validators = [
        DartValidator(runProcess: run),
        FlutterValidator(runProcess: run),
        MelosValidator(runProcess: run),
      ];
      for (final validator in validators) {
        final result = await validator.validate();
        expect(result.type, ValidationType.success);
        expect(result.statusInfo, endsWith(' is installed'));
        expect(result.messages, isEmpty);
      }
      expect(calls, ['dart', 'flutter', 'melos']);
    });

    test('nonzero exit gives installation help and command output', () async {
      final validator = DartValidator(
        runProcess: (_, __) => ProcessResult(1, 127, 'not on PATH', ''),
      );
      final result = await validator.validate();
      expect(result.type, ValidationType.missing);
      expect(result.messages,
          contains(const ValidationMessage.error('Command not found')));
      expect(result.messages,
          contains(const ValidationMessage.warning('not on PATH')));
      expect(result.messages,
          contains(ValidationMessage(validator.installInstructions)));
    });

    test('process exceptions retain the failure code and installation help',
        () async {
      final validator = MelosValidator(runProcess: (_, __) {
        throw const ProcessException('melos', [], 'No executable', 2);
      });
      final result = await validator.validate();
      expect(result.type, ValidationType.missing);
      expect(
          result.messages,
          contains(const ValidationMessage.error(
              'Command not found: [2] No executable')));
      expect(result.messages,
          contains(ValidationMessage(validator.installInstructions)));
    });

    test('unexpected errors are diagnosed as crashes with a stack trace',
        () async {
      final validator = FlutterValidator(runProcess: (_, __) {
        throw StateError('broken runner');
      });
      final result = await validator.validate();
      expect(result.type, ValidationType.crash);
      expect(result.statusInfo, UserMessages.doctorCrash);
      expect(result.messages, hasLength(3));
      expect(result.messages[1].message, contains('broken runner'));
      expect(
          result.messages.last.message, contains('doctor_command_test.dart'));
    });
  });

  group('diagnosis', () {
    for (final type in ValidationType.values) {
      test('reports $type and maps it to the correct exit code', () async {
        final logger = _Logger();
        final progress = _Progress();
        when(() => logger.progress(any())).thenReturn(progress);
        final result = ValidationResult(type, const [
          ValidationMessage.error('error detail'),
          ValidationMessage.warning('warning detail'),
          ValidationMessage('information detail'),
        ]);
        final doctor = Doctor(logger: logger)
          ..validators = [_Validator(result)];
        final command = DoctorCommand(logger: logger, doctor: doctor);
        expect(command.name, 'doctor');
        expect(command.invocation, 'nonstop doctor');
        expect(command.description, contains('installed tooling'));
        expect(
            await command.run(),
            type == ValidationType.crash || type == ValidationType.missing
                ? 75
                : 0);
        final summary = 'Example ${result.typeStr} ${result.leadingIcon}';
        if (type == ValidationType.success) {
          verify(() => progress.complete(summary)).called(1);
          verify(() => logger.info(UserMessages.summarizeDoctorCheckup(0)))
              .called(1);
        } else {
          verify(() => progress.fail(summary)).called(1);
          verify(() => logger.info(UserMessages.summarizeDoctorCheckup(1)))
              .called(1);
        }
        verify(() => logger.err('   🚩 error detail')).called(1);
        verify(() => logger.alert('   ⚠️ warning detail')).called(1);
        verify(() => logger.info('   👉 information detail')).called(1);
      });
    }

    test('uses specific status information and counts multiple issues',
        () async {
      final logger = _Logger();
      final progress = _Progress();
      when(() => logger.progress(any())).thenReturn(progress);
      final doctor = Doctor(logger: logger);
      expect(
          doctor.validators.map((v) => v.title), ['Flutter', 'Dart', 'Melos']);
      doctor.validators = [
        _Validator(ValidationResult(ValidationType.partial, [],
            statusInfo: 'needs setup')),
        _Validator(ValidationResult(ValidationType.notAvailable, [])),
        _Validator(ValidationResult(ValidationType.success, [],
            statusInfo: '1.2.3 installed')),
      ];
      expect(await doctor.diagnose(), isTrue);
      verify(() => progress.fail('Example needs setup ⌛')).called(1);
      verify(() => progress.complete('Example 1.2.3 installed ✅')).called(1);
      verify(() => logger.info('❗ Doctor found issues in 2 categories.'))
          .called(1);
    });
  });

  test('validation message values preserve type, equality and display', () {
    const info = ValidationMessage('detail');
    const error = ValidationMessage.error('detail');
    const warning = ValidationMessage.warning('detail');
    expect(info.isInformation, isTrue);
    expect(info.isError, isFalse);
    expect(info.isWarning, isFalse);
    expect(error.isError, isTrue);
    expect(warning.isWarning, isTrue);
    expect(info, const ValidationMessage('detail'));
    expect(info, isNot(error));
    expect(info, isNot(const ValidationMessage('different')));
    expect(info, isNot('detail'));
    expect(info.hashCode, const ValidationMessage('detail').hashCode);
    final uniqueMessages = {info, error};
    uniqueMessages.add(const ValidationMessage('detail'));
    expect(uniqueMessages, hasLength(2));
    expect(info.toString(), '   👉 detail');
    expect(error.toString(), '   🚩 detail');
    expect(warning.toString(), '   ⚠️ detail');
    expect(const ValidationMessage('').toString(), '');
    final result = ValidationResult.crash(StateError('oops'));
    expect(result.messages, hasLength(2));
    expect(result.toString(), contains('ValidationType.crash'));
    expect(UserMessages.exceptionMessage(Exception('unknown')),
        'Command not found');
  });
}
