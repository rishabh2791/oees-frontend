abstract class DeviceDataRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> deviceData);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> totalDeviceData(Map<String, dynamic> conditions);
}
