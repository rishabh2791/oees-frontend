import 'package:oees/domain/repository/downtime_repository.dart';

class DowntimeApp implements DowntimeAppInterface {
  final DowntimeRepository downtimeRepository;
  DowntimeApp({required this.downtimeRepository});

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtime) async {
    return downtimeRepository.create(downtime);
  }

  @override
  Future<Map<String, dynamic>> getDowntime(String id) async {
    return downtimeRepository.getDowntime(id);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return downtimeRepository.list(conditions);
  }

  @override
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> downtime) async {
    return downtimeRepository.update(id, downtime);
  }
}

abstract class DowntimeAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtime);
  Future<Map<String, dynamic>> getDowntime(String id);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> downtime);
}
