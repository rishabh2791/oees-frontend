import 'package:oees/domain/repository/dowtime_preset_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class DowntimePresetRepo implements DowntimePresetRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtimePreset) async {
    String url = "preset/create/";
    var response = await networkAPIProvider.post(url, downtimePreset, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> downtimePreset) async {
    String url = "preset/create/multi/";
    var response = await networkAPIProvider.post(url, downtimePreset, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "preset/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }
}
