import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'contact_permission_method_channel.dart';

abstract class ContactPermissionPlatform extends PlatformInterface {
  /// Constructs a ContactPermissionPlatform.
  ContactPermissionPlatform() : super(token: _token);

  static final Object _token = Object();

  static ContactPermissionPlatform _instance = MethodChannelContactPermission();

  /// The default instance of [ContactPermissionPlatform] to use.
  ///
  /// Defaults to [MethodChannelContactPermission].
  static ContactPermissionPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ContactPermissionPlatform] when
  /// they register themselves.
  static set instance(ContactPermissionPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> isPermissionGranted();

  Future<bool> requestPermission();
}
