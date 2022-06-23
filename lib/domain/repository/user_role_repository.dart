abstract class UserRoleRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRole);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> userRoles);
  Future<Map<String, dynamic>> getUserRole(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> userRole);
}
