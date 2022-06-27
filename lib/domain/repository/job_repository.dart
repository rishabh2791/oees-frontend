abstract class JobRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> job);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> jobs);
  Future<Map<String, dynamic>> getLine(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> pullFromSyspro();
}
