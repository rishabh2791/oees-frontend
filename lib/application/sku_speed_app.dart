import 'package:oees/domain/repository/sku_speed_repository.dart';

class SKUSpeedApp implements SKUSpeedAppInterface {
  final SKUSpeedRepository skuSpeedRepository;
  SKUSpeedApp({required this.skuSpeedRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> skuSpeed) async {
    return skuSpeedRepository.create(skuSpeed);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> skuSpeeds) async {
    return skuSpeedRepository.createMultiple(skuSpeeds);
  }

  @override
  Future<Map<String, dynamic>> getSKUSpeed(String id) async {
    return skuSpeedRepository.getSKUSpeed(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return skuSpeedRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> skuSpeed) async {
    return skuSpeedRepository.update(id, skuSpeed);
  }
}

abstract class SKUSpeedAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> skuSpeed);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> skuSpeeds);
  Future<Map<String, dynamic>> getSKUSpeed(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> skuSpeed);
}
