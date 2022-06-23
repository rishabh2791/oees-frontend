abstract class UserRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> user);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> users);
  Future<Map<String, dynamic>> getUser(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> user);
}
