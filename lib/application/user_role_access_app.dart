import 'package:oees/domain/repository/user_role_access_repository.dart';

class UserRoleAccessApp implements UserRoleAccessAppInterface {
  UserRoleAccessRepository userRoleAccessRepository;

  UserRoleAccessApp({
    required this.userRoleAccessRepository,
  });

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRoleAccess) async {
    return userRoleAccessRepository.create(userRoleAccess);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> userRoleAccess) async {
    return userRoleAccessRepository.createMultiple(userRoleAccess);
  }

  @override
  Future<Map<String, dynamic>> list(String userRole) async {
    return userRoleAccessRepository.list(userRole);
  }

  @override
  Future<Map<String, dynamic>> update(String userRole, Map<String, dynamic> userRoleAccess) async {
    return userRoleAccessRepository.update(userRole, userRoleAccess);
  }
}

abstract class UserRoleAccessAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRoleAccess);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> userRoleAccess);
  Future<Map<String, dynamic>> list(String userRole);
  Future<Map<String, dynamic>> update(String userRole, Map<String, dynamic> userRoleAccess);
}
