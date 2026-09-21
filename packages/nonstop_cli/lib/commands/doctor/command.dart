import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:nonstop_cli/commands/doctor/src/doctor.dart';
import 'package:nonstop_cli/utils/utils.dart';

final class DoctorCommand extends Command<int> {
  DoctorCommand({
    required Logger logger,
    Doctor? doctor,
  })  : _logger = logger,
        _doctor = doctor ?? Doctor(logger: logger);

  final Logger _logger;
  final Doctor _doctor;

  @override
  final String description = 'Show information about the installed tooling.';

  @override
  String get name => 'doctor';

  @override
  String get invocation => 'nonstop doctor';

  @override
  Future<int> run() async {
    _logger.logSignature();
    final bool success = await _doctor.diagnose();
    return success ? ExitCode.success.code : ExitCode.tempFail.code;
  }
}
