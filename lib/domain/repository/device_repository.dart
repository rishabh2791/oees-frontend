abstract class DeviceRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> device);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> devices);
  Future<Map<String, dynamic>> getDevice(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> device);
}
