import 'package:oees/domain/repository/plant_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class PlantRepo implements PlantRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> plant) async {
    String url = "plant/create/";
    var response = await networkAPIProvider.post(url, plant, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> plants) async {
    String url = "plant/create/multi/";
    var response = await networkAPIProvider.post(url, plants, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getPlant(String id) async {
    String url = "plant/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "plant/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> plant) async {
    String url = "plant/" + id + "/";
    var response = await networkAPIProvider.patch(url, plant, TokenType.accessToken);
    return response;
  }
}
