import 'package:oees/domain/repository/task_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class TaskRepo implements TaskRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> task) async {
    String url = "task/create/";
    var response = await networkAPIProvider.post(url, task, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> skus) async {
    String url = "task/create/multi/";
    var response = await networkAPIProvider.post(url, skus, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getTask(String id) async {
    String url = "task/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "task/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> sku) async {
    String url = "task/" + id + "/";
    var response = await networkAPIProvider.patch(url, sku, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> delete(String id) async {
    String url = "task/delete/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }
}
