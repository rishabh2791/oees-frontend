import 'package:oees/domain/repository/auth_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class AuthRepo implements AuthRepository {
  @override
  Future<Map<String, dynamic>> login(Map<String, dynamic> loginDetails) async {
    String url = "auth/login/";
    var response = await networkAPIProvider.post(url, loginDetails, TokenType.none);
    return response;
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    String url = "auth/logout/";
    var response = await networkAPIProvider.post(url, {}, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> refresh() async {
    String url = "auth/refresh/";
    var response = await networkAPIProvider.get(url, TokenType.refreshToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> resetPassword(
    Map<String, dynamic> passwordDetails,
  ) async {
    String url = "auth/reset/password/";
    var response = await networkAPIProvider.post(url, passwordDetails, TokenType.accessToken);
    return response;
  }
}
