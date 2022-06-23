import 'package:oees/domain/repository/job_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class JobRepo implements JobRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> job) async {
    String url = "job/create/";
    var response = await networkAPIProvider.post(url, job, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> jobs) async {
    String url = "job/create/multi/";
    var response = await networkAPIProvider.post(url, jobs, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getLine(String id) async {
    String url = "job/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "job/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }
}
