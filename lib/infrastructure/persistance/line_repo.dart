import 'package:oees/domain/repository/line_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class LineRepo implements LineRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> line) async {
    String url = "line/create/";
    var response = await networkAPIProvider.post(url, line, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> lines) async {
    String url = "line/create/multi/";
    var response = await networkAPIProvider.post(url, lines, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getLine(String id) async {
    String url = "line/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "line/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> line) async {
    String url = "line/" + id + "/";
    var response = await networkAPIProvider.patch(url, line, TokenType.accessToken);
    return response;
  }
}
