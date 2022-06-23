abstract class PlantRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> plant);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> plants);
  Future<Map<String, dynamic>> getPlant(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> plant);
}
