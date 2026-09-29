abstract interface class DeviceInfo {
  Future<String> generateDeviceId();

  Future<String> getDeviceName();
}

abstract interface class InstallationIdStore {
  Future<String?> read();
  Future<void> write(String id);
}
