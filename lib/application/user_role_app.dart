import 'package:oees/domain/repository/user_role_repository.dart';

class UserRoleApp implements UserRoleAppInterface {
  final UserRoleRepository userRoleRepository;
  UserRoleApp({required this.userRoleRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRole) async {
    return userRoleRepository.create(userRole);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> userRoles) async {
    return userRoleRepository.createMultiple(userRoles);
  }

  @override
  Future<Map<String, dynamic>> getUserRole(String id) async {
    return userRoleRepository.getUserRole(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return userRoleRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> userRole) async {
    return userRoleRepository.update(id, userRole);
  }
}

abstract class UserRoleAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRole);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> userRoles);
  Future<Map<String, dynamic>> getUserRole(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> userRole);
}
