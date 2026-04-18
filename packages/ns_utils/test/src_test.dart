import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/src.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('NSUtils.init wires up custom callbacks and initializes SPService',
      () async {
    Object? loggedApp;
    Object? loggedError;
    await NSUtils.instance.init(
      appLogsFunction: (obj, [Object detail = '']) => loggedApp = obj,
      errorLogsFunction:
          (obj, [dynamic err, StackTrace stack = StackTrace.empty]) =>
              loggedError = obj,
    );

    appLogsNS('hello app');
    errorLogsNS('boom', Exception('x'), StackTrace.current);

    expect(loggedApp, 'hello app');
    expect(loggedError, 'boom');
    // SPService.instance is set after init.
    SPService().log();
  });

  test('NSUtils.init works without callbacks', () async {
    await NSUtils.instance.init();
  });
}
