abstract class UserRoleAccessRepository {
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRoleAccess);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> userRoleAccess);
  Future<Map<String, dynamic>> list(String userRole);
  Future<Map<String, dynamic>> update(String userRole, Map<String, dynamic> userRoleAccess);
}
