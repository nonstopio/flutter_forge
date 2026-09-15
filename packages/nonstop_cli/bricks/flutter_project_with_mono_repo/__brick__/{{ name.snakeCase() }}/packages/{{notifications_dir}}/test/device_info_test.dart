import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notifications/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Logger extends Mock implements Logger {}

class _Plugin extends Mock implements DeviceInfoPlugin {}

class _Info extends Mock implements BaseDeviceInfo {}

class _Preferences extends Mock implements SharedPreferences {}

class _Store implements InstallationIdStore {
  String? value;
  bool fail = false;
  int writes = 0;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String id) async {
    if (fail) throw StateError('disk unavailable');
    writes++;
    value = id;
  }
}

void main() {
  test('storage rejects unsuccessful preference writes', () async {
    final preferences = _Preferences();
    when(
      () => preferences.setString(any(), any()),
    ).thenAnswer((_) async => false);
    final store = SharedPreferencesInstallationIdStore(
      preferences: preferences,
    );
    await expectLater(store.write('id'), throwsStateError);
  });
  test(
    'concurrent requests persist one ID and new instances reuse it',
    () async {
      final store = _Store();
      var generated = 0;
      final device = DeviceInfoImpl(
        logger: _Logger(),
        store: store,
        createId: () => 'id-${++generated}',
      );
      expect(
        await Future.wait([
          device.generateDeviceId(),
          device.generateDeviceId(),
        ]),
        ['id-1', 'id-1'],
      );
      expect(store.writes, 1);
      final second = DeviceInfoImpl(logger: _Logger(), store: store);
      expect(await second.generateDeviceId(), 'id-1');
    },
  );

  test('storage failures propagate and can be retried', () async {
    final store = _Store()..fail = true;
    final device = DeviceInfoImpl(
      logger: _Logger(),
      store: store,
      createId: () => 'id',
    );
    await expectLater(device.generateDeviceId(), throwsStateError);
    store.fail = false;
    expect(await device.generateDeviceId(), 'id');
  });

  test(
    'default storage persists random IDs without hardware fingerprinting',
    () async {
      SharedPreferences.setMockInitialValues({});
      final first = await DeviceInfoImpl(logger: _Logger()).generateDeviceId();
      expect(first, matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(await DeviceInfoImpl(logger: _Logger()).generateDeviceId(), first);
    },
  );

  test(
    'device names use plugin metadata and fall back when unavailable',
    () async {
      final plugin = _Plugin();
      final info = _Info();
      when(() => plugin.deviceInfo).thenAnswer((_) async => info);
      final device = DeviceInfoImpl(
        logger: _Logger(),
        deviceInfoPlugin: plugin,
      );
      when(() => info.data).thenReturn({'model': 'Test phone'});
      expect(await device.getDeviceName(), 'Test phone');
      when(() => info.data).thenReturn({});
      expect(await device.getDeviceName(), isNotEmpty);
      when(() => plugin.deviceInfo).thenThrow(StateError('unavailable'));
      expect(await device.getDeviceName(), isNotEmpty);
    },
  );
}
