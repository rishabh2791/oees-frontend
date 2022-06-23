import 'package:oees/domain/repository/downtime_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class DowntimeRepo implements DowntimeRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtime) async {
    String url = "downtime/create/";
    var response = await networkAPIProvider.post(url, downtime, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getDowntime(String id) async {
    String url = "downtime/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "downtime/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> downtime) async {
    String url = "downtime/" + id + "/";
    var response = await networkAPIProvider.patch(url, downtime, TokenType.accessToken);
    return response;
  }
}
