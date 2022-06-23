import 'package:oees/domain/repository/user_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class UserRepo implements UserRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> user) async {
    String url = "user/create/";
    var response = await networkAPIProvider.post(url, user, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> users) async {
    String url = "user/create/multi/";
    var response = await networkAPIProvider.post(url, users, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getUser(String id) async {
    String url = "user/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "user/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> user) async {
    String url = "user/" + id + "/";
    var response = await networkAPIProvider.patch(url, user, TokenType.accessToken);
    return response;
  }
}
