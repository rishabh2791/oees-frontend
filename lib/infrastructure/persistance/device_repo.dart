import 'package:oees/domain/repository/device_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class DeviceRepo implements DeviceRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> device) async {
    String url = "device/create/";
    var response = await networkAPIProvider.post(url, device, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> devices) async {
    String url = "device/create/multi/";
    var response = await networkAPIProvider.post(url, devices, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> getDevice(String id) async {
    String url = "device/" + id + "/";
    var response = await networkAPIProvider.get(url, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "device/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> device) async {
    String url = "device/" + id + "/";
    var response = await networkAPIProvider.patch(url, device, TokenType.accessToken);
    return response;
  }
}
