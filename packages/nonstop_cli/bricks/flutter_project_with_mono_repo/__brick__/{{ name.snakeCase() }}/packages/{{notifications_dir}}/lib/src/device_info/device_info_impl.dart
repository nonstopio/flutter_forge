import 'dart:convert';
import 'dart:io';

import 'package:core/logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:di/di.dart';
import 'package:notifications/src/device_info/device_info.dart';

/// Concrete implementation of DeviceInfo for Android and iOS only
/// Generates consistent device identifiers using stable device characteristics
class DeviceInfoImpl implements DeviceInfo {
  static const String _tag = 'DeviceInfoImpl';

  final Logger _logger;
  final DeviceInfoPlugin _deviceInfoPlugin;

  DeviceInfoImpl({Logger? logger, DeviceInfoPlugin? deviceInfoPlugin})
    : _logger = logger ?? di.get<Logger>(),
      _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  @override
  Future<String> generateDeviceId() async {
    try {
      if (Platform.isAndroid) {
        return await _generateAndroidDeviceId();
      } else if (Platform.isIOS) {
        return await _generateIOSDeviceId();
      } else {
        _logger.w('$_tag: Unsupported platform: ${Platform.operatingSystem}');
        throw UnsupportedError('Only Android and iOS platforms are supported');
      }
    } catch (e) {
      _logger.w('$_tag: Error generating device ID: $e');
      return _generateFallbackId();
    }
  }

  @override
  Future<String> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceName();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceName();
      } else {
        _logger.w('$_tag: Unsupported platform: ${Platform.operatingSystem}');
        throw UnsupportedError('Only Android and iOS platforms are supported');
      }
    } catch (e) {
      _logger.w('$_tag: Error getting device name: $e');
      return _getFallbackDeviceName();
    }
  }

  /// Generate Android device ID using stable hardware characteristics
  Future<String> _generateAndroidDeviceId() async {
    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;

      // Use only the most stable hardware characteristics that don't change
      final stableCharacteristics = [
        androidInfo.brand,
        androidInfo.model,
        androidInfo.device,
        androidInfo.hardware,
        androidInfo.board,
        androidInfo.bootloader,
        androidInfo.product,
        // fingerprint contains build info but is generally stable for same device
        androidInfo.fingerprint,
        // Physical device indicator
        androidInfo.isPhysicalDevice.toString(),
        // Hardware features that are stable
        androidInfo.supportedAbis.join(','),
        androidInfo.supported32BitAbis.join(','),
        androidInfo.supported64BitAbis.join(','),
      ];

      // Remove empty values and create a deterministic string
      final cleanCharacteristics = stableCharacteristics
          .where((char) => char.isNotEmpty && char != 'null')
          .toList();

      if (cleanCharacteristics.isEmpty) {
        throw Exception('No stable characteristics found for Android device');
      }

      // Sort to ensure consistent ordering
      cleanCharacteristics.sort();

      final deviceString = cleanCharacteristics.join('|');
      final deviceHash = _generateDeterministicHash(deviceString);

      _logger.d(
        '$_tag: Generated Android device ID from '
        '${cleanCharacteristics.length} characteristics',
      );
      return 'android_$deviceHash';
    } catch (e) {
      _logger.w('$_tag: Android device ID generation failed: $e');
      rethrow;
    }
  }

  /// Generate iOS device ID using identifierForVendor or stable characteristics
  Future<String> _generateIOSDeviceId() async {
    try {
      final iosInfo = await _deviceInfoPlugin.iosInfo;

      // First preference: use identifierForVendor as it's designed to be stable
      final identifier = iosInfo.identifierForVendor;
      if (identifier != null && identifier.isNotEmpty && identifier != 'null') {
        _logger.d('$_tag: Using iOS identifierForVendor');
        return 'ios_$identifier';
      }

      // Fallback: use stable device characteristics
      _logger.i(
        '$_tag: iOS identifierForVendor not available, '
        'using device characteristics',
      );

      final stableCharacteristics = [
        iosInfo.model,
        iosInfo.localizedModel,
        iosInfo.systemName,
        iosInfo.isPhysicalDevice.toString(),
        // Machine identifier from utsname (hardware model)
        iosInfo.utsname.machine,
        iosInfo.utsname.sysname,
        // These are generally stable for the same device model
        iosInfo.utsname.nodename,
      ];

      // Remove empty values and create a deterministic string
      final cleanCharacteristics = stableCharacteristics
          .where((char) => char.isNotEmpty && char != 'null')
          .toList();

      if (cleanCharacteristics.isEmpty) {
        throw Exception('No stable characteristics found for iOS device');
      }

      // Sort to ensure consistent ordering
      cleanCharacteristics.sort();

      final deviceString = cleanCharacteristics.join('|');
      final deviceHash = _generateDeterministicHash(deviceString);

      _logger.d(
        '$_tag: Generated iOS device ID from '
        '${cleanCharacteristics.length} characteristics',
      );
      return 'ios_$deviceHash';
    } catch (e) {
      _logger.w('$_tag: iOS device ID generation failed: $e');
      rethrow;
    }
  }

  /// Get Android device name in format "Brand Model"
  Future<String> _getAndroidDeviceName() async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    final brand = androidInfo.brand;
    final model = androidInfo.model;

    return '$brand $model';
  }

  /// Get iOS device name in format "Name (Model)"
  Future<String> _getIOSDeviceName() async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    final name = iosInfo.name;
    final model = iosInfo.model;

    return '$name ($model)';
  }

  /// Generate a deterministic hash from device characteristics
  /// Uses SHA-256 to create a consistent, stable hash
  String _generateDeterministicHash(String input) {
    // Add a salt to make the hash more unique while keeping it deterministic
    const salt = 'device_identifier_salt_2024';
    final saltedInput = '$salt|$input';

    final bytes = utf8.encode(saltedInput);
    final digest = sha256.convert(bytes);

    // Return first 16 characters for reasonable length
    return digest.toString().substring(0, 16);
  }

  /// Generate a fallback device ID when all other methods fail
  String _generateFallbackId() {
    final platform = Platform.isAndroid ? 'android' : 'ios';

    // Use a deterministic fallback based on platform
    final fallbackString = '${platform}_fallback_device';
    final fallbackHash = _generateDeterministicHash(fallbackString);

    _logger.w('$_tag: Using deterministic fallback ID');
    return '${platform}_$fallbackHash';
  }

  /// Get fallback device name when detection fails
  String _getFallbackDeviceName() {
    return Platform.isAndroid ? 'Android Device' : 'iOS Device';
  }
}
