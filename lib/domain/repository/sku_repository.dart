abstract class SKURepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> sku);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> skus);
  Future<Map<String, dynamic>> getSKU(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> sku);
}
