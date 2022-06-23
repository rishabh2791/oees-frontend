import 'package:oees/domain/repository/user_role_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class UserRoleRepo implements UserRoleRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRole) async {
    String url = "user_role/create/";
    var response = await networkAPIProvider.post(url, userRole, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> userRoles) async {
    String url = "user_role/create/multi/";
    var response = await networkAPIProvider.post(url, userRoles, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getUserRole(String id) async {
    String url = "user_role/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "user_role/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> userRole) async {
    String url = "user_role/" + id + "/";
    var response = await networkAPIProvider.patch(url, userRole, TokenType.accessToken);
    return response;
  }
}
