abstract class LineRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> line);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> lines);
  Future<Map<String, dynamic>> getLine(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> line);
}
