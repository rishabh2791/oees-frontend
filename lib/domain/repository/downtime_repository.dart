abstract class DowntimeRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtime);
  Future<Map<String, dynamic>> getDowntime(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> downtime);
}
