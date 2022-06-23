import 'package:oees/domain/repository/user_role_access_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class UserRoleAccessRepo implements UserRoleAccessRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> userRoleAccess) async {
    String url = "user_role_access/create/";
    var response = await networkAPIProvider.post(url, userRoleAccess, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> userRoleAccess) async {
    String url = "user_role_access/create/multi/";
    var response = await networkAPIProvider.post(url, userRoleAccess, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(String userRole) async {
    String url = "user_role_access/" + userRole + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String userRole, Map<String, dynamic> userRoleAccess) async {
    String url = "user_role_access/" + userRole + "/";
    var response = await networkAPIProvider.patch(url, userRoleAccess, TokenType.accessToken);
    return response;
  }
}
