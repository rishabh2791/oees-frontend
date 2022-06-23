import 'package:oees/domain/repository/plant_repository.dart';

class PlantApp implements PlantAppInterface {
  final PlantRepository plantRepository;
  PlantApp({required this.plantRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> plant) async {
    return plantRepository.create(plant);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> plants) async {
    return plantRepository.createMultiple(plants);
  }

  @override
  Future<Map<String, dynamic>> getPlant(String id) async {
    return plantRepository.getPlant(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return plantRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> plant) async {
    return plantRepository.update(id, plant);
  }
}

abstract class PlantAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> plant);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> plants);
  Future<Map<String, dynamic>> getPlant(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> plant);
}
