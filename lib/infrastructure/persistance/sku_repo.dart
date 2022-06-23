import 'package:oees/domain/repository/sku_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class SKURepo implements SKURepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> sku) async {
    String url = "sku/create/";
    var response = await networkAPIProvider.post(url, sku, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> skus) async {
    String url = "sku/create/multi/";
    var response = await networkAPIProvider.post(url, skus, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getSKU(String id) async {
    String url = "sku/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "sku/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> sku) async {
    String url = "sku/" + id + "/";
    var response = await networkAPIProvider.patch(url, sku, TokenType.accessToken);
    return response;
  }
}
