import 'package:oees/domain/repository/device_repository.dart';

class DeviceApp implements DeviceAppInterface {
  final DeviceRepository deviceRepository;
  DeviceApp({required this.deviceRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> device) async {
    return deviceRepository.create(device);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> devices) async {
    return deviceRepository.createMultiple(devices);
  }

  @override
  Future<Map<String, dynamic>> getDevice(String id) async {
    return deviceRepository.getDevice(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return deviceRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> device) async {
    return deviceRepository.update(id, device);
  }
}

abstract class DeviceAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> device);
  Future<Map<String, dynamic>> createMultiple(Map<String, dynamic> devices);
  Future<Map<String, dynamic>> getDevice(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> device);
}
