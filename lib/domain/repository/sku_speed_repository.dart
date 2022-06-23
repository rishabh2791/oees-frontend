abstract class SKUSpeedRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> skuSpeed);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> skuSpeeds);
  Future<Map<String, dynamic>> getSKUSpeed(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> skuSpeed);
}
