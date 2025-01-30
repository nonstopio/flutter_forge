import 'contact_permission_platform_interface.dart';

class ContactPermission {
  static Future<bool> isPermissionGranted() {
    try {
      return ContactPermissionPlatform.instance.isPermissionGranted();
    } catch (e) {
      return Future.value(false);
    }
  }

  static Future<bool> requestPermission() {
    try {
      return ContactPermissionPlatform.instance.requestPermission();
    } catch (e) {
      return Future.value(false);
    }
  }
}
