import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'contact_permission_platform_interface.dart';

/// An implementation of [ContactPermissionPlatform] that uses method channels.
class MethodChannelContactPermission extends ContactPermissionPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nonstopio_contact_permission');

  @override
  Future<bool> isPermissionGranted() async {
    final version =
        await methodChannel.invokeMethod<bool>('isPermissionGranted');
    return version ?? false;
  }

  @override
  Future<bool> requestPermission() async {
    final version = await methodChannel.invokeMethod<bool>('requestPermission');
    return version ?? false;
  }
}
