import 'package:oees/domain/repository/device_data_repository.dart';
import 'package:oees/infrastructure/enums/token_type.dart';
import 'package:oees/infrastructure/network/network.dart';

class DeviceDataRepo implements DeviceDataRepository {
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> deviceData) async {
    String url = "device_data/create/";
    var response = await networkAPIProvider.post(url, deviceData, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    String url = "device_data/";
    var response = await networkAPIProvider.post(url, conditions, TokenType.accessToken);
    return response;
  }

  @override
  Future<Map<String, dynamic>> totalDeviceData(Map<String, dynamic> conditions) async {
    String url = "device_data/total/";
    return await networkAPIProvider.post(url, conditions, TokenType.accessToken);
  }
}
