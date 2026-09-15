abstract class DeviceInfo {
  Future<String> generateDeviceId();

  Future<String> getDeviceName();
}

abstract class InstallationIdStore {
  Future<String?> read();
  Future<void> write(String id);
}
