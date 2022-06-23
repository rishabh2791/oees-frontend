import 'package:oees/domain/repository/sku_speed_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class SKUSpeedRepo implements SKUSpeedRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> skuSpeed) async {
    String url = "sku_speed/create/";
    var response = await networkAPIProvider.post(url, skuSpeed, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> skuSpeeds) async {
    String url = "sku_speed/create/multi/";
    var response = await networkAPIProvider.post(url, skuSpeeds, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getSKUSpeed(String id) async {
    String url = "sku_speed/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "sku_speed/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> skuSpeed) async {
    String url = "sku_speed/" + id + "/";
    var response = await networkAPIProvider.patch(url, skuSpeed, TokenType.accessToken);
    return response;
  }
}
