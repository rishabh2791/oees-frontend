import 'package:oees/domain/repository/task_batch_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class TaskBatchRepo implements TaskBatchRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> task) async {
    String url = "task_batch/create/";
    var response = await networkAPIProvider.post(url, task, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(String taskID) async {
    String url = "task_batch/" + taskID + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> task) async {
    String url = "task_batch/" + id + "/";
    var response = await networkAPIProvider.patch(url, task, TokenType.accessToken);
    return response;
  }
}
