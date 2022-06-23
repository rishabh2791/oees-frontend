import 'package:oees/domain/repository/shift_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class ShiftRepo implements ShiftRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> shift) async {
    String url = "shift/create/";
    var response = await networkAPIProvider.post(url, shift, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> shifts) async {
    String url = "shift/create/multi/";
    var response = await networkAPIProvider.post(url, shifts, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getShift(String id) async {
    String url = "shift/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "shift/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> shift) async {
    String url = "shift/" + id + "/";
    var response = await networkAPIProvider.patch(url, shift, TokenType.accessToken);
    return response;
  }
}
