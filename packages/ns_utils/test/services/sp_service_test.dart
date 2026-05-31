import 'package:flutter_test/flutter_test.dart';
import 'package:ns_utils/services/shared_preferences/sp_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'existing': 'yes'});
  });

  test('init loads the shared preferences and clear wipes them', () async {
    await SPService.init();
    expect(SPService.instance.containsKey('existing'), isTrue);
    SPService.clear();
    expect(SPService.instance.containsKey('existing'), isFalse);
  });

  test('log calls the NS app logger without throwing', () {
    SPService().log();
  });
}
