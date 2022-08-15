import 'package:oees/domain/repository/sku_repository.dart';

class SKUApp implements SKUAppInterface {
  final SKURepository skuRepository;
  SKUApp({required this.skuRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> sku) async {
    return skuRepository.create(sku);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> skus) async {
    return skuRepository.createMultiple(skus);
  }

  @override
  Future<Map<String, dynamic>> getSKU(String id) async {
    return skuRepository.getSKU(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return skuRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> sku) async {
    return skuRepository.update(id, sku);
  }
}

abstract class SKUAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> sku);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> skus);
  Future<Map<String, dynamic>> getSKU(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> sku);
}
