import 'dart:math';

import 'package:core/logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:notifications/src/device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists a random installation identifier, independent of hardware models.
class SharedPreferencesInstallationIdStore implements InstallationIdStore {
  SharedPreferencesInstallationIdStore({SharedPreferences? preferences})
    : _provided = preferences;
  final SharedPreferences? _provided;
  Future<SharedPreferences> get _preferences async =>
      _provided ?? await SharedPreferences.getInstance();
  static const _key = 'nonstop.installation_id';

  @override
  Future<String?> read() async => (await _preferences).getString(_key);

  @override
  Future<void> write(String id) async {
    final saved = await (await _preferences).setString(_key, id);
    if (!saved) throw StateError('Could not persist installation ID');
  }
}

/// Supplies installation identity and a human-readable device label.
class DeviceInfoImpl implements DeviceInfo {
  DeviceInfoImpl({
    required Logger logger,
    DeviceInfoPlugin? deviceInfoPlugin,
    InstallationIdStore? store,
    String Function()? createId,
  }) : _logger = logger,
       _plugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
       _store = store ?? SharedPreferencesInstallationIdStore(),
       _createId = createId ?? _randomId;

  final Logger _logger;
  final DeviceInfoPlugin _plugin;
  final InstallationIdStore _store;
  final String Function() _createId;
  Future<String>? _id;

  static String _randomId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  @override
  Future<String> generateDeviceId() async {
    if (_id != null) return _id!;
    final pending = _loadId();
    _id = pending;
    try {
      return await pending;
    } catch (error) {
      _id = null;
      _logger.w('Installation ID storage failed: $error');
      rethrow;
    }
  }

  Future<String> _loadId() async {
    final existing = await _store.read();
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _createId();
    await _store.write(id);
    return id;
  }

  @override
  Future<String> getDeviceName() async {
    try {
      final data = (await _plugin.deviceInfo).data;
      final name = data['name'] ?? data['model'] ?? data['computerName'];
      if (name is String && name.isNotEmpty) return name;
    } catch (error) {
      _logger.w('Device name unavailable: $error');
    }
    return kIsWeb ? 'Web browser' : defaultTargetPlatform.name;
  }
}
