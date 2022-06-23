import 'package:oees/domain/repository/dowtime_preset_repository.dart';

class DowntimePresetApp implements DowntimePresetAppInterface {
  final DowntimePresetRepository downtimePresetRepository;

  DowntimePresetApp({required this.downtimePresetRepository});
  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtimePreset) async {
    return downtimePresetRepository.create(downtimePreset);
  }

  @override
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> downtimePreset) async {
    return downtimePresetRepository.createMultiple(downtimePreset);
  }

  @override
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions) async {
    return downtimePresetRepository.list(conditions);
  }
}

abstract class DowntimePresetAppInterface {
  Future<Map<String, dynamic>> create(Map<String, dynamic> downtimePreset);
  Future<Map<String, dynamic>> createMultiple(List<Map<String, dynamic>> downtimePreset);
  Future<Map<String, dynamic>> list(Map<String, dynamic> conditions);
}
